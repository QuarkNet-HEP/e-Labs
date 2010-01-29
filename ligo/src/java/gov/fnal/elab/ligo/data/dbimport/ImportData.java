/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;

public class ImportData extends AbstractDataTool {

    private String pathToData, pathToLIGOTools;
    private Set<String> processedFiles;
    private BufferedWriter log;
    private static final int ESTIMATION_RUNS = 20;
    private static final int BATCH_SIZE = 1000;
    private String workdir;
    private PrintWriter error;

    private long flen;

    private Map<String, PGDataFileWriter> writers;

    private Map<String, Double> maxtime;
    private List<String> fileBatch;

    private static Object SHUTDOWN_LOCK = new Object();

    public ImportData(String pathToData, String pathToLIGOTools, String workdir, String dburl, String dbuser,
            String dbpass) {
        super(dburl, dbuser, dbpass);
        this.pathToData = pathToData;
        this.pathToLIGOTools = pathToLIGOTools;
        this.workdir = workdir;
        writers = new HashMap<String, PGDataFileWriter>();
        maxtime = new HashMap<String, Double>();
        fileBatch = new ArrayList<String>();
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
        initTmpDir();
        connectToDb();
        loadChannelInfo();
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

    private void initTmpDir() throws IOException {
        File f = File.createTempFile("ligoimport", "");
        if (!f.delete()) {
            throw new IOException("Cannot remove temp file " + f);
        }
        if (!f.mkdirs()) {
            throw new IOException("Cannot create temp directory " + f);
        }
    }

    private void loadMaxTimes() throws SQLException {
        System.out.println("Loading times...");
        Statement s = conn.createStatement();
        maxtime.clear();
        for (Map.Entry<String, String> e : tables.entrySet()) {
            ResultSet rs = s.executeQuery("SELECT MAX(time) FROM " + e.getValue());
            if (rs.next()) {
                maxtime.put(e.getKey(), rs.getDouble(1));
            }
            else {
                maxtime.put(e.getKey(), 0.0);
            }
        }
    }

    private void convertAndImport(SortedSet<LIGOFile> files) throws Exception {

        loadProcessedFiles();
        int fileCount = 0, batchCount = 1;

        for (LIGOFile f : files) {
            fileCount++;
            flen += f.file.length();

            if (processedFiles.contains(f.file.getName())) {
                System.out.println("Skipping " + f.file.getName());
                continue;
            }

            checkDuration(f.file, f.trend);
            convertFile(f);

            batchCount++;
            if (batchCount % BATCH_SIZE == 0) {
                commitBatch();
            }

            printInfo(fileCount, files);
        }
        commitBatch();
        log("# done");
    }

    private LinkedList<Long> times = new LinkedList<Long>();

    private void printInfo(int fileCount, SortedSet<LIGOFile> files) {
        if (fileCount % 100 == 0) {
            Timings.print();
        }
        long now = System.currentTimeMillis();
        times.addLast(now);
        long est;
        if (times.size() > ESTIMATION_RUNS) {
            long start = times.removeFirst();
            est = (now - start) * (files.size() - fileCount) / ESTIMATION_RUNS;
        }
        else {
            est = -1;
        }
        System.out.println(fileCount + "/" + files.size() + " (" + fileCount * 100 / files.size() + "%, "
                + formatSize(flen) + ") done; estimated time left: " + formatTime(est));
    }

    private void loadProcessedFiles() throws IOException {
        processedFiles = new HashSet<String>();
        File f = new File(workdir + File.separator + "ligoimport.files");
        if (f.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(f));

            int batchCount = 0;
            boolean last = false;
            String line = br.readLine();
            while (line != null) {
                batchCount++;
                if (line.startsWith("# batch")) {
                    batchCount = 0;
                }
                else if (line.startsWith("# done")) {
                    last = true;
                }
                else {
                    processedFiles.add(line);
                }
                line = br.readLine();
            }
            if (last) {
                throw new RuntimeException("Data already imported. Clear the database and the work directory to redo.");
            }
            else if (batchCount != 0) {
                throw new RuntimeException("Log file is corrupt (count=" + batchCount
                        + "). Clear the database and the work directory.");
            }
            br.close();
        }
        log = new BufferedWriter(new FileWriter(f, true));
    }

