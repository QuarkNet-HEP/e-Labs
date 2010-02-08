/*
 * Created on Jan 29, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.expression.data.engine.DataBackendException;
import gov.fnal.elab.expression.data.engine.DataEngine;
import gov.fnal.elab.expression.data.engine.DataPath;
import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.Options;
import gov.fnal.elab.expression.data.engine.Range;

import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LIGOFileDataEngine implements DataEngine {

    private String dir;
    private Map<String, ChannelProperties> channels;
    private Map<String, ChannelIndex> indexes;
    private Map<String, RandomAccessFile> files;
    private List<DataPath> paths;

    public LIGOFileDataEngine(String dir) throws IOException {
        this.dir = dir;
        loadChannelInfo();
        loadChannelIndexes();
        files = new HashMap<String, RandomAccessFile>();
    }

    private void loadChannelIndexes() throws IOException {
        indexes = new HashMap<String, ChannelIndex>();
        for (String channel : channels.keySet()) {
            indexes.put(channel, new ChannelIndex(new File(dir + File.separator + channel + ".index.bin")));
        }
    }

    private void loadChannelInfo() throws IOException {
        File[] info = new File(dir).listFiles(new FileFilter() {
            public boolean accept(File pathname) {
                return pathname.getName().endsWith(".info");
            }
        });
        channels = new HashMap<String, ChannelProperties>();
        for (File f : info) {
            String channel = f.getName().substring(0, f.getName().length() - ".info".length());
            channels.put(channel, new ChannelProperties(f));
        }
    }

    public DataSet get(DataPath path, Range range, Options options) throws DataBackendException {
        int ip = path.getName().lastIndexOf('.');
        String channel = path.getName().substring(0, ip);
        String type = path.getName().substring(ip + 1);
        ChannelIndex index = indexes.get(channel);
        ChannelProperties props = channels.get(channel);
        Double[] values = new Double[options.getSamples()];
        double min = Double.MAX_VALUE;
        double max = Double.MIN_VALUE;

        try {
            LIGOFileReader rf = LIGOFileReader.instance(props, type, getFile(channel));
            Record last = rf.readRecord(index.getRecordIndex(range.getStart().doubleValue()) - 1);
            boolean lastInvalid = false;
            if (last == null) {
                last = new Record(false, 0, 0);
                lastInvalid = true;
            }
            double lastvalue = 0;
            
            for (int i = 0; i < options.getSamples(); i++) {
                double time = range.getStart().doubleValue() + i * range.getRange().doubleValue()
                        / options.getSamples();
                long recordIndex = index.getRecordIndex(time);

                Record rec = rf.readRecord(recordIndex);
                if (rec == null) {
                    values[i] = Double.NaN;
                    continue;
                }

                if (rec.time == last.time) {
                    // I'm not sure this is strictly correct
                    values[i] = lastvalue;
                }
                else {
                    values[i] = rf.value(last, rec);
                }
                if (lastInvalid) {
                    values[i] = Double.NaN;
                    lastInvalid = false;
                }
                if (!rec.valid) {
                    values[i] = Double.NaN;
                    lastInvalid = true;
                }
                else {
                    // last should be the last valid record
                    last = rec;
                }
                
                lastvalue = values[i];
                
                values[i] = values[i].doubleValue() * props.getSlope() + props.getBias();
                if (values[i] > max) {
                    max = values[i];
                }
                if (values[i] < min) {
                    min = values[i];
                }
            }
            return new NumberArrayDataSet(path, range, new Range(min, max), values, props.getUnits());
        }
        catch (IOException e) {
            throw new DataBackendException(e);
        }
    }

    private RandomAccessFile getFile(String channel) throws FileNotFoundException {
        synchronized (files) {
            RandomAccessFile f = files.get(channel);
            if (f == null) {
                f = new RandomAccessFile(dir + File.separator + channel + ".bin", "r");
                files.put(channel, f);
            }
            return f;
        }
    }

    public List<DataPath> getPaths() throws DataBackendException {
        if (paths == null) {
            paths = new ArrayList<DataPath>();
            for (Map.Entry<String, ChannelIndex> e : indexes.entrySet()) {
                Range range = getRange(e.getKey());
                paths.add(new DataPath(e.getKey() + ".mean", range));
                paths.add(new DataPath(e.getKey() + ".rms", range));
            }
        }
        return paths;
    }

    private Range getRange(String channel) throws DataBackendException {
        try {
            RandomAccessFile raf = new RandomAccessFile(dir + File.separator + channel + ".bin", "r");
            try {
                if (raf.length() == 0) {
                    return new Range(0, 0);
                }
                raf.skipBytes(1);
                double start = EncodingTools.readDouble(raf);
                raf.seek(raf.length() - 24);
                double end = EncodingTools.readDouble(raf);
                return new Range(start, end);
            }
            finally {
                raf.close();
            }
        }
        catch (IOException e) {
            throw new DataBackendException(e);
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
            LIGOFileDataEngine eng = new LIGOFileDataEngine("/mnt/ubuntu/tmp/test");
            time("new");
            List<DataPath> dps = eng.getPaths();
            time("getpaths");
            for (int i = 0; i < 1; i++) {
                eng.get(new DataPath("H0:PEM-MY_SEISZ.rms"), new Range(915199610, 915223854), new Options()
                    .setSamples(800));
                time("get");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
