/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

class DoubleDataReader extends DataReader<Double, Double> {

    public DoubleDataReader(Connection conn, String table) {
        super(conn, table);
    }

    protected Double readOne(InputStream is) throws IOException {
        long v = 0;
        for (int j = 0; j < 8; j++) {
            long l = is.read();
            if (l == -1) {
                return null;
            }
            v = (v >> 8) + ((l << 56) & 0xff00000000000000L);
        }

        return Double.longBitsToDouble(v);
    }

    @Override
    protected Double add(Double s, Double v) {
        return s + v;
    }

    @Override
    protected Double multiply(Double v, int i) {
        return v * i;
    }

    @Override
    protected Double sqr(Double v) {
        return v * v;
    }

    @Override
    protected Double widen(Double v) {
        return v;
    }

    @Override
    protected Double zero() {
        return 0.0;
    }

    @Override
    protected Double getSum(ResultSet rs, int i) throws SQLException {
        return rs.getDouble(i);
    }

    @Override
    protected void setSum(PreparedStatement ps, int i, Double sum) throws SQLException {
        ps.setDouble(i, sum);
    }

    @Override
    protected void setValue(PreparedStatement ps, int i, Double value) throws SQLException {
        ps.setDouble(i, value);
    }

    @Override
    protected Double subtract(Double s, Double v) {
        return s - v;
    }

}