    private void commitBatch() throws Exception {
        synchronized (SHUTDOWN_LOCK) {
            System.out.println("Committing batch...");
            conn.setAutoCommit(false);
            try {
                copyToDb();
                writers.clear();
                for (String file : fileBatch) {
                    log(file);
                    markFileAsImported(file);
                }
                fileBatch.clear();
                log("# batch");
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
    }
    
    private PreparedStatement psInsertKeyInDb;
    
    private void markFileAsImported(String f) throws SQLException {
        if (psInsertKeyInDb == null) {
            psInsertKeyInDb = conn.prepareStatement("INSERT INTO files VALUES(?)");
        }
        psInsertKeyInDb.setString(1, f);
        psInsertKeyInDb.execute();
    }

    private void copyToDb() throws Exception {
        int i = 0;
        for (Map.Entry<String, String> e : tables.entrySet()) {
            i++;
            String channel = e.getKey();
            System.out.println(channel + "... (" + i + "/" + tables.size() + ")");
            PGDataFileWriter wr = writers.get(channel);
            if (wr == null) {
                System.out.println("no writer for " + channel);
            }
            else {
                wr.close();
                wr.getFile().setReadable(true);
                copyIntoDb(wr.getFile(), e.getValue());
                wr.getFile().delete();
            }
        }
    }

    private void copyIntoDb(File data, String table) throws SQLException {
        data.setReadable(true);
        Statement s = conn.createStatement();
        s.execute("COPY BINARY " + table + " FROM '" + data.getAbsolutePath() + "'");
    }

    private void convertFile(final LIGOFile f) throws Exception {
        System.out.print("Processing " + f.file.getName() + "...");
        long time = fileGPSTime(f.file);
        String tmpprefix = runFrameDataDump2(f.file, null);

        Set<String> dumpedc = getDumpedChannels(tmpprefix);
        Set<String> dcc = new HashSet<String>(dumpedc);
        dcc.removeAll(tables.keySet());
        if (!dcc.isEmpty()) {
            // new channels
            CreateDatabase cd = new CreateDatabase(conn);
            cd.createChannelTables(pathToLIGOTools, f.file);
            // refresh table names and types
            loadChannelInfo();
            loadMaxTimes();
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

        Iterator<Map.Entry<String, DataReader<?, ?>>> i = s.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry<String, DataReader<?, ?>> e = i.next();
            e.getValue().write(getWriter(e.getKey()));
            i.remove();
        }
        fileBatch.add(f.file.getName());
    }

    private DataReader<?, ?> readChannelData(String channel, String tmpprefix, LIGOFile f, boolean delete)
            throws Exception {
        Timings.timingStart("readChannelData");
        DataReader<?, ?> data = null;
        File rmsbin = new File(tmpprefix + channel + ".rms.bin");
        File meanbin = new File(tmpprefix + channel + ".mean.bin");
        File rmstxt = new File(tmpprefix + channel + ".rms.txt");
        File meantxt = new File(tmpprefix + channel + ".mean.txt");

        if (!tables.containsKey(channel)) {
            throw new RuntimeException("Error: channel " + channel + " does not exist in the database");
        }
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
        String table = tables.get(channel);
        if (!rangeCovered(starttime, len, channel)) {
            data = readFrameDataDump(f.file, rmsbin, rmstxt, meanbin, meantxt, channel, tables.get(channel));
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
        Timings.timingEnd("readChannelData");
        return data;
    }

    private boolean rangeCovered(long starttime, int len, String channel) {
        return starttime <= maxtime.get(channel);
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
        Timings.timingStart("runFrameDataDump2");
        File tmp = File.createTempFile("ldump", "", dir);
        tmp.delete();
        if (!tmp.mkdirs()) {
            throw new RuntimeException("Cannot create temp dir " + tmp);
        }
        String frameDataDump = pathToLIGOTools + File.separator + "bin" + File.separator + "FrameDataDump2";
        String[] c = new String[] { frameDataDump, "-I" + f.getAbsolutePath(), "-O" + tmp.getAbsolutePath() + "/" };
        Process p = Runtime.getRuntime().exec(c);
        String o = ProcessTools.getOutput("FrameDataDump2", p, f);
        Timings.timingEnd("runFrameDataDump2");
        return tmp.getAbsolutePath() + "/";
    }

    private PGDataFileWriter getWriter(String channel) throws IOException {
        PGDataFileWriter w = writers.get(channel);
        if (w == null) {
            w = new PGDataBinaryFileWriter(new File(workdir + File.separator + "ldata-" + channel), false);
            writers.put(channel, w);
        }
        return w;
    }

    private void log(String f) throws IOException {
        log.write(f + "\n");
        log.flush();
    }

    public static void main(String[] args) {
        if (args.length < 6) {
            help();
            error("Missing argument(s)", 1);
        }
        try {
            new ImportData(args[0], args[1], args[2], args[3], args[4], args[5]).run();
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
        System.err.println("Usage: ImportData <pathToData> <pathToLigoTools> <workdir> <dburl> <dbsuser> <dbsupass>");
        System.err.println("  where:");
        System.err.println("    <pathToData> path to data in standard ligo trend directories");
        System.err.println("    <pathToLigoTools> path to LIGO tools (in particular FrDump and FrameDataDump2)");
        System.err.println("    <workdir> a directory to hold data and log state");
        System.err.println("    <dburl>    database name");
        System.err
            .println("    <dbsuser>  a database user with superuser priviledges (in order to be able to execute COPY statements)");
        System.err.println("    <dbsupass> password for said user");
    }
}
