/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImportData implements Runnable {

    /**
     * Used to reconstruct the sums of squares from a RMS value
     */
    public static final int RAW_SAMPLES_PER_SECOND = 250;
    public static final double END_OF_TIME = Double.MAX_VALUE;

    public static final String LIGO_FILE_EXTENSION = ".gwf";

    public static final String[] SITES = new String[] { "LHO", "LLO" };
    public static final int SECOND_TREND = 0;
    public static final int MINUTE_TREND = 0;
    public static final String[] TRENDS = new String[] { "second-trend", "minute-trend" };
    public static final int[] TREND_FILE_DURATION = new int[] { 60, 3600 };
    public static final Map<String, Integer> TYPE_SIZES = new HashMap<String, Integer>() {
        {
            put("double", 8);
            put("int", 4);
            put("float", 4);
        }
    };

    public static final Set<String> DIR_NAME_START = new HashSet<String>() {
        {
            add("L-");
            add("H-");
        }
    };

    private String pathToData, pathToLigoTools;
    private String dburl, dbuser, dbpass;
    private Connection conn;
    private Map<String, String> tables;
    private Map<String, String> types;

    // start and end times of covered time intervals
    private SortedSet<Long> starts, ends;

    public ImportData(String pathToData, String pathToLigoTools, String dburl, String dbuser, String dbpass) {
        this.pathToData = pathToData;
        this.pathToLigoTools = pathToLigoTools;
        this.dburl = dburl;
        this.dbuser = dbuser;
        this.dbpass = dbpass;
        starts = new TreeSet<Long>();
        ends = new TreeSet<Long>();
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
        connectToDb();
        loadChannelInfo();
        for (int i = 0; i < SITES.length; i++) {
            System.out.println("Importing " + SITES[i] + " data");
            SortedSet<LIGOFile> l = findFiles(i);
            importFiles(l);
        }
    }

    private void loadChannelInfo() throws SQLException {
        tables = new HashMap<String, String>();
        types = new HashMap<String, String>();
        Statement s = conn.createStatement();
        try {
            ResultSet rs = s.executeQuery("SELECT name, tablename, datatype FROM channels");
            while (rs.next()) {
                tables.put(rs.getString(1), rs.getString(2));
                types.put(rs.getString(1), rs.getString(3));
            }
        }
        finally {
            s.close();
        }
    }

    private SortedSet<LIGOFile> findFiles(int site) {
        System.out.print("Searchin for files... ");
        SortedSet<LIGOFile> s = new TreeSet<LIGOFile>();
        for (int trend = 0; trend < TRENDS.length; trend++) {
            File trenddir = new File(pathToData + File.separator + TRENDS[trend] + File.separator + SITES[site]);
            File[] dirs = trenddir.listFiles(new FileFilter() {
                public boolean accept(File pathname) {
                    return DIR_NAME_START.contains(pathname.getName().substring(0, 2));
                }
            });
            if (dirs.length == 0) {
                System.out.println("No data for " + SITES[site] + ", " + TRENDS[trend] + ". Skipping");
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

    private void importFiles(SortedSet<LIGOFile> files) throws Exception {
        int i = 0;
        for (LIGOFile f : files) {
            long start = System.currentTimeMillis();
            checkDuration(f.f, f.trend);
            importFile(f.site, f.trend, f.f);
            i++;
            if (i % 10 == 0) {
                Timings.print();
            }
            long now = System.currentTimeMillis();
            long est = (now - start) * (files.size() - i);
            System.out.println(i + "/" + files.size() + " (" + i * 100 / files.size()
                    + "%) done; estimated time left: " + formatTime(est));
        }
    }

    private String formatTime(long est) {
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

    private void importFile(int site, int trend, File f) throws Exception {
        String pp;
        System.out.print(pp = "Processing " + f.getName() + "...");
        Set<String> c = getActualChannels(site, trend, f);
        int col = pp.length();
        for (String channel : c) {
            if (!tables.containsKey(channel)) {
                throw new RuntimeException("Error: channel " + channel + " does not exist in the database");
            }
            if (!inDatabase(site, trend, fileGPSTime(f), TREND_FILE_DURATION[trend], tables.get(channel))) {
                Timings.timingStart("createTempFiles");
                File rms = File.createTempFile("ldatarms", ".bin");
                File mean = File.createTempFile("ldatamean", ".bin");
                Timings.timingEnd("createTempFiles");
                rms.deleteOnExit();
                mean.deleteOnExit();
                DataReader<?, ?> data = runFrameDataDump(f, rms, mean, channel, tables.get(channel));
                Timings.timingStart("insertIntoDb");
                data.insertIntoDatabase();
                Timings.timingEnd("insertIntoDb");
                Timings.timingStart("removeTempFiles");
                rms.delete();
                mean.delete();
                new File(rms.getAbsolutePath() + ".txt").delete();
                new File(mean.getAbsolutePath() + ".txt").delete();
                Timings.timingEnd("removeTempFiles");
                System.out.print(".");
            }
            else {
                System.out.print("-");
            }
            col++;
            if (col == 80) {
                System.out.println();
                col = 0;
            }
        }
        System.out.println();
    }

    private Set<String> getActualChannels(int site, int trend, File f) throws Exception {
        Timings.timingStart("getActualChannels");
        String frChannels = pathToLigoTools + File.separator + "bin" + File.separator + "FrChannels";
        String[] cmd = new String[] { frChannels, f.getAbsolutePath() };
        Process p = Runtime.getRuntime().exec(cmd);
        String out = getOutput(p.getInputStream());
        String err = getOutput(p.getErrorStream());
        int ec = p.waitFor();
        if (ec != 0) {
            throw new RuntimeException("FrChannels on " + f + " failed: " + err);
        }
        BufferedReader br = new BufferedReader(new StringReader(out));
        Set<String> l = new HashSet<String>();
        String line = br.readLine();
        while (line != null) {
            String[] s1 = line.split("\\s+");
            int i = s1[0].lastIndexOf('.');
            l.add(s1[0].substring(0, i));
            line = br.readLine();
        }
        Timings.timingEnd("getActualChannels");
        return l;
    }

    private DataReader<?, ?> runFrameDataDump(File f, File rms, File mean, String channel, String table)
            throws IOException {
        Timings.timingStart("runFrameDataDump");
        String frameDataDump = pathToLigoTools + File.separator + "bin" + File.separator + "FrameDataDump";
        String[] crms = new String[] { frameDataDump, "-I" + f.getAbsolutePath(), "-C" + channel + ".rms",
                "-O" + rms.getAbsolutePath() };
        String[] cmean = new String[] { frameDataDump, "-I" + f.getAbsolutePath(), "-C" + channel + ".mean",
                "-O" + mean.getAbsolutePath() };
        Process prms = Runtime.getRuntime().exec(crms);
        Process pmean = Runtime.getRuntime().exec(cmean);
        int ecrms, ecmean;
        try {
            ecrms = prms.waitFor();
            ecmean = pmean.waitFor();
        }
        catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        Timings.timingEnd("runFrameDataDump");
        String orms = getOutput(prms, f);
        String omean = getOutput(pmean, f);
        Timings.timingStart("checkFrDumpOutput");
        String[] info = checkFrDumpOutput(orms, types.get(channel), TYPE_SIZES.get(types.get(channel)));
        checkFrDumpOutput(omean, types.get(channel), TYPE_SIZES.get(types.get(channel)));
        Timings.timingEnd("checkFrDumpOutput");
        double starttime = Double.parseDouble(info[0]);
        int nsamples = Integer.parseInt(info[1]);
        double lentime = Double.parseDouble(info[2]);

        Timings.timingStart("readData");
        DataReader<?, ?> dp = DataReader.instance(types.get(channel), conn, table);
        readData(dp, rms, mean);
        Timings.timingEnd("readData");

        if (nsamples != dp.size()) {
            throw new RuntimeException("Size mismatch. Expected " + nsamples + " words, but only " + dp.size()
                    + " were found in the data file");
        }

        Timings.timingStart("process");
        dp.process(starttime, lentime, RAW_SAMPLES_PER_SECOND);
        Timings.timingEnd("process");

        return dp;
    }

    private void readData(DataReader<?, ?> dp, File rms, File mean) throws IOException {
        InputStream isrms = new FileInputStream(rms);
        InputStream ismean = new FileInputStream(mean);

        while (dp.readOne(isrms, ismean)) {
            // noop
        }

        isrms.close();
        ismean.close();
    }

    public static final Pattern FRD_FRAME_TIME = Pattern.compile("The first frame begins at GPS time ([0-9\\.]+)");
    public static final Pattern FRD_SAMPLES_READ = Pattern
        .compile("([0-9]+) samples \\(([0-9\\.]+) s\\) successfully written");
    public static final Pattern FRD_TYPE = Pattern.compile("The binary output file \\(.*\\) is of type '(\\w+)'");
    public static final Pattern FRD_WORDLEN = Pattern.compile("The word length is ([0-9]+) bytes");
    public static final Pattern[] FRD_PATTERNS = new Pattern[] { FRD_FRAME_TIME, FRD_SAMPLES_READ, FRD_TYPE,
            FRD_WORDLEN };

    private String[] checkFrDumpOutput(String out, String expectedType, int expectedWordSize) throws IOException {
        // 0: gpstime, 1: nsamples, 2: seconds, 3: type, 4: wordsize
        String[] info = new String[5];
        int patternIndex = 0, infoIndex = 0;
        BufferedReader br = new BufferedReader(new StringReader(out));
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
        throw new RuntimeException("Invalid FrameDataDump output: " + out);
    }

    private String getOutput(Process p, File f) throws IOException {
        int ec;
        try {
            ec = p.waitFor();
        }
        catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        String out = getOutput(p.getInputStream());
        String err = getOutput(p.getErrorStream());

        if (ec != 0) {
            throw new IOException("FrameDataDump failed for " + f + ": " + err);
        }
        return out;
    }

    private String getOutput(InputStream is) throws IOException {
        StringBuilder sb = new StringBuilder();
        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        String line = br.readLine();
        while (line != null) {
            sb.append(line);
            sb.append('\n');
            line = br.readLine();
        }
        return sb.toString();
    }

    private boolean inDatabase(int site, int trend, long start, int len, String table) throws SQLException {
        Timings.timingStart("inDatabase");
        long end = start + len;
        Timings.timingStart("getCachedStatement");
        PreparedStatement s = getCachedInDatabaseStatement(table);
        Timings.timingEnd("getCachedStatement");
        s.setDouble(1, start);
        s.setDouble(2, end);

        ResultSet rs = s.executeQuery();
        Timings.timingEnd("inDatabase");
        return rs.next();
    }

    private Map<String, PreparedStatement> inDatabaseStatements = new HashMap<String, PreparedStatement>();

    private PreparedStatement getCachedInDatabaseStatement(String table) throws SQLException {
        PreparedStatement ps = inDatabaseStatements.get(table);
        if (ps == null) {
            ps = conn.prepareStatement("SELECT time FROM " + table + " WHERE time >= ? AND time <= ? LIMIT 1");
            inDatabaseStatements.put(table, ps);
        }
        return ps;
    }

    public static final Pattern RE_FILE_GPS_TIME = Pattern.compile("[H|L]-[T|M]-(\\d+)-\\d+.gwf");

    private long fileGPSTime(File file) {
        Matcher m = RE_FILE_GPS_TIME.matcher(file.getName());
        if (m.matches()) {
            return Long.parseLong(m.group(1));
        }
        else {
            throw new RuntimeException("File does not match expected pattern: " + file);
        }
    }

    private void checkDuration(File file, int trend) {
        if (!file.getName().endsWith("-" + TREND_FILE_DURATION[trend] + ".gwf")) {
            throw new RuntimeException("File duration does not match expected (" + TREND_FILE_DURATION[trend]
                    + ") for " + file + ". Bailing out.");
        }
    }

    private void shiftSums() throws Exception {
        System.out.println("Updating sums...");
        conn.setAutoCommit(false);
        try {
            PreparedStatement ps1 = conn.prepareStatement("SELECT DISTINCT tablename FROM sumupdates");

            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                String table = rs1.getString(1);
                System.out.print(table + "...");
                PreparedStatement ps2 = conn.prepareStatement("SELECT "
                        + "(starttime, endtime, sumdeltad, sumdeltai, ssqdeltad, ssqdeltai, sumdeltad ISNULL) "
                        + "FROM sumupdates WHERE tablename = ?");
                final int STARTTIME = 1, ENDTIME = 2, SUMDELTAD = 3, SUMDELTAI = 4, SSQDELTAD = 5, SSQDELTAI = 6;
                ps2.setString(1, table);
                ResultSet rs2 = ps2.executeQuery();
                double sumdeltad = 0, ssqdeltad = 0;
                long sumdeltai = 0, ssqdeltai = 0;

                rs2.next();
                while (true) {
                    System.out.print(".");
                    boolean isint = rs2.getBoolean(7);
                    double start = rs2.getDouble(STARTTIME);
                    double end = rs2.getDouble(ENDTIME);
                    sumdeltad += rs2.getDouble(SUMDELTAD);
                    sumdeltai += rs2.getLong(SUMDELTAI);
                    ssqdeltad += rs2.getDouble(SSQDELTAD);
                    ssqdeltai += rs2.getLong(SSQDELTAI);

                    double ustart = end;
                    double uend;
                    boolean last = false;

                    if (rs2.next()) {
                        uend = rs2.getDouble(STARTTIME);
                    }
                    else {
                        uend = END_OF_TIME;
                        last = true;
                    }

                    PreparedStatement us = conn.prepareStatement("UPDATE " + table
                            + " SET sum = sum + ?, sumsq = sumsq + ? WHERE time > ? AND time < ?");
                    if (isint) {
                        us.setLong(1, sumdeltai);
                        us.setLong(2, ssqdeltai);
                    }
                    else {
                        us.setDouble(1, sumdeltad);
                        us.setDouble(2, ssqdeltad);
                    }
                    us.setDouble(3, ustart);
                    us.setDouble(4, uend);
                    us.execute();
                    us.close();
                    if (last) {
                        break;
                    }
                }

                System.out.println();
            }

            conn.commit();
        }
        catch (Exception e) {
            conn.rollback();
            throw e;
        }
        finally {
            conn.setAutoCommit(true);
        }
    }

    private void connectToDb() throws SQLException {
        System.out.println("Connecting to database...");
        conn = DriverManager.getConnection("jdbc:postgresql:" + dburl, dbuser, dbpass);
    }

    public static void main(String[] args) {
        if (args.length < 5) {
            error("Missing argument(s)", 1);
        }
        try {
            new ImportData(args[0], args[1], args[2], args[3], args[4]).run();
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
        help();
        System.exit(ec);
    }

    public static void help() {
        System.err.println("Usage: ImportData <pathToData> <pathToLigoTools> <dburl> <dbuser> <dbpass>");
    }
}
