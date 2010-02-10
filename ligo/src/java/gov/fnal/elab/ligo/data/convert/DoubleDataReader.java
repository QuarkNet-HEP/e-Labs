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
import java.util.ArrayList;
import java.util.List;

final class DoubleDataReader extends DataReader<Double, Double> {

    public DoubleDataReader(AbstractDataTool impd) {
        super(impd);
    }

    protected Double readOne(InputStream is) throws IOException {
        try {
            return EncodingTools.readDouble(is);
        }
        catch (EOFException e) {
            return null;
        }
    }
    
    @Override
    protected void removeBoundaries(List<Double> data) {
        for (int i = 1; i < data.size(); i++) {
            if (data.get(i) == 0) {
                data.set(i - 1, 0.0);
            }
        }
        for (int i = data.size() - 1; i > 1; i--) {
            if (data.get(i - 1) == 0) {
                data.set(i, 0.0);
            }
        }
    }

    @Override
    protected boolean isZero(Double value) {
        return value.doubleValue() == 0;
    }

    @Override
    protected Double zeroValue() {
        return 0.0;
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
    protected void setValue(PreparedStatement ps, int i, Double value) throws SQLException {
        ps.setDouble(i, value);
    }

    @Override
    protected Double subtract(Double s, Double v) {
        return s - v;
    }

    @Override
    protected void writeSum(DataFileWriter wr, Double sum) throws IOException {
        wr.writeDouble(sum);
    }

    @Override
    protected void writeValue(DataFileWriter wr, Double value) throws IOException {
        wr.writeDouble(value);
    }

    @Override
    protected Double readSum(RandomAccessFile raf) throws IOException {
        return EncodingTools.readDouble(raf);
    }
}