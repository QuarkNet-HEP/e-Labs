/*
 * Created on Feb 4, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.ligo.data.convert.AbstractDataTool;
import gov.fnal.elab.ligo.data.convert.ChannelName;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.HashMap;
import java.util.Map;

public abstract class LIGOFileReader {
    private static final Map<String, Map<String, Class<? extends LIGOFileReader>>> CLASSES;
    static {
        CLASSES = new HashMap<String, Map<String, Class<? extends LIGOFileReader>>>();
        CLASSES.put("mean", new HashMap<String, Class<? extends LIGOFileReader>>());
        CLASSES.put("rms", new HashMap<String, Class<? extends LIGOFileReader>>());
        CLASSES.get("mean").put("int", MeanIntLIGOFileReader.class);
        CLASSES.get("mean").put("float", MeanFloatLIGOFileReader.class);
        CLASSES.get("mean").put("double", MeanDoubleLIGOFileReader.class);
        CLASSES.get("rms").put("int", RMSIntLIGOFileReader.class);
        CLASSES.get("rms").put("float", RMSFloatLIGOFileReader.class);
        CLASSES.get("rms").put("double", RMSDoubleLIGOFileReader.class);
    }

    public static LIGOFileReader instance(ChannelName channel, ChannelProperties props, String type, RandomAccessFile f) {
        if (!CLASSES.containsKey(type)) {
            throw new RuntimeException("Unknown reader type: " + type);
        }
        if (!CLASSES.get(type).containsKey(props.getDataType())) {
            throw new RuntimeException("Unknown data type: " + props.getDataType());
        }
        Class<? extends LIGOFileReader> cls = CLASSES.get(type).get(props.getDataType());
        try {
            LIGOFileReader r = cls.newInstance();
            r.setChannel(channel);
            r.setFile(f);
            return r;
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    protected final int recordSize, skip;
    protected RandomAccessFile f;
    protected int samplingRateAdjust;

    protected LIGOFileReader(int recordSize, int skip) {
        this.recordSize = recordSize;
        this.skip = skip;
    }

    protected void setFile(RandomAccessFile f) {
        this.f = f;
    }

    protected void setChannel(ChannelName channel) {
        this.samplingRateAdjust = AbstractDataTool.getSamplingRateAdjust(channel);
    }

    public Record readRecord(long recordIndex) throws IOException {
        synchronized (f) {
            long pos = recordIndex * recordSize;
            if (pos < 0 || pos > f.length()) {
                return null;
            }
            f.seek(recordIndex * recordSize);
            boolean valid = EncodingTools.readBoolean(f);
            double time = EncodingTools.readDouble(f);
            f.skipBytes(skip);
            return new Record(valid, time, readSum());
        }
    }

    public Record[] readRecords(long[] indices) throws IOException {
        synchronized (f) {
            Record[] records = new Record[indices.length];
            for (int i = 0; i < indices.length; i++) {
                records[i] = readRecord(indices[i]);
            }
            return records;
        }
    }

    public abstract Double value(Record last, Record rec);

    protected abstract Number readSum() throws IOException;

    protected static abstract class MeanLIGOFileReader extends LIGOFileReader {
        public MeanLIGOFileReader(int recordSize) {
            super(recordSize, 0);
        }

        @Override
        public Double value(Record last, Record rec) {
            return (rec.sum.doubleValue() - last.sum.doubleValue()) / ((rec.time - last.time) * samplingRateAdjust);
        }
    }

    protected static abstract class RMSLIGOFileReader extends LIGOFileReader {
        public RMSLIGOFileReader(int recordSize) {
            super(recordSize, 8);
        }

        @Override
        public Double value(Record last, Record rec) {
            return Math.sqrt((rec.sum.doubleValue() - last.sum.doubleValue())
                    / ((rec.time - last.time) * samplingRateAdjust));
        }
    }

    protected static class MeanIntLIGOFileReader extends MeanLIGOFileReader {
        protected MeanIntLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readLong(f);
        }

        @Override
        public Double value(Record last, Record rec) {
            return (rec.sum.longValue() - last.sum.longValue()) / (rec.time - last.time);
        }
    }

    protected static class MeanFloatLIGOFileReader extends MeanLIGOFileReader {
        protected MeanFloatLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(f);
        }
    }

    protected static class MeanDoubleLIGOFileReader extends MeanLIGOFileReader {
        protected MeanDoubleLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(f);
        }
    }

    protected static class RMSIntLIGOFileReader extends RMSLIGOFileReader {
        protected RMSIntLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readLong(f);
        }
    }

    protected static class RMSFloatLIGOFileReader extends RMSLIGOFileReader {
        protected RMSFloatLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(f);
        }
    }

    protected static class RMSDoubleLIGOFileReader extends RMSLIGOFileReader {
        protected RMSDoubleLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(f);
        }
    }
}
