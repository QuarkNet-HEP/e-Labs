package gov.fnal.elab.statistics;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.statistics.Statistics.BarChartEntry;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

public class AnalysisStatistics {
    public static final int RAW_DATA = 0;
    public static final int SWIFT_START = 1;
    public static final int SITE = 2;
    public static final int TYPE = 3;
    public static final int JOB_HOST = 4;
    public static final int JOB_SUCCESS = 5;
    public static final int JOB_FAILURE = 6;

    private static final DateFormat PFMT = new SimpleDateFormat("MM/dd/yyyy");
    private Date pstart, pend;
    private String start, end;
    private int span;
    private Elab elab;
    private long timestamp;

    private static Map eventKeys;
    private SortedMap[] m;
    
    private static void addEventKey(String key, int value) {
        eventKeys.put(key, Integer.valueOf(value));
    }

    static {
        eventKeys = new HashMap();
        addEventKey("rawData", RAW_DATA);
        addEventKey("swiftStart", SWIFT_START);
        addEventKey("site", SITE);
        addEventKey("type", TYPE);
        addEventKey("jobHost", JOB_HOST);
        addEventKey("jobSuccess", JOB_SUCCESS);
        addEventKey("jobFailure", JOB_FAILURE);
    }

    private static final DateFormat DF = new SimpleDateFormat("yyyyMMdd-hhmm");
    private static final DateFormat DFNEW = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

    private static WeakReference stats;
    public Elab getElab() {
        return elab;
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }
    public SortedMap[] load() throws IOException, SQLException {
        int counter = 0;
        if (m == null) {
	    	m = initializeMaps();
	        Connection con = null;
	        PreparedStatement ps = null; 
	        try {
	        	con = DatabaseConnectionManager.getConnection(elab.getProperties());
	            ps = con.prepareStatement("SELECT date_started, " + 
	            						  "       rawdata, " +
	            						  "       study_runmode, " +
	            						  "       study_type, " +
	            						  "       study_result " +
	            						  "  FROM analysis_results "+
	            						  " ORDER BY date_started ");   
	            ResultSet rs = ps.executeQuery();
	            while (rs.next()) {
	            	Date rawdate = (Date) rs.getDate(1);
	            	String formatted = DFNEW.format(rawdate);
	            	Date d = DF.parse(formatted);
	            	m[SWIFT_START].put(d, new Entry("swift"));
	            	String rawdata = "unknown";
	            	if (rs.getString(2) != null) {
	            		rawdata = rs.getString(2);
	            	}
	            	String site = "unknown";
	            	if (rs.getString(3) != null) {
	            		site = rs.getString(3);
	            	}
	            	String type = "unknown";
	            	if (rs.getString(4) != null) {
	            		type = rs.getString(4);
	            	}
	                m[RAW_DATA].put(d, new Entry(rawdata));
	                m[SITE].put(d, new Entry(site));
	                m[TYPE].put(d, new Entry(type));
	                String result = rs.getString(5);
	                if (result != null) {
		                if (result.equals("2")) {
		                	m[JOB_SUCCESS].put(d, new Entry("jobSuccess"));                	
		                } else if (result.equals("3")) {
		                	m[JOB_FAILURE].put(d, new Entry("jobFailure"));                	
		                } else {
		                	m[JOB_FAILURE].put(d, new Entry("unknown"));
		                }
	                }
	                counter++;
	            }
	        } catch (Exception e) {
	        	String msg = e.getMessage();
	        }
	        finally {
	            DatabaseConnectionManager.close(con, ps);
	        }
	        calculateCummulativeData(m);
        }
        System.out.println("counter:"+String.valueOf(counter));
        return m;
    }

    private SortedMap[] initializeMaps() {
        SortedMap[] m = new SortedMap[7];
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

    public int getRuns(Date start, Date end) throws IOException, SQLException {
        SortedMap[] m = getStats();
        return getCount(m[SWIFT_START], start, end);
    }

    private int getCount(SortedMap m, Date start, Date end) {
    	m.s
        m = m.subMap(start, end);
        if (m.isEmpty()) {
            return 0;
        }
        else {
            //return ((Entry) m.get(m.lastKey())).count - ((Entry) m.get(m.firstKey())).count;
        	return m.size();
        }
    }

    private SortedMap[] getStats() throws IOException, SQLException {
        SortedMap[] m;
        m = load();
        stats = new WeakReference(m);
        return m;
    }

    public List getYearlyRuns(Date start, Date end) throws IOException, SQLException  {
        return getRuns(Calendar.YEAR, start, end);
    }

    public List getMonthlyRuns(Date start, Date end) throws IOException, SQLException  {
        return getRuns(Calendar.MONTH, start, end);
    }

    private List getRuns(int field, Date start, Date end) throws IOException, SQLException {
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

    private int addRange(List l, int field, Calendar s, Calendar c, int max) throws IOException, SQLException {
        String key = (field == Calendar.YEAR ? String.valueOf(s.get(Calendar.YEAR)) : DF2.format(s.getTime()));
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

    public int getAnalysisRuns() throws IOException, SQLException  {
        Calendar end = Calendar.getInstance();
        Calendar start = Calendar.getInstance();
        start.add(Calendar.DAY_OF_YEAR, -span);
        int runs = getRuns(start.getTime(), end.getTime());
        return runs;
    }

    public List getYearlyAnalysisCounts() throws IOException, ParseException, SQLException  {
        return getYearlyRuns(pstart, pend);
    }

    public List getMonthlyAnalysisCounts() throws IOException, ParseException, SQLException  {
        return getMonthlyRuns(pstart, pend);
    }

    public List getRunMethods() throws IOException, SQLException  {
        int v;
        List l = new ArrayList();
        SortedMap[] m = getStats();
        v = getCount(m[SWIFT_START], pstart, pend);
        l.add(new BarChartEntry("VDS-local", v));
        Map sm = categorize(m[SITE].subMap(pstart, pend));
        Iterator i = sm.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            l.add(new BarChartEntry((String) e.getKey(), ((Integer) e.getValue()).intValue()));
        }
        percentize(l);
        return l;
    }

    public List getAnalysisTypes() throws IOException, SQLException  {
        int v;
        List l = new ArrayList();
        SortedMap[] m = getStats();
        Map sm = categorize(m[TYPE].subMap(pstart, pend));
        Iterator i = sm.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            l.add(new BarChartEntry((String) e.getKey(), ((Integer) e.getValue()).intValue()));
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
            c = Integer.valueOf(1);
        }
        else {
            c = Integer.valueOf(c.intValue() + 1);
        }
        r.put(key, c);
    }

    private static final NumberFormat NF = new DecimalFormat("###.##");

    public List getRawDataDistribution() throws IOException, SQLException  {
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
    
    public List getAvgDailyRawDataCountOverTime() throws IOException, SQLException  {
        SortedMap[] m = getStats();
        SortedMap sm = m[RAW_DATA].subMap(pstart, pend);
        List l = new ArrayList();
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
            return Integer.valueOf(x);
        }
        if (x == 1) {
            return Integer.valueOf(1);
        }
        double l2 = Math.floor(log2(x)) + 1;
        return Integer.valueOf((int) Math.pow(2, l2));
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