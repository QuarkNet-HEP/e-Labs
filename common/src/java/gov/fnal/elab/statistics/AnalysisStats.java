/*
 * Created on Jan 11, 2009
 */
package gov.fnal.elab.statistics;

import gov.fnal.elab.statistics.Statistics.BarChartEntry;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

public class AnalysisStats {
    public static final String LOG = "/tmp/wf.log";

    public static final int RAW_DATA = 0;
    public static final int SWIFT_START = 1;
    public static final int SWIFT_SUCCESS = 2;
    public static final int SWIFT_FAILURE = 3;
    public static final int SITE = 4;
    public static final int TYPE = 5;
    public static final int JOB_HOST = 6;
    public static final int JOB_SUCCESS = 7;
    public static final int JOB_FAILURE = 8;
    public static final int VDS_START = 9;
    public static final int VDS_COMPLETION = 10;
    public static final int VDS_FAILURE = 11;

    private static final DateFormat PFMT = new SimpleDateFormat("MM/dd/yyyy");
    private Date pstart, pend;
    private String start, end;
    private int span;

    private long timestamp;

    private static Map eventKeys;

    private static void addEventKey(String key, int value) {
        eventKeys.put(key, new Integer(value));
    }

    static {
        eventKeys = new HashMap();
        addEventKey("rawData", RAW_DATA);
        addEventKey("swiftStart", SWIFT_START);
        addEventKey("swiftSuccess", SWIFT_SUCCESS);
        addEventKey("swiftFailure", SWIFT_FAILURE);
        addEventKey("site", SITE);
        addEventKey("type", TYPE);
        addEventKey("jobHost", JOB_HOST);
        addEventKey("jobSuccess", JOB_SUCCESS);
        addEventKey("jobFailure", JOB_FAILURE);
        addEventKey("vdsStart", VDS_START);
        addEventKey("vdsCompletion", VDS_COMPLETION);
        addEventKey("vdsFailure", VDS_FAILURE);
    }

    private static final DateFormat DF = new SimpleDateFormat("yyyyMMdd-hhmm");
    private static WeakReference stats;

