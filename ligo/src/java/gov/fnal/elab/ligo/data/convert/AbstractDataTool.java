/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.ChannelProperties;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class AbstractDataTool {
    public static final boolean FILE_ONLY = true;
    
    public static final int SITE_LHO = 0;
    public static final int SITE_LLO = 1;
    
    public static final int SECOND_TREND = 0;
    public static final int MINUTE_TREND = 1;

    public static final String[] SITES = new String[] { "LHO", "LLO" };
    public static final String[] TRENDS = new String[] { "second-trend", "minute-trend" };
    public static final int[] TREND_FILE_DURATION = new int[] { 60, 3600 };
    public static final String LIGO_FILE_EXTENSION = ".gwf";

    public static final Set<String> DIR_NAME_START = new HashSet<String>() {
        {
            add("L-");
            add("H-");
        }
    };

    public static final Map<String, Integer> TYPE_SIZES = new HashMap<String, Integer>() {
        {
            put("double", 8);
            put("int", 4);
            put("float", 4);
        }
    };
    
    public static final Map<String, Integer> SAMPLING_RATE_ADJUST = new HashMap<String, Integer>() {
        {
            put("EARTHQUAKE", 16);
            put("RAIN", 16);
            put("WDIR", 16);
            put("WIND", 16);
            put("WINDMPH", 16);
            
            put("MAGX", 2048);
            put("MAGY", 2048);
            put("MAGZ", 2048);
            put("MAG1X", 2048);
            put("MAG1Y", 2048);
            put("MAG1Z", 2048);
            
            put("TILTX", 256);
            put("TILTY", 256);
            put("TILTT", 256);
            
            put("SEISX", 256);
            put("SEISY", 256);
            put("SEISZ", 256);
            
            put("SEIS2X", 256);
            put("SEIS2Y", 256);
            put("SEIS2Z", 256);
            
            //there is no raw data for these, so 1 is as good as any value
            put("SEISX_0.03_0.1Hz", 1);
            put("SEISY_0.03_0.1Hz", 1);
            put("SEISZ_0.03_0.1Hz", 1);
            
            put("SEISX_0.1_0.3Hz", 1);
            put("SEISY_0.1_0.3Hz", 1);
            put("SEISZ_0.1_0.3Hz", 1);
            
            put("SEISX_0.3_1Hz", 1);
            put("SEISY_0.3_1Hz", 1);
            put("SEISZ_0.3_1Hz", 1);
            
            put("SEISX_1_3Hz", 1);
            put("SEISY_1_3Hz", 1);
            put("SEISZ_1_3Hz", 1);
            
            put("SEISX_3_10Hz", 1);
            put("SEISY_3_10Hz", 1);
            put("SEISZ_3_10Hz", 1);
            
            put("SEISX_10_30Hz", 1);
            put("SEISY_10_30Hz", 1);
            put("SEISZ_10_30Hz", 1);
        }
    };

    protected Map<ChannelName, String> types;
    protected Map<ChannelName, DataReader<?, ?>> readers;

    protected AbstractDataTool() {
    }

    protected void loadChannelInfo(String pathToData) throws IOException {
        types = new HashMap<ChannelName, String>();
        File[] infos = new File(pathToData).listFiles(new FileFilter() {
            public boolean accept(File pathname) {
                return pathname.getName().endsWith(".info");
            }
        });
        for (File info : infos) {
            ChannelProperties cp = new ChannelProperties(info);
            String fn = info.getName();
            types.put(new ChannelName(fn.substring(0, fn.length() - ".info".length())), cp.getDataType());
        }
    }

    protected SortedSet<LIGOFile> findFiles(int site, String pathToData) {
        System.out.print("Searching for files... ");
        SortedSet<LIGOFile> s = new TreeSet<LIGOFile>();
        for (int trend = 0; trend < TRENDS.length; trend++) {
            File trenddir = new File(pathToData + File.separator + TRENDS[trend] + File.separator + SITES[site]);
            File[] dirs = trenddir.listFiles(new FileFilter() {
                public boolean accept(File pathname) {
                    return DIR_NAME_START.contains(pathname.getName().substring(0, 2));
                }
            });
            if (dirs == null || dirs.length == 0) {
                System.out.println("No data for " + SITES[site] + ", " + TRENDS[trend] + ". Skipping");
                continue;
            }
            for (int d = 0; d < dirs.length; d++) {
                File[] gwfs = dirs[d].listFiles(new FileFilter() {
                    public boolean accept(File pathname) {
                        return pathname.getName().endsWith(LIGO_FILE_EXTENSION);
                    }
                });
                for (int i = 0; i < gwfs.length; i++) {
                    s.add(new LIGOFile(site, trend, gwfs[i]));
                }
            }
        }
        System.out.println(s.size() + " found");
        return s;
    }

    protected void checkDuration(File file, int trend) {
        if (!file.getName().endsWith("-" + TREND_FILE_DURATION[trend] + ".gwf")) {
            throw new RuntimeException("File duration does not match expected (" + TREND_FILE_DURATION[trend]
                    + ") for " + file + ". Bailing out.");
        }
    }

    public static final NumberFormat NF = new DecimalFormat("0.000");

    protected String formatSize(long l) {
        if (l < 1000) {
            return l + " bytes";
        }
        else if (l < 1000000) {
            return NF.format((double) l / 1024) + " KB";
        }
        else if (l < 1000000000) {
            return NF.format((double) l / 1024 / 1024) + " MB";
        }
        else {
            return NF.format((double) l / 1024 / 1024 / 1024) + " GB";
        }
    }

    protected String formatTime(long est) {
        if (est == -1) {
            return "unknown";
        }
        long ms = est % 1000;
        est /= 1000;
        long sec = est % 60;
        est /= 60;
        long min = est % 60;
        est /= 60;
        long hrs = est % 24;
        est /= 24;
        long days = est;
        StringBuilder sb = new StringBuilder();
        if (days > 0) {
            sb.append(days);
            sb.append(" day");
            if (days > 1) {
                sb.append('s');
            }
            sb.append(" and ");
        }
        sb.append(leadingZero(hrs));
        sb.append(hrs);
        sb.append(':');
        sb.append(leadingZero(min));
        sb.append(min);
        sb.append(':');
        sb.append(leadingZero(sec));
        sb.append(sec);
        return sb.toString();
    }

    private String leadingZero(long x) {
        if (x < 10) {
            return "0";
        }
        else {
            return "";
        }
    }

    protected Set<ChannelName> getFileChannels(LIGOFile f, String pathToLIGOTools) throws Exception {
        String frChannels = pathToLIGOTools + File.separator + "bin" + File.separator + "FrChannels";
        String[] cmd = new String[] { frChannels, f.file.getAbsolutePath() };
        Process p = Runtime.getRuntime().exec(cmd);
        String out = ProcessTools.getOutput(p.getInputStream());
        String err = ProcessTools.getOutput(p.getErrorStream());
        int ec = p.waitFor();
        if (ec != 0) {
            throw new RuntimeException("FrChannels on " + f + " failed: " + err);
        }
        BufferedReader br = new BufferedReader(new StringReader(out));
        Set<ChannelName> l = new HashSet<ChannelName>();
        String line = br.readLine();
        while (line != null) {
            String[] s1 = line.split("\\s+");
            int i = s1[0].lastIndexOf('.');
            l.add(new ChannelName(s1[0].substring(0, i)));
            line = br.readLine();
        }
        return l;
    }

    public static final Pattern RE_FILE_GPS_TIME = Pattern.compile("[H|L]-[T|M]-(\\d+)-\\d+.gwf");

    protected long fileGPSTime(File file) {
        Matcher m = RE_FILE_GPS_TIME.matcher(file.getName());
        if (m.matches()) {
            return Long.parseLong(m.group(1));
        }
        else {
            throw new RuntimeException("File does not match expected pattern: " + file);
        }
    }

    private File lastBrokenFile = null;

    protected DataReader<?, ?> readFrameDataDump(File f, File rmsbin, File rmstxt, File meanbin, File meantxt,
            ChannelName channel) throws IOException {
        String[] info = checkFrDumpOutput(read(rmstxt), types.get(channel), TYPE_SIZES.get(types.get(channel)));
        checkFrDumpOutput(read(meantxt), types.get(channel), TYPE_SIZES.get(types.get(channel)));
        double starttime = Double.parseDouble(info[0]);
        if (starttime <= getMaxTime(channel)) {
            long filetime = fileGPSTime(f);
            if (starttime < filetime) {
                if (f != lastBrokenFile) {
                    error("Broken file " + f + ". File name suggests a start time of " + filetime
                            + " and FrDump says it's " + starttime + ". Assuming file time is correct.");
                }
                starttime = filetime;
                lastBrokenFile = f;
            }
            else {
                throw new RuntimeException(f + " time out of range. Dump reports " + starttime + " which is <= "
                        + getMaxTime(channel));
            }
        }
        int nsamples = Integer.parseInt(info[1]);
        double lentime = Double.parseDouble(info[2]);

        DataReader<?, ?> dp = getReader(channel, types.get(channel), this);
        readData(dp, rmsbin, meanbin);

        if (nsamples != dp.size()) {
            throw new RuntimeException("Size mismatch. Expected " + nsamples + " words, but only " + dp.size()
                    + " were found in the data file");
        }

        if (channel.equals("H0:PEM-VAULT_SEISZ")) {
            System.out.println("");
        }

        dp.process(starttime, lentime, getSamplingRateAdjust(channel));

        return dp;
    }

    public static int getSamplingRateAdjust(ChannelName channel) {
        Integer i = SAMPLING_RATE_ADJUST.get(channel.getSubsystem());
        if (i == null) {
            throw new RuntimeException("No sampling rate adjustement for subsystem " + channel.getSubsystem());
        }
        return i;
    }

    private DataReader<?, ?> getReader(ChannelName channel, String string, AbstractDataTool abstractDataTool)
            throws IOException {
        if (readers == null) {
            readers = new HashMap<ChannelName, DataReader<?, ?>>();
        }
        DataReader<?, ?> reader = readers.get(channel);
        if (reader == null) {
            reader = DataReader.instance(types.get(channel), this);
            setLastSums(channel, reader);
            readers.put(channel, reader);
        }
        return reader;
    }

    protected void setLastSums(ChannelName channel, DataReader<?, ?> reader) throws IOException {

    }

    protected void error(String string) {
        System.err.println(string);
    }

    protected double getMaxTime(ChannelName channel) {
        return 0;
    }

    protected void readData(DataReader<?, ?> dp, File rms, File mean) throws IOException {
        InputStream isrms = new BufferedInputStream(new FileInputStream(rms));
        InputStream ismean = new BufferedInputStream(new FileInputStream(mean));

        while (dp.readOne(isrms, ismean)) {
            // noop
        }

        isrms.close();
        ismean.close();
    }

    private String read(File f) throws IOException {
        BufferedReader fw = new BufferedReader(new FileReader(f));
        try {
            StringBuilder sb = new StringBuilder();
            String line = fw.readLine();
            while (line != null) {
                sb.append(line);
                sb.append('\n');
                line = fw.readLine();
            }
            return sb.toString();
        }
        finally {
            fw.close();
        }
    }

    public static final Pattern FRD_FRAME_TIME = Pattern.compile("The first frame begins at GPS time ([0-9\\.]+)");
    public static final Pattern FRD_SAMPLES_READ = Pattern
        .compile("([0-9]+) samples \\(([0-9\\.]+) s\\) successfully written");
    public static final Pattern FRD_TYPE = Pattern.compile("The binary output file \\(.*\\) is of type '(\\w+)'");
    public static final Pattern FRD_WORDLEN = Pattern.compile("The word length is ([0-9]+) bytes");
    public static final Pattern[] FRD_PATTERNS = new Pattern[] { FRD_FRAME_TIME, FRD_SAMPLES_READ, FRD_TYPE,
            FRD_WORDLEN };

    protected String[] checkFrDumpOutput(String out, String expectedType, int expectedWordSize) throws IOException {
        // 0: gpstime, 1: nsamples, 2: seconds, 3: type, 4: wordsize
        String[] info = new String[5];
        int patternIndex = 0, infoIndex = 0;
        try {
            BufferedReader br = new BufferedReader(new StringReader(out));
            try {
                String line = br.readLine();
                while (line != null) {
                    Matcher m = FRD_PATTERNS[patternIndex].matcher(line);
                    if (m.matches()) {
                        for (int i = 0; i < m.groupCount(); i++) {
                            info[infoIndex++] = m.group(i + 1);
                        }
                        patternIndex++;
                        if (patternIndex == FRD_PATTERNS.length) {
                            if (!expectedType.equals(info[3])) {
                                throw new RuntimeException("FrameDataDump reports unexpected data type (" + info[3]
                                        + "). Expected " + expectedType);
                            }
                            if (expectedWordSize != Integer.parseInt(info[4])) {
                                throw new RuntimeException("FrameDataDump reports unexpected word size (" + info[4]
                                        + "). Expected " + expectedWordSize);
                            }
                            return info;
                        }
                    }
                    line = br.readLine();
                }
            }
            finally {
                br.close();
            }
            throw new BrokenDataException("Invalid FrameDataDump output: " + out);
        }
        catch (FileNotFoundException e) {
            throw new BrokenDataException("File not found", e);
        }
    }

}
