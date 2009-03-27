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
import gov.fnal.elab.util.ElabUtil;

import org.apache.commons.lang.StringUtils;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.AbstractCollection;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * A few convenience functions for dealing with QuarkNet data
 * 
 *TODO cosmic things to cosmic
 */
public class DataTools {
    public static String buildQueryURLParams(Elab elab, String key, String value) {
        return "?submit=true&key=" + key + "&value=" + value;
    }

    private static final Map KEYS;

    static {
        KEYS = new HashMap();
        KEYS.put("school", 0);
        KEYS.put("startdate", 1);
        KEYS.put("blessed", 2);
        KEYS.put("stacked", 3);
        KEYS.put("chan1", 4);
        KEYS.put("chan2", 5);
        KEYS.put("chan3", 6);
        KEYS.put("chan4", 7);
        KEYS.put("city", 8);
        KEYS.put("state", 9);
        KEYS.put("enddate", 10);
        KEYS.put("detectorid", 11);
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
    public static final int ENDDATE = 10;
    public static final int DETECTORID = 11; 

    public static final DateFormat MONTH_FORMAT;

    static {
        MONTH_FORMAT = new SimpleDateFormat("MMMM yyyy");
    }

    /**
     * Organizes the search results in a hierarchical fashion and returns a
     * {@link StructuredResultSet}
     * 
     * @param rs
     *            A {@link ResultSet} presumably obtained by running a query.
     * @return A {@link StructuredResultSet} with the organized data.
     * 
     */
    public static StructuredResultSet organizeSearchResults(ResultSet rs) {
        Date startDate = null, endDate = null;

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
            if (StringUtils.isBlank(schoolName)) {
                System.out.println("WARNING: School name is missing for file " + e.getLFN());
                schoolName = "Unknown School";
            }
            String cityName = (String) data[CITY];
            if (StringUtils.isBlank(cityName)) {
                System.out.println("WARNING: City name is missing for file " + e.getLFN());
                cityName = "Unknown City";
            }
            String stateName = (String) data[STATE];
            if (StringUtils.isBlank(stateName)) {
                System.out.println("WARNING: State name is missing for file " + e.getLFN());
                stateName = "Unknown State";
            }
            
            School school = srs.getSchool(schoolName, cityName, stateName);
            if (school == null) {
                school = new School(schoolName, cityName, stateName);
                srs.addSchool(school);
            }
            
            /* Correct city and state names if there some metadata pieces have bad data.
            if (school.getCity().equals("Unknown City") && !cityName.equals("Unknown City"))
            	school.setCity(cityName);
            if (school.getState().equals("Unknown State") && !stateName.equals("Uknown State"))
            	school.setState(stateName);
            */
            
            Timestamp ts = (Timestamp) data[STARTDATE];
            String startdate = MONTH_FORMAT.format(ts);
            Month month = school.getMonth(startdate);
            if (month == null) {
            	month = new Month(startdate, ts);
                school.addDay(month);
            }

            File file = new File(e.getLFN());
            file.setStartDate((Timestamp) data[STARTDATE]);
            file.setEndDate((Timestamp) data[ENDDATE]);
            
            try {
                file.setDetector(Integer.parseInt((String) data[DETECTORID]));
            }
            catch (Exception ex) {
            	System.out.println("WARNING: File " + e.getLFN() + " has a malformed detector ID. Skipping.");
            	continue;
            }
            	
            if (file.getStartDate() == null) {
            	System.out.println("WARNING: File " + e.getLFN() + " is missing the start date. Skipping.");
            	continue;
            }
            if (file.getEndDate() == null) {
                System.out.println("WARNING: File " + e.getLFN() + " is missing the end date. Defaulting to start date.");
                file.setEndDate(file.getStartDate());
            }

            if (startDate == null || startDate.after(file.getStartDate())) {
                startDate = file.getStartDate();
            }

            if (endDate == null || endDate.before(file.getEndDate())) {
                endDate = file.getEndDate();
            }

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
            month.addFile(file);
        }
        srs.setStartDate(startDate);
        srs.setEndDate(endDate);
        return srs;
    }

    public static final DateFormat TZ_DATE_TIME_FORMAT;

    static {
        TZ_DATE_TIME_FORMAT = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
    }