    public SortedMap[] load() throws IOException {
        SortedMap[] m = initializeMaps();
        File f = new File(LOG);
        if (f.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(f));
            String line = br.readLine();
            while (line != null) {
                String[] e = line.split("\\s");
                Date d;
                if (e.length < 2) {
                    System.out.println("Invalid line (missing timestamp): " + line);
                    line = br.readLine();
                    continue;
                }
                try {
                    d = DF.parse(e[1]);
                }
                catch (ParseException e1) {
                    System.out.println("Error parsing analysis log line: "
                            + line);
                    line = br.readLine();
                    continue;
                }
                Integer type = (Integer) eventKeys.get(e[0]);
                if (type == null) {
                    System.out.println("Unknown event type: " + e[0]);
                    line = br.readLine();
                    continue;
                }
                switch (type.intValue()) {
                    case RAW_DATA:
                        m[RAW_DATA].put(d, new Entry(e[2].split(",").length));
                        break;
                    case SITE:
                    case TYPE:
                    case JOB_HOST:
                        m[type.intValue()].put(d, new Entry(e[2]));
                        break;
                    case SWIFT_SUCCESS:
                        m[SWIFT_SUCCESS].put(d, new Entry(Integer
                                .parseInt(e[2])));
                        break;
                    default:
                        m[type.intValue()].put(d, new Entry(0));
                }
                line = br.readLine();
            }
            timestamp = f.lastModified();
        }
        calculateCummulativeData(m);
        return m;
    }

    private SortedMap[] initializeMaps() {
        SortedMap[] m = new SortedMap[12];
        for (int i = 0; i < m.length; i++) {
            m[i] = new TreeMap();
        }
        return m;
    }

    private void calculateCummulativeData(SortedMap[] m) {
        for (int mi = 0; mi < m.length; mi++) {
            int lc = 0;
            int ls = 0;
            Iterator i = m[mi].entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry me = (Map.Entry) i.next();
                Entry e = (Entry) me.getValue();
                lc += 1;
                ls += e.value;
                e.sum = ls;
                e.count = lc;
            }
        }
    }

    public int getRuns(Date start, Date end) throws IOException {
        SortedMap[] m = getStats();
        return getCount(m[VDS_START], start, end)
                + getCount(m[SWIFT_START], start, end);
    }

    private int getCount(SortedMap m, Date start, Date end) {
        m = m.subMap(start, end);
        if (m.isEmpty()) {
            return 0;
        }
        else {
            return ((Entry) m.get(m.lastKey())).count
                    - ((Entry) m.get(m.firstKey())).count;
        }
    }

    private SortedMap[] getStats() throws IOException {
        SortedMap[] m;
        File f = new File(LOG);
        if (stats == null || (m = (SortedMap[]) stats.get()) == null
                || f.lastModified() > timestamp) {
            m = load();
            stats = new WeakReference(m);
        }
        return m;
    }

    public List getYearlyRuns(Date start, Date end) throws IOException {
        return getRuns(Calendar.YEAR, start, end);
    }

    public List getMonthlyRuns(Date start, Date end) throws IOException {
        return getRuns(Calendar.MONTH, start, end);
    }

    private List getRuns(int field, Date start, Date end) throws IOException {
        List l = new ArrayList();
        Calendar s = Calendar.getInstance();
        Calendar e = Calendar.getInstance();
        Calendar c = Calendar.getInstance();
        int max = 1;
        s.setTime(start);
        e.setTime(end);
        c.setTime(start);
        addOne(field, c);
        while (c.before(e)) {
            max = addRange(l, field, s, c, max);
            s.setTime(c.getTime());
            addOne(field, c);
        }
        max = addRange(l, field, s, e, max);
        scale(l, max);
        return l;
    }

    private static final DateFormat DF2 = new SimpleDateFormat("yyyy-MM");

    private int addRange(List l, int field, Calendar s, Calendar c, int max)
            throws IOException {
        String key = (field == Calendar.YEAR ? String.valueOf(s
                .get(Calendar.YEAR)) : DF2.format(s.getTime()));
        int v = getRuns(s.getTime(), c.getTime());
        if (v != 0 || !l.isEmpty()) {
            l.add(new BarChartEntry(key, v));
        }
        return max > v ? max : v;
    }

    private void scale(List l, int max) {
        Iterator i = l.iterator();
        while (i.hasNext()) {
            BarChartEntry bce = (BarChartEntry) i.next();
            bce.setRelativeSize((double) bce.getCount() / max);
        }
    }

    private int getMax(List l) {
        int max = 1;
        Iterator i = l.iterator();
        while (i.hasNext()) {
            BarChartEntry bce = (BarChartEntry) i.next();
            if (bce.getCount() > max) {
                max = bce.getCount();
            }
        }
        return max;
    }

    private void addOne(int f, Calendar s) {
        s.set(Calendar.DAY_OF_MONTH, 1);
        s.set(Calendar.HOUR, 0);
        s.set(Calendar.MINUTE, 0);
        s.set(Calendar.SECOND, 0);
        if (f == Calendar.YEAR) {
            s.set(Calendar.MONTH, 1);
            s.add(Calendar.YEAR, 1);
        }
        else {
            s.add(Calendar.MONTH, 1);
        }
    }

    public int getAnalysisRuns() throws IOException {
        Calendar end = Calendar.getInstance();
        Calendar start = Calendar.getInstance();
        start.add(Calendar.DAY_OF_YEAR, -span);
        return getRuns(start.getTime(), end.getTime());
    }

    public List getYearlyAnalysisCounts() throws IOException, ParseException {
        return getYearlyRuns(pstart, pend);
    }

    public List getMonthlyAnalysisCounts() throws IOException, ParseException {
        return getMonthlyRuns(pstart, pend);
    }

    public List getRunMethods() throws IOException {
        int v;
        List l = new ArrayList();
        SortedMap[] m = getStats();
        v = getCount(m[VDS_START], pstart, pend);
        l.add(new BarChartEntry("VDS-local", v));
        Map sm = categorize(m[SITE].subMap(pstart, pend));
        Iterator i = sm.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            l.add(new BarChartEntry((String) e.getKey(), ((Integer) e
                    .getValue()).intValue()));
        }
        percentize(l);
        return l;
    }

    public List getAnalysisTypes() throws IOException {
        int v;
        List l = new ArrayList();
        SortedMap[] m = getStats();
        Map sm = categorize(m[TYPE].subMap(pstart, pend));
        Iterator i = sm.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            l.add(new BarChartEntry((String) e.getKey(), ((Integer) e
                    .getValue()).intValue()));
        }
        percentize(l);
        return l;
    }

    private void percentize(List l) {
        int sum = 0;
        Iterator i = l.iterator();
        while (i.hasNext()) {
            BarChartEntry bce = (BarChartEntry) i.next();
            sum += bce.getCount();
        }

        i = l.iterator();
        while (i.hasNext()) {
            BarChartEntry bce = (BarChartEntry) i.next();
            bce.setRelativeSize((double) bce.getCount() / sum * 100);
        }
    }

    private Map categorize(Map m) {
        Map r = new TreeMap();
        Iterator i = m.entrySet().iterator();
        while (i.hasNext()) {
            increment(r, ((Entry) ((Map.Entry) i.next()).getValue()).ovalue);
        }
        return r;
    }

    private void increment(Map r, Object key) {
        Integer c = (Integer) r.get(key);
        if (c == null) {
            c = new Integer(1);
        }
        else {
            c = new Integer(c.intValue() + 1);
        }
        r.put(key, c);
    }

    private static final NumberFormat NF = new DecimalFormat("###.##");

    public String getVDSFailures() throws IOException {
        SortedMap[] m = getStats();
        int total = getCount(m[VDS_COMPLETION], pstart, pend);
        int failed = getCount(m[VDS_FAILURE], pstart, pend);
        if (total == 0) {
            return "-";
        }
        return failed + "/" + total + " ("
                + NF.format((double) failed / total * 100) + "%)";
    }

    public String getSwiftFailures() throws IOException {
        SortedMap[] m = getStats();
        int success = getCount(m[SWIFT_SUCCESS], pstart, pend);
        int failed = getCount(m[SWIFT_FAILURE], pstart, pend);
        if (success + failed == 0) {
            return "-";
        }
        return failed + "/" + (success + failed) + " ("
                + NF.format((double) failed / (success + failed) * 100) + "%)";
    }

    public List getRawDataDistribution() throws IOException {
        SortedMap[] m = getStats();
        SortedMap sm = m[RAW_DATA].subMap(pstart, pend);
        Map r = new TreeMap();
        Iterator i = sm.values().iterator();
        while (i.hasNext()) {
            Entry e = (Entry) i.next();
            increment(r, logRange(e.value));
        }

        List l = new ArrayList();
        i = r.entrySet().iterator();
        int max = 1;
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            int value = ((Integer) e.getValue()).intValue();
            if (value > max) {
                max = value;
            }
            l.add(new BarChartEntry(toInterval((Integer) e.getKey()), value));
        }
        scale(l, max);
        return l;
    }

    private String toInterval(Integer i) {
        if (i.intValue() < 3) {
            return i.toString();
        }
        else {
            double l2 = Math.floor(log2(i.intValue()));
            return ((int) Math.pow(2, l2) + 1) + " - "
                    + ((int) Math.pow(2, l2 + 1));
        }
    }

    private Integer logRange(int x) {
        if (false) {
            return new Integer(x);
        }
        if (x == 1) {
            return new Integer(1);
        }
        double l2 = Math.floor(log2(x)) + 1;
        return new Integer((int) Math.pow(2, l2));
    }

    private static double log2(double x) {
        return Math.log(x) / 0.693147181;
    }

    private static class Entry {
        private int value;
        private Object ovalue;
        private int count;
        private long sum;

        public Entry(int value) {
            this.value = value;
        }

        public Entry(Object value) {
            this.ovalue = value;
        }
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) throws ParseException {
        this.start = start;
        this.pstart = PFMT.parse(start);
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) throws ParseException {
        this.end = end;
        this.pend = PFMT.parse(end);
    }

    public int getSpan() {
        return span;
    }

    public void setSpan(int span) {
        this.span = span;
    }
}
