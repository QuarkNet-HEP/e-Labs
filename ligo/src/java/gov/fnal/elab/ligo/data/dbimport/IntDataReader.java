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

class IntDataReader extends DataReader<Integer, Long> {

    public IntDataReader(Connection conn, String table, AbstractDataTool impd) {
        super(conn, table, impd);
    }

    @Override
    protected Integer readOne(InputStream is) throws IOException {
        int v = 0;
        for (int j = 0; j < 4; j++) {
            int c = is.read();
            if (c == -1) {
                return null;
            }
            v = (v >> 8) + ((c << 24) & 0xff000000);
        }
        return v;
    }

    @Override
    protected Long add(Long s, Long v) {
        return s + v;
    }

    @Override
    protected Long multiply(Long v, int i) {
        return v * i;
    }

    @Override
    protected Long sqr(Integer v) {
        return ((long) v) * v;
    }

    @Override
    protected Long widen(Integer v) {
        return (long) v;
    }

    @Override
    protected Long zero() {
        return 0L;
    }

    @Override
    protected Long getSum(ResultSet rs, int i) throws SQLException {
        return rs.getLong(i);
    }

    @Override
    protected void setSum(PreparedStatement ps, int i, Long sum) throws SQLException {
        ps.setLong(i, sum);
    }

    @Override
    protected void setValue(PreparedStatement ps, int i, Integer value) throws SQLException {
        ps.setInt(i, value);
    }

    @Override
    protected Long subtract(Long s, Long v) {
        return s - v;
    }

    @Override
    protected void writeSum(PGDataFileWriter wr, Long sum) throws IOException {
        wr.writeLong(sum);
    }

    @Override
    protected void writeValue(PGDataFileWriter wr, Integer value) throws IOException {
        wr.writeInt(value);
    }

}