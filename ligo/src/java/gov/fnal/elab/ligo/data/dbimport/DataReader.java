/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.IOException;
import java.io.InputStream;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

abstract class DataReader<ValueType extends Number, SumType extends Number> {

    public static DataReader<?, ?> instance(String type, Connection conn, String table) {
        if (type.equals("int")) {
            return new IntDataReader(conn, table);
        }
        else if (type.equals("double")) {
            return new DoubleDataReader(conn, table);
        }
        else if (type.equals("float")) {
            return new FloatDataReader(conn, table);
        }
        else {
            throw new RuntimeException("No reader for type " + type);
        }
    }

    private List<ValueType> rms, mean;
    private List<DataReaderEntry<ValueType, SumType>> data;
    private Connection conn;
    private String table;

    protected DataReader(Connection conn, String table) {
        this.conn = conn;
        this.table = table;
        rms = new ArrayList<ValueType>();
        mean = new ArrayList<ValueType>();
    }

    public int size() {
        return rms.size();
    }

    protected boolean readOne(InputStream isrms, InputStream ismean) throws IOException {
        ValueType v = readOne(isrms);
        if (v == null) {
            return false;
        }
        rms.add(v);
        mean.add(v = readOne(ismean));
        if (v == null) {
            throw new IOException("rms and mean data don't match");
        }
        return true;
    }

    public void process(double startTime, double interval, int rawSamplesPerSecond) {
        data = new ArrayList<DataReaderEntry<ValueType, SumType>>();
        SumType sum = zero();
        SumType ssq = zero();
        for (int i = 0; i < rms.size(); i++) {
            double time = startTime + i * interval / rms.size();
            ValueType value = mean.get(i);
            sum = add(sum, widen(value));
            ValueType vrms = rms.get(i);
            ssq = add(ssq, multiply(sqr(vrms), ImportData.RAW_SAMPLES_PER_SECOND));
            data.add(new DataReaderEntry<ValueType, SumType>(time, value, sum, ssq));
        }
    }

    public void insertIntoDatabase() throws Exception {
        conn.setAutoCommit(false);
        try {
            double startTime = data.get(0).gpstime;
            double endTime = data.get(data.size() - 1).gpstime;

            DataReaderEntry<ValueType, SumType> lower = getLargestMinorant(conn, table, startTime);

            // Find out if there is any data in the db before the endTime
            // If there is, it needs to be removed, and the sums after need
            // updating
            boolean overlap = false;

            DataReaderEntry<ValueType, SumType> upper = getLargestMinorant(conn, table, startTime);

            if (lower.gpstime != upper.gpstime) {
                removeData(lower.gpstime, upper.gpstime);
            }

            SumType lsum = data.get(data.size() - 1).sum;
            SumType lssq = data.get(data.size() - 1).ssq;
            // removal would have changed the sum by -(upper.sum -
            // lower.sum)
            // which should be 0 if no removal occurred;
            // add lsum to that
            insertSumShift(startTime, endTime, subtract(lsum, subtract(upper.sum, lower.sum)), subtract(lssq, subtract(
                upper.ssq, lower.ssq)));

            Timings.timingStart("insertData");
            PreparedStatement in1 = conn.prepareStatement("INSERT INTO " + table + " VALUES (?, ?, ?, ?)");
            for (DataReaderEntry<ValueType, SumType> e : data) {
                in1.setDouble(1, e.gpstime);
                setValue(in1, 2, e.value);
                setSum(in1, 3, add(e.sum, lower.sum));
                setSum(in1, 4, add(e.ssq, lower.ssq));
                in1.addBatch();
            }
            in1.executeBatch();
            Timings.timingEnd("insertData");

            in1.close();
            Timings.timingStart("commitTransaction");
            conn.commit();
            Timings.timingEnd("commitTransaction");
        }
        catch (BatchUpdateException e) {
            conn.rollback();
            throw e.getNextException();
        }
        catch (Exception e) {
            conn.rollback();
            throw e;
        }
        finally {
            conn.setAutoCommit(true);
        }
    }

