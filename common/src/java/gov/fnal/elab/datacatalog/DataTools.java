//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 20, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.AbstractCollection;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

public class DataTools {
    public static String buildQueryURLParams(Elab elab, String key, String value) {
        return "?submit=true&key=" + key + "&value=" + value;
    }

    private static final Map KEYS;

    static {
        KEYS = new HashMap();
        KEYS.put("school", new Integer(0));
        KEYS.put("startdate", new Integer(1));
        KEYS.put("blessed", new Integer(2));
        KEYS.put("stacked", new Integer(3));
        KEYS.put("chan1", new Integer(4));
        KEYS.put("chan2", new Integer(5));
        KEYS.put("chan3", new Integer(6));
        KEYS.put("chan4", new Integer(7));
        KEYS.put("city", new Integer(8));
        KEYS.put("state", new Integer(9));
    }

    public static final int SCHOOL = 0;
    public static final int STARTDATE = 1;
    public static final int BLESSED = 2;
    public static final int STACKED = 3;
    public static final int CHAN1 = 4;
    public static final int CHAN2 = 5;
    public static final int CHAN3 = 6;
    public static final int CHAN4 = 7;
    public static final int CITY = 8;
    public static final int STATE = 9;

    public static final DateFormat MONTH_FORMAT;

    static {
        MONTH_FORMAT = new SimpleDateFormat("MMMM yyyy");
    }

    public static StructuredResultSet organizeSearchResults(ResultSet rs) {
        StructuredResultSet srs = new StructuredResultSet();
        srs.setDataFileCount(rs.size());
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            Iterator j = e.tupleIterator();

            Object[] data = new Object[KEYS.size()];
            while (j.hasNext()) {
                Tuple t = (Tuple) j.next();
                Integer index = (Integer) KEYS.get(t.getKey());
                if (index != null) {
                    data[index.intValue()] = t.getValue();
                }
            }

            String schoolName = (String) data[SCHOOL];
            School school = srs.getSchool(schoolName);
            if (school == null) {
                school = new School(schoolName, (String) data[CITY],
                        (String) data[STATE]);
                srs.addSchool(school);
            }

            String startdate = MONTH_FORMAT.format((Timestamp) data[STARTDATE]);
            Month date = school.getMonth(startdate);
            if (date == null) {
                date = new Month(startdate);
                school.addDay(date);
            }

            File file = new File(e.getLFN());
            file.setDate((Timestamp) data[STARTDATE]);

            if (Boolean.TRUE.equals(data[BLESSED])) {
                file.setBlessed(true);
                school.incBlessed();
            }
            file.setStacked((Boolean) data[STACKED]);
            if (Boolean.TRUE.equals(data[STACKED])) {
                school.incStacked();
            }
            int events = 0;
            for (int k = CHAN1; k <= CHAN4; k++) {
                if (data[k] != null) {
                    events += ((Long) data[k]).intValue();
                }
            }
            school.incEvents(events);
            school.incDataFiles();
            date.addFile(file);
        }
        return srs;
    }

    public static final DateFormat TZ_DATE_TIME_FORMAT;

    static {
        TZ_DATE_TIME_FORMAT = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss zzz");
        TZ_DATE_TIME_FORMAT.setTimeZone(TimeZone.getTimeZone("GMT"));
    }

    public static String getFigureCaption(Elab elab, String[] files)
            throws ElabException {
        if (files == null || files.length == 0) {
            return "";
        }
        StringBuffer data = new StringBuffer();
        StringBuffer detectors = new StringBuffer();

        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        data.append("Data: ");
        if (rs.size() > 1) {
            detectors.append("Detectors: ");
        }
        else {
            detectors.append("Detector: ");
        }
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
            data.append(e.getTupleValue("school"));
            data.append(' ');
            Object date = e.getTupleValue("startdate");
            if (date != null) {
                data.append(TZ_DATE_TIME_FORMAT.format(date));
            }
            detectors.append(e.getTupleValue("detectorid"));
            if (i.hasNext()) {
                data.append(", ");
                detectors.append(", ");
            }
        }
        data.append('\n');
        data.append(detectors);
        return data.toString();
    }

    public static final Map CHANNELS;
    static {
        CHANNELS = new HashMap();
        CHANNELS.put("chan1", "1");
        CHANNELS.put("chan2", "2");
        CHANNELS.put("chan3", "3");
        CHANNELS.put("chan4", "4");
    }

    public static Collection getValidChannels(Elab elab, String[] files)
            throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Set channels = new HashSet();
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
            Iterator j = CHANNELS.entrySet().iterator();
            while (j.hasNext()) {
                Map.Entry f = (Map.Entry) j.next();
                String cname = (String) f.getKey();
                Long l = (Long) e.getTupleValue(cname);
                if (l != null && l.longValue() > 0) {
                    channels.add(f.getValue());
                }
            }
        }
        return channels;
    }
    
    private static final String[] STRING_ARRAY = new String[0];
    
    public static Collection getUniqueValues(Elab elab, Collection files,
            String key) throws ElabException {
        return getUniqueValues(elab, (String[]) files.toArray(STRING_ARRAY), key);
    }

    public static Collection getUniqueValues(Elab elab, String[] files,
            String key) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Set s = new HashSet();
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
            Object v = e.getTupleValue(key);
            if (v != null) {
                s.add(v);
            }
        }
        return s;
    }

    protected static Object coerce(String type, String value) {
        try {
            if (type.equals("string")) {
                return value;
            }
            else if (type.equals("int") || type.equals("integer")
                    || type.equals("i") || type.equals("long")) {
                return Long.valueOf(value);
            }
            else if (type.equals("date")) {
                return Timestamp.valueOf(value);
            }
            else {
                throw new IllegalArgumentException("cannot convert to type '"
                        + type + "'");
            }
        }
        catch (Exception e) {
            throw new IllegalArgumentException(value + ": " + e.getMessage());
        }
    }

    public static CatalogEntry buildCatalogEntry(final String lfn,
            final Collection metadata) {
        final Map tuples = new HashMap();
        Iterator i = metadata.iterator();
        while (i.hasNext()) {
            String m = (String) i.next();
            int n = m.indexOf(' ');
            int t = m.indexOf(' ', n + 1);
            if (n == -1 || t == -1) {
                throw new IllegalArgumentException("Invalid metadata entry: "
                        + m);
            }
            String name = m.substring(0, n);
            String type = m.substring(n + 1, t);
            String value = m.substring(t + 1);

            tuples.put(name, coerce(type, value));
        }

        return new CatalogEntry() {

            public String getLFN() {
                return lfn;
            }

            public Object getTupleValue(String key) {
                return tuples.get(key);
            }

            public Collection getTuples() {
                return new AbstractCollection() {
                    public Iterator iterator() {
                        return tupleIterator();
                    }

                    public int size() {
                        return tuples.size();
                    }
                };
            }

            public void setTupleValue(String key, Object value) {
                throw new UnsupportedOperationException("setTupleValue");
            }

            public Iterator tupleIterator() {
                final Iterator i = tuples.entrySet().iterator();

                return new Iterator() {
                    public boolean hasNext() {
                        return i.hasNext();
                    }

                    public Object next() {
                        Map.Entry e = (Map.Entry) i.next();
                        return new Tuple((String) e.getKey(), e.getValue());
                    }

                    public void remove() {
                        throw new UnsupportedOperationException("remove");
                    }
                };
            }
        };
    }
}
