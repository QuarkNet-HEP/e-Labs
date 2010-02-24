/*
 * Created on Feb 4, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.ligo.data.convert.AbstractDataTool;
import gov.fnal.elab.ligo.data.convert.ChannelName;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

public abstract class ServiceLIGOFileReader implements LIGOFileReader {
    private static final Map<String, Map<String, Class<? extends ServiceLIGOFileReader>>> CLASSES;
    static {
        CLASSES = new HashMap<String, Map<String, Class<? extends ServiceLIGOFileReader>>>();
        CLASSES.put("mean", new HashMap<String, Class<? extends ServiceLIGOFileReader>>());
        CLASSES.put("rms", new HashMap<String, Class<? extends ServiceLIGOFileReader>>());
        CLASSES.get("mean").put("int", MeanIntLIGOFileReader.class);
        CLASSES.get("mean").put("float", MeanFloatLIGOFileReader.class);
        CLASSES.get("mean").put("double", MeanDoubleLIGOFileReader.class);
        CLASSES.get("rms").put("int", RMSIntLIGOFileReader.class);
        CLASSES.get("rms").put("float", RMSFloatLIGOFileReader.class);
        CLASSES.get("rms").put("double", RMSDoubleLIGOFileReader.class);
    }

    public static LIGOFileReaderFactory getFactory(String serviceURL) {
        return new Factory(serviceURL);
    }

    public static class Factory implements LIGOFileReaderFactory {
        private String serviceURL;

        public Factory(String serviceURL) {
            this.serviceURL = serviceURL;
        }

        public LIGOFileReader newReader(ChannelName name, ChannelProperties props, String type) {
            if (!CLASSES.containsKey(type)) {
                throw new RuntimeException("Unknown reader type: " + type);
            }
            if (!CLASSES.get(type).containsKey(props.getDataType())) {
                throw new RuntimeException("Unknown data type: " + props.getDataType());
            }
            Class<? extends ServiceLIGOFileReader> cls = CLASSES.get(type).get(props.getDataType());
            try {
                ServiceLIGOFileReader r = cls.newInstance();
                r.setChannel(name);
                r.setServiceURL(serviceURL);
                return r;
            }
            catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
    }

    protected final int recordSize, skip;
    protected String serviceURL;
    protected int samplingRateAdjust;
    protected ChannelName channel;
    protected InputStream is;

    protected ServiceLIGOFileReader(int recordSize, int skip) {
        this.recordSize = recordSize;
        this.skip = skip;
    }

    public void setServiceURL(String serviceURL) {
        this.serviceURL = serviceURL;
    }

    protected void setChannel(ChannelName channel) {
        this.samplingRateAdjust = AbstractDataTool.getSamplingRateAdjust(channel);
        this.channel = channel;
    }

    public Record readRecord(long recordIndex) throws IOException {
        return readRecords(new long[] { recordIndex })[0];
    }

    public Record[] readRecords(long[] indices) throws IOException {
        HttpURLConnection c = request(indices);
        is = new BufferedInputStream(c.getInputStream());
        try {
            Record[] records = new Record[indices.length];
            for (int i = 0; i < indices.length; i++) {
                boolean valid = EncodingTools.readBoolean(is);
                double time = EncodingTools.readDouble(is);
                if (time == 0) {
                    records[i] = null;
                }
                else {
                    is.skip(skip);
                    records[i] = new Record(valid, time, readSum());
                    is.skip(8 - skip);
                }
                //System.out.println(records[i]);
            }
            return records;
        }
        finally {
            c.disconnect();
        }
    }
    
    private HttpURLConnection request(long[] indices) throws IOException {
        StringBuilder sb = new StringBuilder();
        sb.append("file=");
        sb.append(URLEncoder.encode(channel.uniformName + ".bin", "UTF-8"));
        sb.append("&");
        sb.append("recsz=");
        sb.append(String.valueOf(recordSize));
        sb.append("&");
        sb.append("records=");
        for (int i = 0; i < indices.length; i++) {
            sb.append(String.valueOf(indices[i]));
            sb.append(' ');
        }
        sb.append("\n");
        byte[] b = sb.toString().getBytes();
        HttpURLConnection conn = (HttpURLConnection) new URL(serviceURL).openConnection();
        conn.setDoOutput(true);
        conn.addRequestProperty("content-type", "application/x-www-form-urlencoded");
        conn.getOutputStream().write(b);
        conn.getOutputStream().close();
        return conn;
    }

    public abstract Double value(Record last, Record rec);

    protected abstract Number readSum() throws IOException;

    protected static abstract class MeanLIGOFileReader extends ServiceLIGOFileReader {
        public MeanLIGOFileReader(int recordSize) {
            super(recordSize, 0);
        }

        @Override
        public Double value(Record last, Record rec) {
            return (rec.sum.doubleValue() - last.sum.doubleValue()) / ((rec.time - last.time) * samplingRateAdjust);
        }
    }

    protected static abstract class RMSLIGOFileReader extends ServiceLIGOFileReader {
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
            return EncodingTools.readLong(is);
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
            return EncodingTools.readDouble(is);
        }
    }

    protected static class MeanDoubleLIGOFileReader extends MeanLIGOFileReader {
        protected MeanDoubleLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(is);
        }
    }

    protected static class RMSIntLIGOFileReader extends RMSLIGOFileReader {
        protected RMSIntLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readLong(is);
        }
    }

    protected static class RMSFloatLIGOFileReader extends RMSLIGOFileReader {
        protected RMSFloatLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(is);
        }
    }

    protected static class RMSDoubleLIGOFileReader extends RMSLIGOFileReader {
        protected RMSDoubleLIGOFileReader() {
            super(25);
        }

        @Override
        public Number readSum() throws IOException {
            return EncodingTools.readDouble(is);
        }
    }
}