    private void insertSumShift(double start, double end, SumType sumdif, SumType ssqdif) throws SQLException {
        // don't shift sums right away, because it's an expensive operation
        // instead, add a record of what needs to be shifted and do it
        // after everything else is done
        Timings.timingStart("insertSumShift");
        PreparedStatement qs3 = conn.prepareStatement("SELECT time FROM " + table
                + " WHERE time > ? LIMIT 1");
        qs3.setDouble(1, end);
        ResultSet qr3 = qs3.executeQuery();
        if (!qr3.next()) {
            // no data after this, so no need to update sums
            return;
        }
        PreparedStatement qs1 = conn.prepareStatement("SELECT time FROM " + table
                + " WHERE time > ? AND time < ? LIMIT 1");
        qs1.setDouble(1, start);
        qs1.setDouble(2, end);
        ResultSet qr1 = qs1.executeQuery();
        if (qr1.next()) {
            // cannot join the updates
            insertSumUpdate(start, end, sumdif, ssqdif);
        }
        else {
            PreparedStatement qs2;
            if (sumdif instanceof Long) {
                qs2 = conn
                    .prepareStatement("SELECT (id, sumdeltai, ssqdeltai) FROM sumupdates WHERE tablename = ? AND endtime < ? "
                            + "ORDER BY endtime DESC LIMIT 1");
            }
            else if (sumdif instanceof Double) {
                qs2 = conn
                    .prepareStatement("SELECT (id, sumdeltad, ssqdeltad) FROM sumupdates WHERE tablename = ? AND endtime < ? "
                            + "ORDER BY endtime DESC LIMIT 1");
            }
            else {
                throw new RuntimeException("Invalid type: " + sumdif.getClass());
            }
            qs2.setDouble(1, start);
            qs2.setString(2, table);
            ResultSet qr2 = qs2.executeQuery();
            if (qr2.next()) {
                SumType sumprev, ssqprev;
                sumprev = getSum(qr2, 2);
                ssqprev = getSum(qr2, 3);
                PreparedStatement us1 = null;
                if (sumdif instanceof Long) {
                    us1 = conn
                        .prepareStatement("UPDATE sumupdates SET endtime = ?, sumdeltai = ?, ssqdeltai = ? WHERE id = ?");
                }
                else if (sumdif instanceof Double) {
                    us1 = conn
                        .prepareStatement("UPDATE sumupdates SET endtime = ?, sumdeltad = ?, ssqdeltad = ? WHERE id = ?");
                }

                us1.setDouble(1, end);
                setSum(us1, 2, add(sumdif, sumprev));
                setSum(us1, 3, add(ssqdif, ssqprev));
                us1.setInt(4, qr2.getInt(1));
                us1.execute();
                us1.close();
            }
            else {
                // no previous update
                insertSumUpdate(start, end, sumdif, ssqdif);
            }
            qs2.close();
        }
        qs1.close();
        Timings.timingEnd("insertSumShift");
    }

    private void insertSumUpdate(double start, double end, SumType sumdif, SumType ssqdif) throws SQLException {
        Timings.timingStart("insertSumUpdate");
        PreparedStatement qs2 = conn.prepareStatement("INSERT INTO sumupdates "
                + "(tablename, starttime, endtime, sumdeltad, sumdeltai, ssqdeltad, ssqdeltai) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)");
        qs2.setString(1, table);
        qs2.setDouble(2, start);
        qs2.setDouble(3, end);
        if (sumdif instanceof Long) {
            qs2.setNull(4, Types.DOUBLE);
            qs2.setNull(6, Types.DOUBLE);
            qs2.setDouble(5, sumdif.longValue());
            qs2.setDouble(7, ssqdif.longValue());
        }
        else if (sumdif instanceof Double) {
            qs2.setNull(5, Types.BIGINT);
            qs2.setNull(7, Types.BIGINT);
            qs2.setDouble(4, sumdif.doubleValue());
            qs2.setDouble(6, ssqdif.doubleValue());
        }
        qs2.execute();
        qs2.close();
        Timings.timingEnd("insertSumUpdate");
    }

    /**
     * Removes entries from the table in the interval (start, end]
     */
    private void removeData(double start, double end) throws SQLException {
        PreparedStatement ps = conn.prepareStatement("REMOVE FROM " + table + " WHERE time > ? AND time <= ?");
        try {
            ps.setDouble(1, start);
            ps.setDouble(2, end);
            ps.execute();
        }
        finally {
            ps.close();
        }
    }

    private DataReaderEntry<ValueType, SumType> getLargestMinorant(Connection conn, String table, double startTime)
            throws SQLException {
        Timings.timingStart("getLargestMinorant");
        PreparedStatement ps1 = conn.prepareStatement("SELECT * FROM " + table
                + " WHERE time = (SELECT MAX(time) FROM " + table + " WHERE time < ?)");
        try {
            ps1.setDouble(1, startTime);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) {
                return new DataReaderEntry<ValueType, SumType>(rs1.getDouble(1), null, getSum(rs1, 3), getSum(rs1, 4));
            }
            else {
                return new DataReaderEntry<ValueType, SumType>(0, null, zero(), zero());
            }
        }
        finally {
            Timings.timingEnd("getLargestMinorant");
            ps1.close();
        }
    }

    protected abstract void setValue(PreparedStatement ps, int i, ValueType value) throws SQLException;

    protected abstract void setSum(PreparedStatement ps, int i, SumType sum) throws SQLException;

    protected abstract SumType getSum(ResultSet rs, int i) throws SQLException;

    // like really, java should have this stuff, really
    protected abstract SumType multiply(SumType v, int i);

    protected abstract SumType sqr(ValueType v);

    protected abstract SumType widen(ValueType v);

    protected abstract SumType add(SumType s, SumType v);

    protected abstract SumType subtract(SumType s, SumType v);

    protected abstract SumType zero();

    protected abstract ValueType readOne(InputStream is) throws IOException;
}