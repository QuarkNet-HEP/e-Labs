/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

abstract class DataReader<ValueType extends Number, SumType extends Number> {

    public static DataReader<?, ?> instance(String type, AbstractDataTool impd) {
        if (type.equals("int")) {
            return new IntDataReader(impd);
        }
        else if (type.equals("double")) {
            return new DoubleDataReader(impd);
        }
        else if (type.equals("float")) {
            return new FloatDataReader(impd);
        }
        else {
            throw new RuntimeException("No reader for type " + type);
        }
    }

    private List<ValueType> rms, mean;
    private List<DataReaderEntry<ValueType, SumType>> data;
    private AbstractDataTool impd;
    private double minTime, lastAddedTime;
    private SumType sumOffset, ssqOffset;
    private ValueType lastKnownGoodValue, lastKnownGoodSquare;

    protected DataReader(AbstractDataTool impd) {
        this.impd = impd;
        rms = new ArrayList<ValueType>();
        mean = new ArrayList<ValueType>();
        sumOffset = zeroSum();
        ssqOffset = zeroSum();
        lastKnownGoodValue = zeroValue();
        lastKnownGoodSquare = zeroValue();
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

    public void process(double startTime, double totalInterval, int rawSamplesPerSecond) {
        data = new ArrayList<DataReaderEntry<ValueType, SumType>>();
        removeBoundaries(rms);
        removeBoundaries(mean);
        if (lastAddedTime > 0 && startTime - lastAddedTime > samplingInterval) {
            // gap in data (assuming our largest trend is a minute trend)
            // fill with lastKnownGoodValue and mark as invalid
            fillAsInvalid(lastWrittenTime, startTime, rawSamplesPerSecond);
        }
        double currentSamplingInterval = totalInterval / rms.size();
        SumType sum = sumOffset;
        SumType ssq = ssqOffset;
        for (int i = 0; i < rms.size(); i++) {
            boolean valid = true;
            double time = startTime + i * currentSamplingInterval;
            ValueType value = mean.get(i);
            if (isZero(value)) {
                valid = false;
                value = lastKnownGoodValue;
            }
            else {
                lastKnownGoodValue = value;
            }
            // mean = S / n, where mean = value, n = samplingInterval *
            // rawSamplesPerSecond
            // so S = mean * n = value * samplingInterval * rawSamplesPerSecond

            // samplingInterval * rawSamplesPerSecond is integral, since the
            // smallest possible
            // sampling interval is 1/rawSamplesPerSecond, and all other
            // intervals are
            // a multiple of that
            int n = (int) (currentSamplingInterval * rawSamplesPerSecond);
            sum = add(sum, multiply(widen(value), n));
            ValueType vrms = rms.get(i);
            if (!valid) {
                vrms = lastKnownGoodSquare;
            }
            else {
                lastKnownGoodSquare = vrms;
            }
            // _________
            // rms = V Ssq / n
            // Ssq = rms^2 * n
            SumType mtt = add(ssq, multiply(sqr(vrms), n));
            if (mtt instanceof Double && Double.isInfinite(mtt.doubleValue())) {
                System.err.println("SSQ is infinite for time=" + time + ". Ignoring data point");
            }
            else {
                ssq = mtt;
            }

            data.add(new DataReaderEntry<ValueType, SumType>(valid, time, sum, ssq));
            lastAddedTime = time;
        }
        sumOffset = sum;
        ssqOffset = ssq;
        samplingInterval = currentSamplingInterval;
    }

    private void fillAsInvalid(double start, double end, int rawSamplesPerSecond) {
        // one raw sample
        double offset = 1.0 / rawSamplesPerSecond;
        // add sums at the beginning and end of gap
        int n = 1;
        sumOffset = add(sumOffset, multiply(widen(lastKnownGoodValue), n));
        ssqOffset = add(ssqOffset, multiply(sqr(lastKnownGoodSquare), n));
        data.add(new DataReaderEntry<ValueType, SumType>(false, start + offset, sumOffset, ssqOffset));
        // it's not as easy to guarantee that n is integral below
        n = (int) ((end - start) * rawSamplesPerSecond - 2);
        sumOffset = add(sumOffset, multiply(widen(lastKnownGoodValue), n));
        ssqOffset = add(ssqOffset, multiply(sqr(lastKnownGoodSquare), n));
        data.add(new DataReaderEntry<ValueType, SumType>(false, end - offset, sumOffset, ssqOffset));
        
        lastAddedTime = end - offset;
    }

    private void removeBoundaries(List<ValueType> data) {
        // find boundaries of zeroed intervals
        // because they are means made with partial zeroed data and
        // partially valid data, but they throw the mean and rms
        // off the charts if the channel doesn't hang around 0

        // In other words, mean and rms don't make much sense if part of the
        // data uses zero to signify "no data"

        for (int i = 1; i < data.size(); i++) {
            if (isZero(data.get(i))) {
                data.set(i - 1, zeroValue());
            }
        }
        for (int i = data.size() - 1; i > 1; i--) {
            if (isZero(data.get(i - 1))) {
                data.set(i, zeroValue());
            }
        }
    }

    private double lastWrittenTime = 0, samplingInterval = -1;

    public void write(DataFileWriter wr, DataFileWriter index) throws IOException {
        for (DataReaderEntry<ValueType, SumType> e : data) {
            if (!sameSamplingInterval(e.gpstime)) {
                index.writeDouble(lastWrittenTime);
                samplingInterval = e.gpstime - lastWrittenTime;
                index.writeDouble(samplingInterval);
            }
            lastWrittenTime = e.gpstime;
            wr.writeBoolean(e.valid);
            wr.writeDouble(e.gpstime);
            writeSum(wr, e.sum);
            writeSum(wr, e.ssq);
        }
        data.clear();
        mean.clear();
        rms.clear();
    }

    public void readLastSums(File f) throws IOException {
        if (!f.exists() || f.length() < 50) {
            return;
        }
        RandomAccessFile raf = new RandomAccessFile(f, "r");
        raf.seek(raf.length() - 24);
        lastWrittenTime = EncodingTools.readDouble(raf);
        sumOffset = readSum(raf);
        ssqOffset = readSum(raf);

        raf.seek(raf.length() - 49);
        double secondLastTime = EncodingTools.readDouble(raf);
        lastKnownGoodValue = subtract(sumOffset, readSum(raf));
        lastKnownGoodSquare = subtract(ssqOffset, readSum(raf));

        raf.close();
        samplingInterval = lastWrittenTime - secondLastTime;
        lastAddedTime = lastWrittenTime;
    }

    private boolean readBoolean(RandomAccessFile raf) throws IOException {
        return raf.read() != 0;
    }

    protected abstract SumType readSum(RandomAccessFile raf) throws IOException;

    /**
     * Impose some reasonable resolution to avoid problems created by rounding
     */
    public static final double RESOLUTION = 0.00000001;

    private boolean sameSamplingInterval(double gpstime) {
        double error = gpstime - lastWrittenTime - samplingInterval;
        return Math.abs(error) < RESOLUTION;
    }

    public double[] getTimeRange() {
        return new double[] { data.get(0).gpstime, data.get(data.size() - 1).gpstime };
    }

    protected abstract void writeSum(DataFileWriter wr, SumType sum) throws IOException;

    protected abstract void writeValue(DataFileWriter wr, ValueType value) throws IOException;

    protected abstract void setValue(PreparedStatement ps, int i, ValueType value) throws SQLException;

    protected abstract void setSum(PreparedStatement ps, int i, SumType sum) throws SQLException;

    protected abstract SumType getSum(ResultSet rs, int i) throws SQLException;

    // like really, java should have this stuff, really
    protected abstract SumType multiply(SumType v, int i);

    protected abstract SumType sqr(ValueType v);

    protected abstract SumType widen(ValueType v);

    protected abstract SumType add(SumType s, SumType v);

    protected abstract ValueType subtract(SumType s, SumType v);

    protected abstract SumType zeroSum();

    protected abstract ValueType zeroValue();

    protected abstract ValueType readOne(InputStream is) throws IOException;

    protected abstract boolean isZero(ValueType value);
}