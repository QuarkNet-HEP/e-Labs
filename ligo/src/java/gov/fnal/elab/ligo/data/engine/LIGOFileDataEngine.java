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
import gov.fnal.elab.ligo.data.convert.ChannelName;
import gov.fnal.elab.ligo.data.convert.ImportData;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class LIGOFileDataEngine implements DataEngine {
    private String dir;
    private Map<String, ChannelProperties> channels;
    private Map<String, ChannelIndex> indexes;
    private Map<String, RandomAccessFile> files;
    private List<DataPath> paths;
    private Map<String, ChannelName> names;
    private Map<String, Long> fileTime;
    private ModificationChecker modcheck;
    private ReadWriteLock lock;

    public LIGOFileDataEngine(String dir) throws IOException {
        this.dir = dir;
        fileTime = new HashMap<String, Long>();
        lock = new ReentrantReadWriteLock();
        reload();
        modcheck = new ModificationChecker(this);
    }

    public void reload() throws IOException {
        lock.writeLock().lock();
        try {
            loadChannelInfo();
            loadChannelIndexes();
            if (files == null) {
                files = new HashMap<String, RandomAccessFile>();
            }
            else {
                files.clear();
            }
            paths = null;
        }
        finally {
            lock.writeLock().unlock();
        }
    }

    private void loadChannelIndexes() throws IOException {
        indexes = new HashMap<String, ChannelIndex>();
        for (String channel : channels.keySet()) {
            indexes.put(channel, new ChannelIndex(new File(dir + File.separator + channel + ".index.bin")));
        }
    }

    private void loadChannelInfo() throws IOException {
        File d = new File(dir);
        if (!d.exists()) {
            throw new EngineException("The specified data directory (" + d.getAbsolutePath() + ") does not exist.");
        }
        File[] info = new File(dir).listFiles(new InfoFileFilter());

        if (info == null) {
            throw new EngineException("No data found in the specified directory (" + d.getAbsolutePath() + ")");
        }
        channels = new HashMap<String, ChannelProperties>();
        names = new HashMap<String, ChannelName>();
        for (File f : info) {
            String channel = f.getName().substring(0, f.getName().length() - ".info".length());
            channels.put(channel, new ChannelProperties(f));
            names.put(channel, new ChannelName(channel));
        }
    }

    public static final NumberFormat NF = new DecimalFormat("0.0000000");

    public DataSet get(DataPath path, Range range, Options options) throws DataBackendException {
        lock.readLock().lock();
        try {
            int ip = path.getName().lastIndexOf('.');
            String channel = path.getName().substring(0, ip);
            String type = path.getName().substring(ip + 1);
            ChannelIndex index = indexes.get(channel);
            if (index == null) {
                throw new DataBackendException("Invalid data path: " + path);
            }
            ChannelProperties props = channels.get(channel);
            Double[] values = new Double[options.getSamples()];
            double min = Double.MAX_VALUE;
            double max = Double.MIN_VALUE;

            long[] indices = new long[options.getSamples() + 1];
            indices[0] = index.getRecordIndex(range.getStart().doubleValue()) - 1;
            for (int i = 0; i < options.getSamples(); i++) {
                double time = range.getStart().doubleValue() + i * range.getRange().doubleValue()
                        / options.getSamples();
                indices[i + 1] = index.getRecordIndex(time);
            }

            try {
                LIGOFileReader rf = LIGOFileReader.instance(getName(channel), props, type, getFile(channel));
                Record[] records = rf.readRecords(indices);
                Record last = records[0];
                boolean lastInvalid = false;
                if (last == null) {
                    last = new Record(false, 0, 0);
                    lastInvalid = true;
                }
                double lastvalue = 0;

                for (int i = 0; i < options.getSamples(); i++) {
                    Record rec = records[i + 1];
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
        finally {
            lock.readLock().unlock();
        }
    }

    private ChannelName getName(String channel) {
        return names.get(channel);
    }

    private RandomAccessFile getFile(String channel) throws IOException {
        synchronized (files) {
            RandomAccessFile f = files.get(channel);
            if (f == null) {
                f = new RandomAccessFile(dir + File.separator + channel + ".bin", "r");
                files.put(channel, f);
            }
            return f;
        }
    }

    private long fileTime(String channel) {
        return new File(dir + File.separator + channel + ".bin").lastModified();
    }

    private long storedFileTime(String channel) {
        Long l = fileTime.get(channel);
        if (l == null) {
            return 0;
        }
        else {
            return l.longValue();
        }
    }

    public List<DataPath> getPaths() throws DataBackendException {
        lock.readLock().lock();
        try {
            if (paths == null) {
                paths = new ArrayList<DataPath>();
                for (Map.Entry<String, ChannelIndex> e : indexes.entrySet()) {
                    Range range = getRange(e.getKey());
                    if (!e.getKey().endsWith("Hz")) {
                        // the bandwidth filtered channels only have rms info
                        // i.e. rms = mean = min = max
                        paths.add(new DataPath(e.getKey() + ".mean", range));
                    }
                    paths.add(new DataPath(e.getKey() + ".rms", range));
                }
            }
            return paths;
        }
        finally {
            lock.readLock().unlock();
        }
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
                File fl = new File(dir + File.separator + ImportData.LOCKNAME);
                if (fl.exists()) {
                    throw new EngineException("Data is being updated");
                }
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

    private static ThreadLocal<Long> time = new ThreadLocal<Long>();

    private static void time(String s) {
        long now = System.currentTimeMillis();
        if (time.get() != null) {
            System.out.println(s + " (" + (now - time.get()) + "ms)");
        }
        time.set(now);
    }

    private static final int NTHREADS = 10;

    public static void main(String[] args) {
        try {
            time("");
            final LIGOFileDataEngine eng = new LIGOFileDataEngine("/mnt/ubuntu/tmp/test");
            time("new");
            List<DataPath> dps = eng.getPaths();
            time("getpaths");
            Thread[] threads = new Thread[NTHREADS];
            for (int j = 0; j < NTHREADS; j++) {
                final int k = j;
                threads[j] = new Thread() {
                    public void run() {
                        try {
                            for (int i = 0; i < 20; i++) {
                                eng.get(new DataPath("H0:PEM-MX_TILTT.mean"), new Range(915109200 + (int) (Math
                                    .random() * 15109200), 948645719 - (int) (Math.random() * 15109200)), new Options()
                                    .setSamples(800));
                                time("get");
                            }
                        }
                        catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                };
                threads[j].start();
            }

            for (int j = 0; j < NTHREADS; j++) {
                threads[j].join();
            }
            time("total");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String getDataDirectory() {
        return dir;
    }
}
