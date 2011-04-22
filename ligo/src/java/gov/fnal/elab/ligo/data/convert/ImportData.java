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
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImportData extends AbstractDataTool {
    
    public static final String LOCKNAME = ".lock";

    private static final int DUMPAHEAD_SIZE = 8;

    private String pathToData, pathToLIGOTools;
    private Set<String> processedFiles;
    private BufferedWriter log;
    private static final int ESTIMATION_RUNS = 200;
    private static final int BATCH_SIZE = 10;
    private String outputPath;
    private PrintWriter error;
    private SortedSet<LIGOFile> files;
    private SortedMap<LIGOFile, Object> doneDumps;

    private long flen;

    private Map<String, DataFileWriter> writers;

    private Map<ChannelName, Double> maxtime;

    private static Object SHUTDOWN_LOCK = new Object();

    private long startTime;
    
    private File lockfile;

    public ImportData(String pathToData, String pathToLIGOTools, String outputPath) {
        this.pathToData = pathToData;
        this.pathToLIGOTools = pathToLIGOTools;
        this.outputPath = outputPath;
        writers = new HashMap<String, DataFileWriter>();
        maxtime = new HashMap<ChannelName, Double>();
        doneDumps = new TreeMap<LIGOFile, Object>();
        lockfile = new File(pathToData + File.separator + LOCKNAME);
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
        lockfile.createNewFile();

        loadChannelInfo(outputPath);
        loadMaxTimes();

        startTime = System.currentTimeMillis();
        for (int i = 0; i < SITES.length; i++) {
            System.out.println("Importing " + SITES[i] + " data");
            files = findFiles(i, pathToData);

            convertAndImport(files);
        }
        System.out.println("Total time: " + formatTime(System.currentTimeMillis() - startTime));
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
                if (lockfile != null) {
                    lockfile.delete();
                }
            }
        });
    }

    private void loadMaxTimes() throws IOException {
        for (ChannelName channel : types.keySet()) {
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

    private Double loadMaxTime(ChannelName channel) throws IOException {
        File f = new File(outputPath + File.separator + channel.uniformName + ".bin");
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
        int totalFileCount = files.size(); 
        LIGOFile f; 

        /* Cannot use the foreach method since we need to remove the element after use for GC reasons */ 
        Iterator<LIGOFile> it = files.iterator();
        while (it.hasNext()) {
        	f = it.next(); 
        	
        	fileCount++; 
        	flen += f.file.length();
        	
        	if (processedFiles.contains(f.file.getName())) {
                System.out.println("Skipping " + f.file.getName());
                continue;
            }

            checkDuration(f.file, f.trend);
            convertFile(f);

            printInfo(fileCount, totalFileCount, files);
            
            it.remove(); 
        }
        log("# done");
    }

    private LinkedList<Long> times = new LinkedList<Long>();
    
    private void printInfo(int fileCount, int totalFileCount, SortedSet<LIGOFile> files) {
    	long now = System.currentTimeMillis();
        times.addLast(now);
        long est;
        if (times.size() > ESTIMATION_RUNS) {
            times.removeFirst();
        }
        long start = times.getFirst();
        est = (now - start) * (totalFileCount - fileCount) / times.size();
        System.out.println(fileCount + "/" + totalFileCount + " (" + fileCount * 100 / totalFileCount + "%, "
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

    private void commit(Map<ChannelName, DataReader<?, ?>> s, File file) throws Exception {
        synchronized (SHUTDOWN_LOCK) {
            Iterator<Map.Entry<ChannelName, DataReader<?, ?>>> i = s.entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry<ChannelName, DataReader<?, ?>> e = i.next();
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
            tmpprefix = getFrameDataDump2Dir(f);
        }
        catch (ToolException e) {
            System.err.println("FrameDataDump2 failed: " + e.getMessage() + ". Skipping file.");
            return;
        }

        Set<ChannelName> dumpedc = getDumpedChannels(tmpprefix);
        Set<ChannelName> dcc = new HashSet<ChannelName>(dumpedc);
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

        final Map<ChannelName, DataReader<?, ?>> s = new HashMap<ChannelName, DataReader<?, ?>>();
        DataReader<?, ?> data = null;
        for (ChannelName channel : dumpedc) {
            try {
            	data = readChannelData(channel, tmpprefix, f, true);
            }
            catch (RuntimeException re) {
            	System.out.println(re.getMessage());
            }

            if (data == null) {
                System.out.println("Skipping channel " + channel);
            }
            else {
            	s.put(channel, data);
            } 
        }
        if (!new File(tmpprefix).delete()) {
            throw new RuntimeException("Could not remove directory " + tmpprefix);
        }

        commit(s, f.file);
    }

    private DataReader<?, ?> readChannelData(ChannelName channel, String tmpprefix, LIGOFile f, boolean delete)
            throws Exception {
        DataReader<?, ?> data = null;
        File rmsbin = new File(tmpprefix + channel.originalName + ".rms.bin");
        File meanbin = new File(tmpprefix + channel.originalName + ".mean.bin");
        File rmstxt = new File(tmpprefix + channel.originalName + ".rms.txt");
        File meantxt = new File(tmpprefix + channel.originalName + ".mean.txt");

        if (!rmstxt.exists()) {
            // check if this file really doesn't have that channel
            Set<ChannelName> channels = getFileChannels(f, pathToLIGOTools);
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

    private boolean rangeCovered(long starttime, int len, ChannelName channel) {
        Double mt = maxtime.get(channel);
        if (mt == null) {
            mt = Double.valueOf(0);
        }
        return starttime <= mt;
    }

    @Override
    protected void setLastSums(ChannelName channel, DataReader<?, ?> reader) throws IOException {
        reader.readLastSums(new File(outputPath + File.separator + channel.uniformName + ".bin"));
    }

    @Override
    protected double getMaxTime(ChannelName channel) {
        return maxtime.get(channel);
    }

    private Set<ChannelName> getDumpedChannels(String tmpprefix) {
        Set<ChannelName> s = new HashSet<ChannelName>();
        File[] fs = new File(tmpprefix).listFiles(new FileFilter() {
            public boolean accept(File pathname) {
                return pathname.getName().endsWith(".rms.txt");
            }
        });
        for (int i = 0; i < fs.length; i++) {
            String name = fs[i].getName();
            s.add(new ChannelName(name.substring(0, name.length() - ".rms.txt".length())));
        }
        return s;
    }

    private static final boolean DUMPAHEAD = true;

    private String getFrameDataDump2Dir(LIGOFile lf) throws Exception {
        if (DUMPAHEAD) {
            synchronized (doneDumps) {
                SortedSet<LIGOFile> tm = files.tailSet(lf);
                Iterator<LIGOFile> i = tm.iterator();
                while (doneDumps.size() < DUMPAHEAD_SIZE && i.hasNext()) {
                    LIGOFile nlf = i.next();
                    if (!doneDumps.containsKey(nlf)) {
                        startDump(nlf);
                    }
                }

                Object result = doneDumps.remove(lf);
                while (result == null) {
                    doneDumps.wait();
                    result = doneDumps.remove(lf);
                }

                if (result instanceof String) {
                    return (String) result;
                }
                else {
                    throw (Exception) result;
                }
            }
        }
        else {
            return runFrameDataDump2(lf.file, null);
        }
    }

    private void startDump(final LIGOFile nlf) {
        doneDumps.put(nlf, null);
        new Thread() {

            @Override
            public void run() {
                Object result;
                try {
                    result = runFrameDataDump2(nlf.file, null);
                }
                catch (Exception e) {
                    result = e;
                }
                synchronized (doneDumps) {
                    doneDumps.put(nlf, result);
                    doneDumps.notifyAll();
                }
            }
        }.start();
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

    private DataFileWriter getWriter(ChannelName channel) throws IOException {
        DataFileWriter w = writers.get(channel.uniformName);
        if (w == null) {
            w = new DataBinaryFileWriter(new File(outputPath + File.separator + channel.uniformName + ".bin"), true);
            writers.put(channel.uniformName, w);
        }
        return w;
    }

    private DataFileWriter getIndexWriter(ChannelName channel) throws IOException {
        DataFileWriter w = writers.get(channel.uniformName + ".index");
        if (w == null) {
            w = new DataBinaryFileWriter(new File(outputPath + File.separator + channel.uniformName + ".index.bin"),
                true);
            writers.put(channel.uniformName + ".index", w);
        }
        return w;
    }

    private void log(String f) throws IOException {
        log.write(f + "\n");
        log.flush();
    }

    public static final Pattern DEBUG_LEVEL = Pattern.compile("\\s*Debug level\\s*:\\s*(\\d)+");
    public static final Pattern ADC_LINE = Pattern
        .compile("\\s*ADC:\\s*(\\w+:\\w+-[\\w\\.\\-]+)\\.mean\\s.*nBits=(\\d+) bias=((?:\\w|\\-|\\.)+) slope=((?:\\w|\\-|\\.)+) units=(.*)");
    public static final Pattern DATA_LINE = Pattern.compile("\\s*Data\\((\\w+)\\).*");

    public Map<ChannelName, String> createDescriptorFiles(String ligoToolsHome, String workdir, File f,
            Set<ChannelName> channels) throws Exception {
        String[] c = new String[] { ligoToolsHome + File.separator + "bin" + File.separator + "FrDump", "-i",
                f.getAbsolutePath(), "-d", "4" };
        Process p = Runtime.getRuntime().exec(c);
        String out = ProcessTools.getOutput("FrDump", p, f);
        BufferedReader br = new BufferedReader(new StringReader(out));
        Matcher level = skipToNotNull(br, DEBUG_LEVEL);
        if (!"4".equals(level.group(1))) {
            throw new RuntimeException("You must run FrDump with the \"-d 4\" option.");
        }

        Set<ChannelName> existing = new HashSet<ChannelName>();

        existing.addAll(channels);

        Map<ChannelName, String> types = new HashMap<ChannelName, String>();
        Matcher adc = skipTo(br, ADC_LINE);
        while (adc != null) {
            Matcher data = skipToNotNull(br, DATA_LINE);
            if (existing.contains(adc.group(1))) {
                adc = skipTo(br, ADC_LINE);
                continue;
            }

            ChannelName channel = new ChannelName(adc.group(1));
            FileWriter fw = new FileWriter(workdir + File.separator + channel.uniformName + ".info");
            fw.write("datatype = " + data.group(1) + "\n");
            fw.write("nbits = " + adc.group(2) + "\n");
            fw.write("bias = " + adc.group(3) + "\n");
            fw.write("slope = " + adc.group(4) + "\n");
            fw.write("units = " + adc.group(5) + "\n");
            fw.close();
            types.put(channel, data.group(1));
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
