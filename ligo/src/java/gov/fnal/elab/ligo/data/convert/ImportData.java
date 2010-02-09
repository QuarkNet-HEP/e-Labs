/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.RandomAccessFile;
import java.io.StringReader;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImportData extends AbstractDataTool {

    private String pathToData, pathToLIGOTools;
    private Set<String> processedFiles;
    private BufferedWriter log;
    private static final int ESTIMATION_RUNS = 200;
    private static final int BATCH_SIZE = 10;
    private String outputPath;
    private PrintWriter error;

    private long flen;

    private Map<String, DataFileWriter> writers;

    private Map<String, Double> maxtime;

    private static Object SHUTDOWN_LOCK = new Object();

    public ImportData(String pathToData, String pathToLIGOTools, String outputPath) {
        this.pathToData = pathToData;
        this.pathToLIGOTools = pathToLIGOTools;
        this.outputPath = outputPath;
        writers = new HashMap<String, DataFileWriter>();
        maxtime = new HashMap<String, Double>();
    }

    public void run() {
        try {
            run2();
        }
        catch (RuntimeException e) {
            throw e;
        }
        catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    private void run2() throws Exception {
        error = new PrintWriter(new FileWriter("ImportData.errors"));
        addShutdownHook();

        loadChannelInfo(outputPath);
        loadMaxTimes();

        for (int i = 0; i < SITES.length; i++) {
            System.out.println("Importing " + SITES[i] + " data");
            SortedSet<LIGOFile> l = findFiles(i, pathToData);

            convertAndImport(l);
        }
    }

    @Override
    protected void error(String string) {
        super.error(string);
        error.println(string);
        error.flush();
    }

    private void addShutdownHook() {
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                synchronized (SHUTDOWN_LOCK) {
                    System.out.println("Shutting down...");
                }
            }
        });
    }

    private void loadMaxTimes() throws IOException {
        for (String channel : types.keySet()) {
            if (!maxtime.containsKey(channel)) {
                Double time = loadMaxTime(channel);
                if (time == null) {
                    maxtime.put(channel, 0.0);
                }
                else {
                    maxtime.put(channel, time);
                }
            }
        }
    }

    private Double loadMaxTime(String channel) throws IOException {
        File f = new File(outputPath + File.separator + channel + ".bin");
        if (!f.exists() || f.length() < 24) {
            return null;
        }
        RandomAccessFile raf = new RandomAccessFile(f, "r");
        raf.seek(raf.length() - 24);
        Double time = EncodingTools.readDouble(raf);
        raf.close();
        return time;
    }

    private void convertAndImport(SortedSet<LIGOFile> files) throws Exception {

        loadProcessedFiles();
        int fileCount = 0;

        for (LIGOFile f : files) {
            fileCount++;
            flen += f.file.length();

            if (processedFiles.contains(f.file.getName())) {
                System.out.println("Skipping " + f.file.getName());
                continue;
            }

            checkDuration(f.file, f.trend);
            convertFile(f);

            printInfo(fileCount, files);
        }
        log("# done");
    }

    private LinkedList<Long> times = new LinkedList<Long>();

    private void printInfo(int fileCount, SortedSet<LIGOFile> files) {
        long now = System.currentTimeMillis();
        times.addLast(now);
        long est;
        if (times.size() > ESTIMATION_RUNS) {
            times.removeFirst();
        }
        long start = times.getFirst();
        est = (now - start) * (files.size() - fileCount) / times.size();
        System.out.println(fileCount + "/" + files.size() + " (" + fileCount * 100 / files.size() + "%, "
                + formatSize(flen) + ") done; estimated time left: " + formatTime(est));
    }

    private void loadProcessedFiles() throws IOException {
        processedFiles = new HashSet<String>();
        File f = new File(outputPath + File.separator + "ligoimport.files");
        if (f.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(f));

            boolean last = false;
            String line = br.readLine();
            while (line != null) {
                processedFiles.add(line);
                line = br.readLine();
            }
            br.close();
        }
        log = new BufferedWriter(new FileWriter(f, true));
    }

    private void commit(Map<String, DataReader<?, ?>> s, File file) throws Exception {
        synchronized (SHUTDOWN_LOCK) {
            Iterator<Map.Entry<String, DataReader<?, ?>>> i = s.entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry<String, DataReader<?, ?>> e = i.next();
                DataFileWriter wr = getWriter(e.getKey());
                DataFileWriter ir = getIndexWriter(e.getKey());
                e.getValue().write(wr, ir);
                wr.flush();
                ir.flush();
                i.remove();
            }
            
            log(file.getName());
        }
    }

    private void convertFile(final LIGOFile f) throws Exception {
        System.out.print("Processing " + f.file.getName() + "...");
        long time = fileGPSTime(f.file);
        String tmpprefix;
        try {
            tmpprefix = runFrameDataDump2(f.file, null);
        }
        catch (ToolException e) {
            System.err.println("FrameDataDump2 failed: " + e.getMessage() + ". Skipping file.");
            return;
        }

        Set<String> dumpedc = getDumpedChannels(tmpprefix);
        Set<String> dcc = new HashSet<String>(dumpedc);
        dcc.removeAll(types.keySet());
        if (!dcc.isEmpty()) {
            try {
                // new channels
                types.putAll(createDescriptorFiles(pathToLIGOTools, outputPath, f.file, types.keySet()));
            }
            catch (ToolException e) {
                System.err.println("Caught tool exception: " + e.getMessage() + ". Skipping file.");
                return;
            }
            finally {
                loadChannelInfo(outputPath);
                loadMaxTimes();
            }
        }

        final Map<String, DataReader<?, ?>> s = new HashMap<String, DataReader<?, ?>>();
        for (String channel : dumpedc) {
            DataReader<?, ?> data = readChannelData(channel, tmpprefix, f, true);

            if (data == null) {
                System.out.println("Skipping channel " + channel);
                continue;
            }

            s.put(channel, data);
        }
        if (!new File(tmpprefix).delete()) {
            throw new RuntimeException("Could not remove directory " + tmpprefix);
        }

        commit(s, f.file);
    }

    private DataReader<?, ?> readChannelData(String channel, String tmpprefix, LIGOFile f, boolean delete)
            throws Exception {
        DataReader<?, ?> data = null;
        File rmsbin = new File(tmpprefix + channel + ".rms.bin");
        File meanbin = new File(tmpprefix + channel + ".mean.bin");
        File rmstxt = new File(tmpprefix + channel + ".rms.txt");
        File meantxt = new File(tmpprefix + channel + ".mean.txt");

        if (!rmstxt.exists()) {
            // check if this file really doesn't have that channel
            Set<String> channels = getFileChannels(f, pathToLIGOTools);
            if (channels.contains(channel)) {
                throw new RuntimeException("Channel " + channel
                        + " not produced by FrameDataDump, but FrChannels claims it exists in " + f);
            }
            else {
                return null;
            }
        }
        long starttime = fileGPSTime(f.file);
        int len = TREND_FILE_DURATION[f.trend];
        if (!rangeCovered(starttime, len, channel)) {
            data = readFrameDataDump(f.file, rmsbin, rmstxt, meanbin, meantxt, channel);
        }
        if (data != null) {
            // the -0.000001 is there as an implementation of
            // maxtime representing an open interval
            // which is necessary because the data in the db represents
            // an open interval
            maxtime.put(channel, Math.max(starttime + len - 0.0000001, maxtime.get(channel)));
        }
        if (delete) {
            if (!rmsbin.delete())
                throw new RuntimeException("Could not delete " + rmsbin);
            if (!rmstxt.delete())
                throw new RuntimeException("Could not delete " + rmstxt);
            if (!meanbin.delete())
                throw new RuntimeException("Could not delete " + meanbin);
            if (!meantxt.delete())
                throw new RuntimeException("Could not delete " + meantxt);
        }
        return data;
    }

    private boolean rangeCovered(long starttime, int len, String channel) {
        Double mt = maxtime.get(channel);
        if (mt == null) {
            mt = Double.valueOf(0);
        }
        return starttime <= mt;
    }

    @Override
    protected void setLastSums(String channel, DataReader<?, ?> reader) throws IOException {
        reader.readLastSums(new File(outputPath + File.separator + channel + ".bin"));
    }

    @Override
    protected double getMaxTime(String channel) {
        return maxtime.get(channel);
    }

    private Set<String> getDumpedChannels(String tmpprefix) {
        Set<String> s = new HashSet<String>();
        File[] fs = new File(tmpprefix).listFiles(new FileFilter() {
            public boolean accept(File pathname) {
                return pathname.getName().endsWith(".rms.txt");
            }
        });
        for (int i = 0; i < fs.length; i++) {
            String name = fs[i].getName();
            s.add(name.substring(0, name.length() - ".rms.txt".length()));
        }
        return s;
    }

    private String runFrameDataDump2(File f, File dir) throws Exception {
        File tmp = File.createTempFile("ldump", "", dir);
        tmp.delete();
        if (!tmp.mkdirs()) {
            throw new RuntimeException("Cannot create temp dir " + tmp);
        }
        String frameDataDump = pathToLIGOTools + File.separator + "bin" + File.separator + "FrameDataDump2";
        String[] c = new String[] { frameDataDump, "-I" + f.getAbsolutePath(), "-O" + tmp.getAbsolutePath() + "/" };
        Process p = Runtime.getRuntime().exec(c);
        String o = ProcessTools.getOutput("FrameDataDump2", p, f);
        return tmp.getAbsolutePath() + "/";
    }

    private DataFileWriter getWriter(String channel) throws IOException {
        DataFileWriter w = writers.get(channel);
        if (w == null) {
            w = new DataBinaryFileWriter(new File(outputPath + File.separator + channel + ".bin"), true);
            writers.put(channel, w);
        }
        return w;
    }

    private DataFileWriter getIndexWriter(String channel) throws IOException {
        return getWriter(channel + ".index");
    }

    private void log(String f) throws IOException {
        log.write(f + "\n");
        log.flush();
    }

    public static final Pattern DEBUG_LEVEL = Pattern.compile("\\s*Debug level\\s*:\\s*(\\d)+");
    public static final Pattern ADC_LINE = Pattern
        .compile("\\s*ADC:\\s*(\\w+:\\w+-[\\w\\.\\-]+)\\.mean\\s.*nBits=(\\d+) bias=((?:\\w|\\-|\\.)+) slope=((?:\\w|\\-|\\.)+) units=(.*)");
    public static final Pattern DATA_LINE = Pattern.compile("\\s*Data\\((\\w+)\\).*");

    public Map<String, String> createDescriptorFiles(String ligoToolsHome, String workdir, File f, Set<String> channels)
            throws Exception {
        String[] c = new String[] { ligoToolsHome + File.separator + "bin" + File.separator + "FrDump", "-i",
                f.getAbsolutePath(), "-d", "4" };
        Process p = Runtime.getRuntime().exec(c);
        String out = ProcessTools.getOutput("FrDump", p, f);
        BufferedReader br = new BufferedReader(new StringReader(out));
        Matcher level = skipToNotNull(br, DEBUG_LEVEL);
        if (!"4".equals(level.group(1))) {
            throw new RuntimeException("You must run FrDump with the \"-d 4\" option.");
        }

        Set<String> existing = new HashSet<String>();

        existing.addAll(channels);

        Map<String, String> types = new HashMap<String, String>();
        Matcher adc = skipTo(br, ADC_LINE);
        while (adc != null) {
            Matcher data = skipToNotNull(br, DATA_LINE);
            if (existing.contains(adc.group(1))) {
                adc = skipTo(br, ADC_LINE);
                continue;
            }

            FileWriter fw = new FileWriter(workdir + File.separator + adc.group(1) + ".info");
            fw.write("datatype = " + data.group(1) + "\n");
            fw.write("nbits = " + adc.group(2) + "\n");
            fw.write("bias = " + adc.group(3) + "\n");
            fw.write("slope = " + adc.group(4) + "\n");
            fw.write("units = " + adc.group(5) + "\n");
            fw.close();
            types.put(adc.group(1), data.group(1));
            adc = skipTo(br, ADC_LINE);
        }
        br.close();
        return types;
    }

    private Matcher skipToNotNull(BufferedReader br, Pattern p) throws IOException {
        Matcher result = skipTo(br, p);
        if (result == null) {
            throw new RuntimeException("Search string not found in FrDump output: " + p);
        }
        else {
            return result;
        }
    }

    private Matcher skipTo(BufferedReader br, Pattern p) throws IOException {
        String line = br.readLine();
        while (line != null) {
            Matcher m = p.matcher(line);
            if (m.matches()) {
                return m;
            }
            line = br.readLine();
        }
        return null;
    }

    public static void main(String[] args) {
        if (args.length < 3) {
            help();
            error("Missing argument(s)", 1);
        }
        try {
            new ImportData(args[0], args[1], args[2]).run();
        }
        catch (NullPointerException e) {
            e.printStackTrace();
            System.exit(3);
        }
        catch (Exception e) {
            e.printStackTrace();
            error(e.getMessage(), 2);
        }
    }

    public static void error(String msg, int ec) {
        System.err.println(msg);
        System.exit(ec);
    }

    public static void help() {
        System.err.println("Usage: ImportData <pathToData> <pathToLigoTools> <outputDir>");
        System.err.println("  where:");
        System.err.println("    <pathToData> path to data in standard ligo trend directories");
        System.err.println("    <pathToLigoTools> path to LIGO tools (in particular FrDump and FrameDataDump2)");
        System.err.println("    <outputDir> a directory to hold data and log state");
    }
}