    /**
     * Builds a figure caption from a set of data files. This is Cosmic specific
     * and should be moved there. The caption is composed of the list of data
     * files, the set of detectors that captured the data and the set of
     * channels in the data.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A list of logical file names for the data
     * 
     * @return A figure caption
     */
    public static String getFigureCaption(Elab elab, Collection files)
            throws ElabException {
        if (files == null || files.size() == 0) {
            return "";
        }
        StringBuffer data = new StringBuffer();
        Set detectors = new HashSet();
        

        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        data.append("Data: ");
        int dataCount = 0;
        
        Iterator i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = (CatalogEntry) i.next();
            if (e == null) {
                continue;
            }
            detectors.add(e.getTupleValue("detectorid"));
            if (dataCount < 8) {
                data.append(e.getTupleValue("school"));
                data.append(' ');
                Object date = e.getTupleValue("startdate");
            
                if (date != null) {
                    data.append(TZ_DATE_TIME_FORMAT.format(date));
                    data.append(" UTC");
                    dataCount++;
                }
                if (i.hasNext()) {
                    data.append("\n");
                }
            }
            else if (dataCount != Integer.MAX_VALUE) {
                data.deleteCharAt(data.length() - 1);
                data.append("\n...");
                dataCount = Integer.MAX_VALUE;
            }
        }
        data.append('\n');
        if (detectors.size() > 1) {
            data.append("Detectors: ");
        }
        else {
            data.append("Detector: ");
        }
        data.append(ElabUtil.join(detectors, ", "));
        return data.toString();
    }
    
    public static String getFigureCaption(Elab elab, String[] files) throws ElabException {
        return getFigureCaption(elab, Arrays.asList(files));
    }
    
    private static final String[] STRING_ARRAY = new String[0];

    /**
     * Returns a {@link Collection} of values that correspond to a specific
     * metadata key for a {@link Collection} of logical file names. Values are
     * guaranteed to not appear twice in the {@link Collection}.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A {@link Collection} of logical file names
     * @param key
     *            A metadata key
     * 
     * @return A {@link Collection} of values
     * 
     */
    public static Collection getUniqueValues(Elab elab, String[] files,
            String key) throws ElabException {
        return getUniqueValues(elab, Arrays.asList(files),
                key);
    }

    /**
     * Returns a {@link Collection} of values that correspond to a specific
     * metadata key for an array of logical file names. Values are guaranteed to
     * not appear twice in the {@link Collection}.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A {@link Collection} of logical file names
     * @param key
     *            A metadata key
     * 
     * @return A {@link Collection} of values
     * 
     */
    public static Collection getUniqueValues(Elab elab, Collection files,
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
    
    public static final DateFormat DF0 = new SimpleDateFormat("MM/dd/yyyy");

    public static final DateFormat[] DFORMATS = new DateFormat[] {
            DateFormat.getDateTimeInstance(), DF0,
            DateFormat.getDateInstance(), DateFormat.getTimeInstance() };

    protected static Object coerce(String type, String value, String name) {
        try {
            if (type.equals("string")) {
                return value;
            }
            else if (type.equals("int") || type.equals("integer")
                    || type.equals("i") || type.equals("long")) {
                return Long.valueOf(value);
            }
            else if (type.equals("float") || type.equals("double")) {
                return Double.valueOf(value);
            }
            else if (type.equals("date")) {
                try {
                    return Timestamp.valueOf(value);
                }
                catch (Exception e) {
                }
                for (int i = 0; i < DFORMATS.length; i++) {
                    try {
                        return new Timestamp(DFORMATS[i].parse(value).getTime());
                    }
                    catch (Exception e) {
                    }
                }
                throw new IllegalArgumentException("Could not parse date: "
                        + value);
            }
            else if (type.equals("boolean")) {
                return Boolean.valueOf(value);
            }
            else {
                throw new IllegalArgumentException("cannot convert to type '"
                        + type + "'");
            }
        }
        catch (Exception e) {
            if (e.getClass().equals(IllegalArgumentException.class)) {
                throw (IllegalArgumentException) e;
            }
            throw new IllegalArgumentException("Could not convert " + name + " = " + value
                    + " to " + type + ": " + e.getMessage());
        }
    }

    /**
     * Builds a {@link CatalogEntry} from a logical file name and a
     * {@link Collection} of metadata descriptors. Each metadata descriptor is a
     * string of three space separated items:
     * <ol>
     * <li>The key (name)</li>
     * <li>A type. Possible values are
     * <code>"string", "integer", "int", "i", "long", "float", "double", "date"</code></li>
     * <li>The value</li>
     * </ol>
     * 
     * This method will attempt to interpret and convert the value to the
     * specified type before constructing the {@link CatalogEntry}
     * 
     * @param lfn
     *            The logical file name
     * @param metadata
     *            A {@link Collection} of metadata descriptors
     * 
     * @return A {@link CatalogEntry}
     */
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

            tuples.put(name, coerce(type, value, name));
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
