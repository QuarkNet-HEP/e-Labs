/*
 * Created on Jan 26, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.expression.data.engine.DataBackendException;
import gov.fnal.elab.expression.data.engine.DataEngine;
import gov.fnal.elab.expression.data.engine.DataPath;
import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.Options;
import gov.fnal.elab.expression.data.engine.Range;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

public class LIGODataEngine implements DataEngine {
    private Connection conn;
    private Map<String, String> tables, types, units;
    private Map<String, Double> slopes, biases;
    private List<DataPath> cachedDPs;

    public LIGODataEngine(Connection conn) {
        this.conn = conn;
    }

    public DataSet get(DataPath path, Range range, Options options) throws DataBackendException {
        try {
            checkCache();
            int ip = path.getName().indexOf('.');
            if (ip == -1) {
                throw new IllegalArgumentException("Invalid data path: " + path);
            }
            String name = path.getName().substring(0, ip);
            String type = path.getName().substring(ip + 1);
            String table = tables.get(name);
            if (table == null) {
                throw new IllegalArgumentException("Invalid data path: " + path);
            }
            PreparedStatement ps1 = conn.prepareStatement("SELECT * FROM " + table
                    + " WHERE time = (SELECT MAX(time) FROM " + table + " WHERE time < ?)");
            PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM " + table
                    + " WHERE time = (SELECT MIN(time) FROM " + table + " WHERE time >= ?)");
            int field;
            if (type.equals(".mean")) {
                field = 3;
            }
            else {
                field = 4;
            }
            String datatype = types.get(name);
            try {
                if (datatype.equals("int")) {
                    return createIntArray(ps1, ps2, path, range, options, field, biases.get(name), slopes.get(name),
                        units.get(name));
                }
                else if (datatype.equals("float")) {
                    return createFloatArray(ps1, ps2, path, range, options, field, biases.get(name), slopes.get(name),
                        units.get(name));
                }
                else {
                    return createDoubleArray(ps1, ps2, path, range, options, field, biases.get(name), slopes.get(name),
                        units.get(name));
                }
            }
            finally {
                ps1.close();
                ps2.close();
            }
        }
        catch (SQLException e) {
            throw new DataBackendException(e);
        }
    }

    private DataSet createDoubleArray(PreparedStatement ps1, PreparedStatement ps2, DataPath path, Range range,
            Options options, int field, double bias, double slope, String units) throws SQLException {
        int samples = options.getSamples();
        SortedMap<Double, Double> sums = new TreeMap<Double, Double>();
        ps1.setDouble(1, range.getStart().doubleValue());
        ResultSet rs = ps1.executeQuery();
        if (rs.next()) {
            sums.put(rs.getDouble(1), rs.getDouble(field));
        }
        else {
            sums.put(0.0, 0.0);
        }
        for (int i = 1; i <= samples; i++) {
            ps2.setDouble(1, range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples);
            rs = ps2.executeQuery();
            if (rs.next()) {
                sums.put(rs.getDouble(1), rs.getDouble(field));
            }
        }
        Double[] data = new Double[samples];
        double min = Double.MAX_VALUE;
        double max = Double.MIN_VALUE;
        for (int i = 0; i < samples; i++) {
            double time = range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples;
            Double l = sums.headMap(time).lastKey();
            Double u = sums.tailMap(time).firstKey();
            data[i] = (sums.get(u) - sums.get(l)) * slope + bias;
            if (min > data[i]) {
                min = data[i];
            }
            if (max < data[i]) {
                max = data[i];
            }
        }
        return new NumberArrayDataSet(path, range, new Range(min, max), data, units);
    }

    private DataSet createFloatArray(PreparedStatement ps1, PreparedStatement ps2, DataPath path, Range range,
            Options options, int field, double bias, double slope, String units) throws SQLException {
        int samples = options.getSamples();
        SortedMap<Double, Float> sums = new TreeMap<Double, Float>();
        ps1.setDouble(1, range.getStart().doubleValue());
        ResultSet rs = ps1.executeQuery();
        if (rs.next()) {
            sums.put(rs.getDouble(1), rs.getFloat(field));
        }
        else {
            sums.put(0.0, 0f);
        }
        for (int i = 1; i <= samples; i++) {
            ps2.setDouble(1, range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples);
            rs = ps2.executeQuery();
            if (rs.next()) {
                sums.put(rs.getDouble(1), rs.getFloat(field));
            }
        }
        Float[] data = new Float[samples];
        double min = Double.MAX_VALUE;
        double max = Double.MIN_VALUE;
        for (int i = 0; i < samples; i++) {
            double time = range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples;
            Double l = sums.headMap(time).lastKey();
            Double u = sums.tailMap(time).firstKey();
            data[i] = sums.get(u) - sums.get(l);
            if (min > data[i]) {
                min = data[i];
            }
            if (max < data[i]) {
                max = data[i];
            }
        }
        return new NumberArrayDataSet(path, range, new Range(min, max), data, units);
    }

    private DataSet createIntArray(PreparedStatement ps1, PreparedStatement ps2, DataPath dp, Range range,
            Options options, int field, double bias, double slope, String units) throws SQLException {
        int samples = options.getSamples();
        SortedMap<Double, Long> sums = new TreeMap<Double, Long>();
        ps1.setDouble(1, range.getStart().doubleValue());
        ResultSet rs = ps1.executeQuery();
        if (rs.next()) {
            sums.put(rs.getDouble(1), rs.getLong(field));
        }
        else {
            sums.put(0.0, 0L);
        }
        for (int i = 1; i <= samples; i++) {
            ps2.setDouble(1, range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples);
            rs = ps2.executeQuery();
            if (rs.next()) {
                sums.put(rs.getDouble(1), rs.getLong(field));
            }
        }
        Integer[] data = new Integer[samples];
        double min = Double.MAX_VALUE;
        double max = Double.MIN_VALUE;
        for (int i = 0; i < samples; i++) {
            double time = range.getStart().doubleValue() + i * range.getRange().doubleValue() / samples;
            Double l = sums.headMap(time).lastKey();
            Double u = sums.tailMap(time).firstKey();
            data[i] = (int) (sums.get(u) - sums.get(l));
            if (min > data[i]) {
                min = data[i];
            }
            if (max < data[i]) {
                max = data[i];
            }
        }
        return new NumberArrayDataSet(dp, range, new Range(min, max), data, units);
    }

    public List<DataPath> getPaths() throws DataBackendException {
        try {
            checkCache();
            return cachedDPs;
        }
        catch (SQLException e) {
            throw new DataBackendException(e);
        }
    }

    private synchronized void checkCache() throws SQLException {
        // check if db modified and reload stuff if necessary
        if (tables == null) {
            loadChannelInfo();
            cachedDPs = new ArrayList<DataPath>();
            for (String channel : tables.keySet()) {
                cachedDPs.add(createDataPath(channel, "mean"));
                cachedDPs.add(createDataPath(channel, "rms"));
            }
        }
    }

    private DataPath createDataPath(String channel, String type) throws SQLException {
        Statement s = conn.createStatement();
        ResultSet rs = s.executeQuery("SELECT MIN(time), MAX(time) FROM " + tables.get(channel));
        if (rs.next()) {
            return new DataPath(channel + "." + type, new Range(rs.getDouble(1), rs.getDouble(2)));
        }
        else {
            return new DataPath(channel + "." + type, new Range(0, 0));
        }
    }

    protected void loadChannelInfo() throws SQLException {
        tables = new HashMap<String, String>();
        types = new HashMap<String, String>();
        units = new HashMap<String, String>();
        slopes = new HashMap<String, Double>();
        biases = new HashMap<String, Double>();
        Statement s = conn.createStatement();
        try {
            ResultSet rs = s.executeQuery("SELECT name, tablename, datatype, units, slope, bias FROM channels");
            while (rs.next()) {
                String name = rs.getString(1);
                tables.put(name, rs.getString(2));
                types.put(name, rs.getString(3));
                units.put(name, rs.getString(4));
                slopes.put(name, rs.getDouble(5));
                biases.put(name, rs.getDouble(6));
            }
        }
        finally {
            s.close();
        }
    }

    private static long time = 0;

    private static void time(String s) {
        long now = System.currentTimeMillis();
        if (time != 0) {
            System.out.println(s + " (" + (now - time) + "ms)");
        }
        time = now;
    }

    public static void main(String[] args) {
        try {
            time("");
            Connection conn = DriverManager.getConnection("jdbc:postgresql:ligodata", "ligo", "ligo");
            time("connect");
            LIGODataEngine eng = new LIGODataEngine(conn);
            time("new");
            List<DataPath> dps = eng.getPaths();
            time("getpaths");
            DataSet ds = eng.get(dps.get(0), dps.get(0).getTotalRange(), new Options().setSamples(800));
            time("get");
            System.out.println(ds);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
