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

class FloatDataReader extends DataReader<Float, Double> {

    public FloatDataReader(Connection conn, String table) {
        super(conn, table);
    }

    @Override
    protected Float readOne(InputStream is) throws IOException {
        int v = 0;
        for (int j = 0; j < 4; j++) {
            int c = is.read();
            if (c == -1) {
                return null;
            }
            v = (v >> 8) + ((c << 24) & 0xff000000);
        }
        float y = Float.intBitsToFloat(v);
        return y;
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
    protected Double sqr(Float v) {
        return ((double) v) * v;
    }

    @Override
    protected Double widen(Float v) {
        return (double) v;
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
    protected void setValue(PreparedStatement ps, int i, Float value) throws SQLException {
        ps.setFloat(i, value);
    }

    @Override
    protected Double subtract(Double s, Double v) {
        return s - v;
    }
}