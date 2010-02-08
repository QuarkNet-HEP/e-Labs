/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

class IntDataReader extends DataReader<Integer, Long> {

    public IntDataReader(AbstractDataTool impd) {
        super(impd);
    }

    @Override
    protected Integer readOne(InputStream is) throws IOException {
        try {
            return EncodingTools.readInt(is);
        }
        catch (EOFException e) {
            return null;
        }
    }

    @Override
    protected boolean isZero(Integer value) {
        return value == 0;
    }

    @Override
    protected Integer zeroValue() {
        return 0;
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
    protected Long zeroSum() {
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
    protected Integer subtract(Long s, Long v) {
        return (int) (s - v);
    }

    @Override
    protected void writeSum(DataFileWriter wr, Long sum) throws IOException {
        wr.writeLong(sum);
    }

    @Override
    protected void writeValue(DataFileWriter wr, Integer value) throws IOException {
        wr.writeInt(value);
    }

    @Override
    protected Long readSum(RandomAccessFile raf) throws IOException {
        return EncodingTools.readLong(raf);
    }

}