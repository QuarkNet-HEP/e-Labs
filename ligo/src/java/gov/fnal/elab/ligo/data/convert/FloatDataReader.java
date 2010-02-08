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

class FloatDataReader extends DataReader<Float, Double> {

    public FloatDataReader(AbstractDataTool impd) {
        super(impd);
    }

    @Override
    protected Float readOne(InputStream is) throws IOException {
        try {
            return EncodingTools.readFloat(is);
        }
        catch (EOFException e) {
            return null;
        }
    }

    @Override
    protected boolean isZero(Float value) {
        return value == 0;
    }

    @Override
    protected Float zeroValue() {
        return 0.0f;
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
    protected Double zeroSum() {
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
    protected Float subtract(Double s, Double v) {
        return (float) (s - v);
    }

    @Override
    protected void writeSum(DataFileWriter wr, Double sum) throws IOException {
        wr.writeDouble(sum);
    }

    @Override
    protected void writeValue(DataFileWriter wr, Float value) throws IOException {
        wr.writeFloat(value);
    }

    @Override
    protected Double readSum(RandomAccessFile raf) throws IOException {
        return EncodingTools.readDouble(raf);
    }

}