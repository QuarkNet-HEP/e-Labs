/*
 * Created on Sep 2, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.estimation.EstimationHistoryTracker;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.Timer;
import java.util.TimerTask;
import java.util.TreeMap;
import java.util.TreeSet;

public class HistoricData implements EstimationHistoryTracker {
    public static final String LOG = System.getProperty("user.home") + File.separator + ".analysis-times";
    public static final String TMP = System.getProperty("user.home") + File.separator + ".analysis-times.tmp";

    public static final long S = 1000;
    public static final long M = 60 * S;
    public static final long H = 60 * M;
    public static final long D = 24 * H;

    public static final int MIN_RANGE = 5000;

    public static final long MAX_AGE = 120 * D;

    public static final long PRUNE_AND_SAVE_INTERVAL = 30 * M;

    private static HistoricData instance;

    public synchronized static HistoricData instance() {
        if (instance == null) {
            instance = new HistoricData();
            instance.load();
            Runtime.getRuntime().addShutdownHook(new Thread() {
                @Override
                public void run() {
                    instance.pruneAndSave();
                }
            });
        }
        return instance;
    }

    private static class Entry implements Comparable<Entry> {
        public final String type;
        public final String mode;
        public final int events;
        public final int time;
        public final long timestamp;

        public Entry(String type, String mode, int events, int time, long timestamp) {
            this.type = type;
            this.mode = mode;
            this.events = events;
            this.time = time;
            this.timestamp = timestamp;
        }

        public int compareTo(Entry o) {
            return (int) (timestamp - o.timestamp);
        }
    }

    public static class Parameters {
        public double a;
        public double b;

        public Parameters(double a, double b) {
            this.a = a;
            this.b = b;
        }
        
        public String toString() {
            return "(" + a + ", " + b + ")";
        }
    }

    private SortedSet<Entry> data;
    private Set<String> types;
    private Map<String, Map<String, Parameters>> fit;
    private boolean updated;

    private Timer timer;

    private HistoricData() {
        data = new TreeSet<Entry>();
        types = new HashSet<String>();
        fit = new HashMap<String, Map<String, Parameters>>();
        load();
        updated = false;
        timer = new Timer();
        timer.schedule(new PruneAndSave(), PRUNE_AND_SAVE_INTERVAL, PRUNE_AND_SAVE_INTERVAL);
    }

    private void load() {
        try {
            File log = new File(LOG);
            if (!log.exists()) {
                log = new File(TMP);
                if (!log.exists()) {
                    System.out.println("Log and tmp log are both missing");
                    return;
                }
                else {
                    log.renameTo(new File(LOG));
                    log = new File(LOG);
                }
            }
            data.clear();
            BufferedReader br = new BufferedReader(new FileReader(log));
            try {
                String line = br.readLine();
                while (line != null) {
                    String[] spl = line.split("\\s+");
                    if (spl.length != 5) {
                        System.out.println("Invalid line in " + log + ": " + line);
                    }
                    else {
                        try {
                            addData(spl[0], spl[1], toInt(spl[2]), toInt(spl[3]), Long.parseLong(spl[4]));
                        }
                        catch (NumberFormatException e) {
                            System.out.println("Invalid line in " + log + ": " + line);
                        }
                    }
                    line = br.readLine();
                }
            }
            finally {
                br.close();
            }
        }
        catch (Exception e) {
            System.err.println("Error loading analysis time log");
            e.printStackTrace();
        }
    }

    private int toInt(String val) {
        return Integer.parseInt(val);
    }

    private void addData(String type, String mode, int events, int time, long timestamp) {
        data.add(new Entry(type, mode, events, time, timestamp));
        updated = true;
    }

    public synchronized void track(String type) {
        types.add(type);
    }

    public synchronized void add(Elab elab, AnalysisRun run) {
        try {
            ElabAnalysis analysis = run.getAnalysis();
            if (types.contains(analysis.getType())) {
                Collection rd = (Collection) analysis.getParameter("rawData");
                String runMode = (String) run.getAttribute("runMode");
                if (runMode == null) {
                    runMode = "local";
                }
                int events = AnalysisParameterTools.getEventCount(elab, rd);
                addData(analysis.getType(), runMode, events, (int) (run.getEndTime().getTime() - run.getStartTime()
                    .getTime()), System.currentTimeMillis());
            }
        }
        catch (Exception e) {
            System.err.println("Could not add analysis run to historic data: " + run);
            e.printStackTrace();
        }
    }

    private void prune() {
        long now = System.currentTimeMillis();
        long limit = now - MAX_AGE;
        data.headSet(new Entry(null, null, 0, 0, limit)).clear();
    }

    private synchronized void save() {
        if (!updated) {
            return;
        }
        File log = new File(LOG);
        File tmp = new File(TMP);
        try {
            FileWriter fw = new FileWriter(TMP);
            try {
                for (Entry e : data) {
                    fw.write(e.type + " " + e.mode + " " + e.events + " " + e.time + " " + e.timestamp + "\n");
                }
            }
            finally {
                fw.close();
            }
            log.delete();
            tmp.renameTo(log);
            updated = false;
        }
        catch (Exception e) {
            tmp.delete();
            System.err.println("Error saving performance history");
            e.printStackTrace();
        }
    }

    protected synchronized void pruneAndSave() {
        prune();
        save();
    }

    private static class Bin {
        private List<Integer> v;
        public int sum, n;
        public double sumsq;

        public Bin() {
            v = new ArrayList<Integer>();
        }
        
        public void add(int i) {
            v.add(i);
            sum += i;
            n++;
            double di = i;
            sumsq += di * di;
        }
        
        public double avg() {
            if (n == 0) {
                return 0;
            }
            else {
                double avg = sum / n;
                double stddev = Math.sqrt(sumsq / n - avg * avg);
                Iterator<Integer> i = v.iterator();
                while (i.hasNext()) {
                    int j = i.next();
                    if (Math.abs(j - avg) > stddev) {
                        sum -= j;
                        n--;
                    }
                }
                return sum / n;
            }
        }
    }

    private void addFit(String type, String mode, double a, double b) {
        Map<String, Parameters> m = fit.get(type);
        if (m == null) {
            m = new HashMap<String, Parameters>();
            fit.put(type, m);
        }
        m.put(mode, new Parameters(a, b));
    }

    private void fit() {
        Map<String, Map<String, SortedMap<Integer, Bin>>> m1 = new HashMap<String, Map<String, SortedMap<Integer, Bin>>>();
        synchronized (this) {
            for (Entry e : data) {
                Map<String, SortedMap<Integer, Bin>> m2 = m1.get(e.type);
                if (m2 == null) {
                    m2 = new HashMap<String, SortedMap<Integer, Bin>>();
                    m1.put(e.type, m2);
                }
                SortedMap<Integer, Bin> m3 = m2.get(e.mode);
                if (m3 == null) {
                    m3 = new TreeMap<Integer, Bin>();
                    m2.put(e.mode, m3);
                }
                Bin bin = m3.get(e.events);
                if (bin == null) {
                    bin = new Bin();
                    m3.put(e.events, bin);
                }
                bin.add(e.time);
            }
        }
        for (Map.Entry<String, Map<String, SortedMap<Integer, Bin>>> e1 : m1.entrySet()) {
            for (Map.Entry<String, SortedMap<Integer, Bin>> e2 : e1.getValue().entrySet()) {
                if (range(e2.getValue()) < MIN_RANGE) {
                    System.out.println("Not fitting " + e1.getKey() + "/" + e2.getKey() + ". Range < " + MIN_RANGE);
                    continue;
                }
                List<Fitter.Entry> l = new ArrayList<Fitter.Entry>();
                for (Map.Entry<Integer, Bin> e3 : e2.getValue().entrySet()) {
                    l.add(new Fitter.Entry(e3.getKey(), e3.getValue().avg()));
                }
                Fitter f = new LinearMinLogSquaredNewtonFitter();
                Parameters p = getParameters(e1.getKey(), e2.getKey(), null);
                f.fit(l, new double[] { p.a, p.b });
                addFit(e1.getKey(), e2.getKey(), f.getParameter(1), f.getParameter(2));
                System.out.println("Fitted " + e1.getKey() + "/" + e2.getKey() + ". Old: " + p + ", New: "
                        + getParameters(e1.getKey(), e2.getKey(), null));
            }
        }
    }

    private int range(SortedMap<Integer, Bin> m) {
        return m.lastKey() - m.firstKey();
    }

    private class PruneAndSave extends TimerTask {
        public void run() {
            pruneAndSave();
            fit();
        }
    }

    public Parameters getParameters(String type, String mode, Parameters guess) {
        track(type);
        Map<String, Parameters> m = fit.get(type);
        if (m == null) {
            m = new HashMap<String, Parameters>();
            m.put(mode, guess);
            fit.put(type, m);
            return guess;
        }
        else {
            Parameters p = m.get(mode);
            if (p == null) {
                m.put(mode, guess);
                return guess;
            }
            else {
                return p;
            }
        }
    }
}
