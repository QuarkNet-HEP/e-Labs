/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

/**
 * This class allows a hierarchical representation of a {@link ResultSet} based
 * on the following hierarchy:<br>
 * {@link School} -&gt; {@link Month} -&gt; {@link Day} -&gt; {@link File}
 */
public class StructuredResultSet {
    private SortedMap schoolsSorted;
    private Map schools;
    private int dataFileCount;
    private String key, value, time;

    public StructuredResultSet() {
        schools = new HashMap();
    }

    public School getSchool(String name) {
        return (School) schools.get(name);
    }

    public void addSchool(School school) {
        schools.put(school.getName(), school);
    }

    public Collection getSchools() {
        return schools.values();
    }

    public int getSchoolCount() {
        return schools.size();
    }

    public synchronized Collection getSchoolsSorted() {
        if (schoolsSorted == null) {
            schoolsSorted = new TreeMap(schools);
        }
        return schoolsSorted.values();
    }

    public int getDataFileCount() {
        return dataFileCount;
    }

    public void setDataFileCount(int dataFileCount) {
        this.dataFileCount = dataFileCount;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public boolean isEmpty() {
        return schools.isEmpty();
    }

    public static class School {
        private String name, city, state;
        private int blessed, stacked, dataFiles;
        private long events;
        private SortedMap monthsSorted;
        private Map months;

        public School(String name, String city, String state) {
            this.name = name;
            this.city = city;
            this.state = state;
            months = new HashMap();
        }

        public String getName() {
            return name;
        }

        public void incBlessed() {
            blessed++;
        }

        public void incStacked() {
            stacked++;
        }

        public void incEvents(int i) {
            events += i;
        }

        public void incDataFiles() {
            dataFiles++;
        }

        public Month getMonth(String month) {
            return (Month) months.get(month);
        }

        public void addDay(Month month) {
            months.put(month.getMonth(), month);
        }

        public Collection getMonths() {
            return months.values();
        }

        public int getMonthCount() {
            return months.size();
        }

        public int getDataFileCount() {
            return dataFiles;
        }

        public synchronized Collection getMonthsSorted() {
            if (monthsSorted == null) {
                monthsSorted = new TreeMap(months);
            }
            return monthsSorted.values();
        }

        public String getCity() {
            return city;
        }

        public String getState() {
            return state;
        }

        public int getBlessedCount() {
            return blessed;
        }

        public int getStackedCount() {
            return stacked;
        }

        public long getEventCount() {
            return events;
        }
    }

    public static class Month {
        private List files;
        private String month;

        public Month(String month) {
            this.month = month;
            files = new ArrayList();
        }

        public String getMonth() {
            return month;
        }

        public void addFile(File f) {
            files.add(f);
        }

        public int getFileCount() {
            return files.size();
        }

        public Collection getFiles() {
            return files;
        }
    }

    public static class File {
        private boolean blessed;
        private Boolean stacked;
        private final String lfn;
        private java.util.Date date;

        public File(String lfn) {
            this.lfn = lfn;
        }

        public boolean isBlessed() {
            return blessed;
        }

        public void setBlessed(boolean blessed) {
            this.blessed = blessed;
        }

        public String getLFN() {
            return lfn;
        }

        public Boolean getStacked() {
            return stacked;
        }

        public void setStacked(Boolean stacked) {
            this.stacked = stacked;
        }

        public java.util.Date getDate() {
            return date;
        }

        public void setDate(java.util.Date date) {
            this.date = date;
        }
    }

}
