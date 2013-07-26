/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog;

import edu.emory.mathcs.backport.java.util.Collections;
import gov.fnal.elab.datacatalog.query.ResultSet;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

import com.mallardsoft.tuple.*;

import org.apache.axis.types.Day;

/**
 * This class allows a hierarchical representation of a {@link ResultSet} based
 * on the following hierarchy:<br>
 * {@link School} -&gt; {@link Month} -&gt; {@link Day} -&gt; {@link File}
 */
public class StructuredResultSet {
	private SortedMap<Triple<String, String, String>, School> schools; 
    private int dataFileCount;
    private String key, value, time;
    private java.util.Date startDate, endDate;

    public StructuredResultSet() {
    	schools = new TreeMap<Triple<String, String, String>, School>();
    }

    public School getSchool(String name, String city, String state) {
    	return schools.get(new Triple<String, String, String>(name.toLowerCase(), city.toLowerCase(), state.toLowerCase()));
    }

    public synchronized void addSchool(School school) {
        schools.put(new Triple<String, String, String>(school.getName().toLowerCase(), school.getCity().toLowerCase(), school.getState().toLowerCase()), school);
    }

    public Collection<School> getSchools() {
        return schools.values();
    }

    public int getSchoolCount() {
        return schools.size();
    }

    public synchronized Collection<School> getSchoolsSorted() {
    	return this.getSchools();
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
    
    public java.util.Date getEndDate() {
        return endDate;
    }

    public void setEndDate(java.util.Date endDate) {
        this.endDate = endDate;
    }

    public java.util.Date getStartDate() {
        return startDate;
    }

    public void setStartDate(java.util.Date startDate) {
        this.startDate = startDate;
    }

    public static class School implements Comparable<School> {
        private String name, city, state;
        private int blessed, stacked, dataFiles;
        private long events;
        private Map<String, Month> months;

        public School(String name, String city, String state) {
            this.name = name;
            this.city = city;
            this.state = state;
            months = new HashMap<String, Month>();
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
            return months.get(month);
        }

        public void addDay(Month month) {
            months.put(month.getMonth(), month);
        }

        public Collection<Month> getMonths() {
            return months.values();
        }

        public int getMonthCount() {
            return months.size();
        }

        public int getDataFileCount() {
            return dataFiles;
        }
        
        public synchronized Collection<Month> getMonthsSorted() {
            List<Month> monthsSorted = new ArrayList<Month>(months.values()); 
            Collections.sort(monthsSorted, new Month.DATE_ORDER()); 
            return monthsSorted; 
        }

        public String getCity() {
            return city;
        }
        
        public void setCity(String city) {
        	this.city = city;
        }

        public String getState() {
            return state;
        }
        
        public void setState(String state) {
        	this.state = state;
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
		
		public int compareTo(School s) {
			int retval = 0; 
			retval = name.compareToIgnoreCase(s.getName());
			if (retval == 0) {
				retval = city.compareToIgnoreCase(s.getCity()); 
				if (retval == 0) {
					retval = state.compareToIgnoreCase(s.getState());
				}
			}
			return retval; 
		}
		
		public boolean equals(School s) { 
			return this.compareTo(s) == 0; 
		}
    }

    public static class Month {
        private SortedMap<Integer, Detector> detectors;
        private String month;
        private Date date;

        public Month(String month, Date date) {
            this.month = month;
            this.date = date;
            detectors = new TreeMap<Integer, Detector>();
        }

        public String getMonth() {
            return month;
        }
        
        private void addDetector(Integer detectorID) {
        	if (!detectors.containsKey(detectorID)) {
        		Detector d = new Detector(detectorID.intValue());
        		detectors.put(detectorID, d);
        	}
        }

        public void addFile(File f) {
        	Integer d = Integer.valueOf(f.getDetector());
        	if (!detectors.containsKey(d)) {
        		this.addDetector(d);
        	}
            detectors.get(d).addFile(f);
        }
        
        public SortedMap<Integer, Detector> getDetectors() {
        	return detectors;
        }

        public int getFileCount() {
            int count = 0;
        	for (Detector d : detectors.values()) {
        		count += d.getFileCount();
        	}
        	return count; 
        }
        
        public Date getDate() {
            return date;
        }
        
        public static class DATE_ORDER implements Comparator<Month> {
    		@Override
    		public int compare(Month o1, Month o2) {
    			return o1.getDate().compareTo(o2.getDate());
    		}
        }
    }
    
    public static class Detector implements Comparable<Detector> {
    	private Integer detectorID; 
    	private SortedSet<File> files; 
    	
    	public Detector(int detector) {
    		this.detectorID = Integer.valueOf(detector);
    		files = new TreeSet<File>(); 
    	}

		public int compareTo(Detector d) {
			return this.detectorID.compareTo(d.getDetectorID()); 
		}

		public void setDetectorID(Integer detectorID) {
			this.detectorID = detectorID;
		}

		public Integer getDetectorID() {
			return detectorID;
		}
		
		public void addFile(File f) {
			files.add(f);
		}
		
		public Collection<File> getFiles() {
			return files; 
		}
		
		public int getFileCount() {
			return files.size();
		}
		
    }

    public static class File implements Comparable<File> {
        private boolean blessed;
        private Boolean stacked;
        private final String lfn;
        private java.util.Date startDate, endDate, creationDate;
        private int detector;
        private long totalEvents;
        private long channel1, channel2, channel3, channel4;
        private String blessfile;
        private String conreg0, conreg1, conreg2, conreg3;

        //EPeronja-04/25/2013: Benchmark File attributes
        private Boolean benchmarkfile, benchmarkdefault;
        private String benchmarklabel, benchmarkreference, benchmarkfail;
        //EPeronja-06/25/2013: 289- Lost functionality on data search
        private String group;
        
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

        public void setBlessFile(String blessfile){
        	this.blessfile = blessfile;
        }
        
        public String getBlessFile() {
        	return this.blessfile;
        }
        public void setConReg0(String conreg0){
        	this.conreg0 = conreg0;
        }
        public String getConReg0() {
        	return this.conreg0;
        }
        public void setConReg1(String conreg1){
        	this.conreg1 = conreg1;
        }
        public String getConReg1() {
        	return this.conreg1;
        }
        public void setConReg2(String conreg2){
        	this.conreg2 = conreg2;
        }
        public String getConReg2() {
        	return this.conreg2;
        }
        public void setConReg3(String conreg3){
        	this.conreg3 = conreg3;
        }
        public String getConReg3() {
        	return this.conreg3;
        }
        public java.util.Date getDate() {
            return startDate;
        }

        //EPeronja-06/25/2013: 289- Lost functionality on data search
        public String getGroup() {
        	return this.group;
        }
        public void setGroup(String group) {
        	this.group = group;
        }
        public java.util.Date getCreationDate() {
        	return this.creationDate;
        }
        public void setCreationDate(java.util.Date date) {
        	this.creationDate = date;
        }
        public Long getChannel1() {
        	return this.channel1;
        }
        public void setChannel1(Long channel) {
        	this.channel1 = channel;
        }
        public Long getChannel2() {
        	return this.channel2;
        }
        public void setChannel2(Long channel) {
        	this.channel2 = channel;
        }
        public Long getChannel3() {
        	return this.channel3;
        }
        public void setChannel3(Long channel) {
        	this.channel3 = channel;
        }
        public Long getChannel4() {
        	return this.channel4;
        }
        public void setChannel4(Long channel) {
        	this.channel4 = channel;
        }

        public void setDate(java.util.Date date) {
            this.startDate = date;
        }

        public java.util.Date getEndDate() {
            return endDate;
        }

        public void setEndDate(java.util.Date endDate) {
            this.endDate = endDate;
        }

        public java.util.Date getStartDate() {
            return startDate;
        }

        public void setStartDate(java.util.Date startDate) {
            this.startDate = startDate;
        }

        public int compareTo(File f) {
            int d = startDate.compareTo(f.startDate);
            if (d != 0) {
                return d;
            }
            else {
                return lfn.compareTo(f.lfn);
            }
        }

		public void setDetector(int detector) {
			this.detector = detector;
		}

		public int getDetector() {
			return detector;
		}
		
		public long getTotalEvents() {
			return totalEvents; 
		}
		
		public void setTotalEvents(long totalEvents) {
			this.totalEvents = totalEvents; 
		}
    }
}
