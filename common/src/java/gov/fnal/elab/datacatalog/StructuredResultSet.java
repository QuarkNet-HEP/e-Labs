/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.datacatalog.query.ResultSet;

import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
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
    	schools = new TreeMap();
    }

    public School getSchool(String name, String city, String state) {
    	return schools.get(new Triple<String, String, String>(name.toLowerCase(), city.toLowerCase(), state.toLowerCase()));
    }

    public synchronized void addSchool(School school) {
        schools.put(new Triple<String, String, String>(school.getName().toLowerCase(), school.getCity().toLowerCase(), school.getState().toLowerCase()), school);
    }

    public Collection getSchools() {
        return schools.values();
    }

    public int getSchoolCount() {
        return schools.size();
    }

    public synchronized Collection getSchoolsSorted() {
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


    public static class School implements Comparable {
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
                monthsSorted = new TreeMap();
                Iterator i = months.values().iterator();
                while (i.hasNext()) {
                    Month m = (Month) i.next();
                    monthsSorted.put(m.getDate(), m);
                }
            }
            return monthsSorted.values();
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
		
		public int compareTo(Object o) {
			int retval = 0; 
			if (o instanceof School) {
				retval = name.compareToIgnoreCase(((School) o).getName());
				if (retval == 0) {
					retval = city.compareToIgnoreCase(((School) o).getCity()); 
					if (retval == 0) {
						retval = state.compareToIgnoreCase(((School) o).getState());
					}
				}
			}
			return retval; 
		}
		
		public boolean equals(Object o) { 
			if (o instanceof School) {
				return (this.compareTo(o) == 0);
			}
			return false; 
		}
    }

    public static class Month {
        private SortedMap<Integer, Detector> detectors;
        private String month;
        private Date date;

        public Month(String month, Date date) {
            this.month = month;
            this.date = date;
            detectors = new TreeMap();
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
        
        public SortedMap getDetectors() {
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
    }
    
    public static class Detector implements Comparable {
    	private Integer detectorID; 
    	private SortedSet<File> files; 
    	
    	public Detector(int detector) {
    		this.detectorID = Integer.valueOf(detector);
    		files = new TreeSet(); 
    	}

		public int compareTo(Object o) {
			return this.detectorID.compareTo(((Detector) o).getDetectorID()); 
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
		
		public Collection getFiles() {
			return files; 
		}
		
		public int getFileCount() {
			return files.size();
		}
		
    }

    public static class File implements Comparable {
        private boolean blessed;
        private Boolean stacked;
        private final String lfn;
        private java.util.Date startDate, endDate;
        private int detector;

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
            return startDate;
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

        public int compareTo(Object o) {
            File other = (File) o;
            int d = startDate.compareTo(other.startDate);
            if (d != 0) {
                return d;
            }
            else {
                return lfn.compareTo(other.lfn);
            }
        }

		public void setDetector(int detector) {
			this.detector = detector;
		}

		public int getDetector() {
			return detector;
		}
    }
}
