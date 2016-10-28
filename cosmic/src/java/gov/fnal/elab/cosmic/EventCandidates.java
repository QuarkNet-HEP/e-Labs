/*
 * Created on Jan 8, 2008
 * Updated Oct 2016 to add Delta-t function (JG)
 */
package gov.fnal.elab.cosmic;

import gov.fnal.elab.Elab;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.util.NanoDate;
import gov.fnal.elab.util.ElabMemory;

import org.apache.commons.lang.time.DateFormatUtils;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
// for Shower delta-t only (2):
import java.text.DecimalFormat;
import java.math.RoundingMode;
import java.util.*;

public class EventCandidates {
    public static final String[] colNames = new String[] { "date",
            "eventCoincidence", "numDetectors", "multiplicityCount" };
    public static final int[] defDir = new int[] { 1, -1, -1 };

    private Collection rows;
    private Collection filteredRows;
    private Row crt;
    private Set allIds;
    private String eventNum;
    private String userFeedback;
    private ArrayList<Integer> multiplicityFilter = new ArrayList<Integer>(); 
    
    public static final String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
    public static final TimeZone TIMEZONE = TimeZone.getTimeZone("UTC");
		public int eventThreshold = 400000;
    public int eventNdx = 0;
    // Cosmic data files store time values in days.
		// Multiply by timeUnitNano to convert to nanoseconds
		public Double timeUnitNano = 86400.0*1e9;
		
    public EventCandidates(Comparator c) {
        rows = new TreeSet(c);
        filteredRows = new TreeSet(c);
        allIds = new HashSet();
    }

		// "templates" used to cast using Set/List.toArray()
    private static final String[] STRING_ARRAY = new String[0];
    private static final Double[] DOUBLE_ARRAY = new Double[0];
		
    public void read(File in, File out, int eventStart, String en)
            throws Exception {
    	Elab elab = Elab.getElab(null, "cosmic");
    	String et = elab.getProperty("event.threshold");
    	if (et != null && !et.equals("")) {
    		eventThreshold = Integer.parseInt(et);
    	}
        this.eventNum = en;
        int lineNo = 1;
        BufferedReader br = new BufferedReader(new FileReader(in));
        BufferedWriter bw = new BufferedWriter(new FileWriter(out));
        String line = br.readLine();
        Set ids = new HashSet();
        Set multiplicities = new HashSet();
				List<Double> deltaT = new ArrayList<Double>();
        ElabMemory em = new ElabMemory();
        userFeedback = "";
        while (line != null) {
            // ignore comments in the file
            if (!line.matches("^.*#.*")) {
                lineNo++;
								// memory management
								if (lineNo > eventThreshold) {
                    em.refresh();
                    if (em.isCritical()) {
                    	Exception e = new Exception("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB");
                    	String emailMessage = 	"The code stopped processing the eventCandidates file: "+in.getAbsolutePath()+"\n"+
                    							"at line: "+line+"\n"+
                    							em.getMemoryDetails();
                    	userFeedback = "We stopped processing the eventCandidates file at line: <br />"+line+".<br/>" +
                    				   "Please select fewer files or files with fewer events.";
                    	throw e;
                    }
                }

								// parse the eventCandidates input file
                if (lineNo >= eventStart) {
                    Row row = new Row();
										// arr[] is the array that holds all individual
										//   elements of a single row
										String[] arr = line.split("\\s");
										// The first three elements:
                    row.setEventCoincidence(Integer.parseInt(arr[1]));
                    row.setNumDetectors(Integer.parseInt(arr[2]));
                    row.setEventNum(Integer.parseInt(arr[0]));
                    row.setLine(lineNo);
                    if (this.eventNum == null) {
                        this.eventNum = arr[0];
                    }

										// remaining elements in sets of three
                    ids.clear();
                    multiplicities.clear();
										deltaT.clear();
										Double firstHit = Double.parseDouble(arr[5]);
										for (int i = 3; i < arr.length; i += 3) {
												// arr[i] will always be detector.channel
												String[] idchan = arr[i].split("\\.");
												//idchan[0] = idchan[0].intern();
                        //ids.add(idchan[0]);
                        if (!ids.contains(idchan[0])) {
                        	ids.add(idchan[0]);
													// note that deltaT[0]=0 always
													Double nowHit = Double.parseDouble(arr[i+2]);
													deltaT.add(nowHit-firstHit);
												}
												String mult = arr[i].intern();
                        multiplicities.add(mult);
                        //if (!multiplicities.contains(arr[i])) {
                        //	multiplicities.add(arr[i]);
                        //}
                        allIds.add(idchan[0]);
										}
                    
                    row.setIds((String[]) ids.toArray(STRING_ARRAY));
                    row.setMultiplicity((String[]) multiplicities.toArray(STRING_ARRAY));
                    row.setMultiplicityCount();
                    setMultiplicityFilter(multiplicities.size());
										row.setDeltaT((Double[]) deltaT.toArray(DOUBLE_ARRAY));

										// Julian Date
                    String jd = arr[4];
                    String partial = arr[5];

                    // get the date and time of the shower
                    NanoDate nd = ElabUtil.julianToGregorian(Integer
                            .parseInt(jd), Double.parseDouble(partial));
                    row.setDate(nd);
                    rows.add(row);
                    if (this.eventNum.equals(arr[0])) {
                        crt = row;
                    }
                }
             }
            line = br.readLine();
        }
        //set the event position
				Object[] allR = rows.toArray();
				for (int i = 0; i < allR.length; i++) {
						Row r = (Row) allR[i];
						if (r.getEventNum() == Integer.parseInt(eventNum)) {
								eventNdx = i;
								break;
						}
				}
        //write multiplicity summary
        try {
        	saveMultiplicitySummary(bw);
        } catch (Exception e) {
        	throw new Exception(e.getMessage());
        }
        bw.close();
        br.close();
    }
    
    public Collection getRows() {
        return rows;
    }
    
    public Collection getAllIds() {
        return allIds;
    }
    
    public Row getCurrentRow() {
        return crt;
    }
    
    public String getEventNum() {
        return this.eventNum;
    }
    
    public int getEventIndex() {
        return this.eventNdx;
    }

    public String getUserFeedback() {
    	return this.userFeedback;
    }

    public ArrayList<Integer> getMultiplicityFilter() {
    	Collections.sort(multiplicityFilter);
    	return this.multiplicityFilter;
    }
    
    public void setMultiplicityFilter(int length) {
    	if (!this.multiplicityFilter.contains(length)) {
    		this.multiplicityFilter.add(length);
    	}
    }

    public Collection filterByMuliplicity(int filter) {    	
    	filteredRows.clear();
    	for (Iterator it = rows.iterator(); it.hasNext();) {
    		Row r = (Row) it.next();
    		if (r.getMultiplicityCount() == filter) {
    			filteredRows.add(r);
    		}
    	}
    	return filteredRows;
    }
    
    public void saveMultiplicitySummary(BufferedWriter bw) throws Exception {
        bw.write("Hit Counters, Count\n");
    	Collections.sort(multiplicityFilter);
        for (int x = 0; x < multiplicityFilter.size(); x++) {
        	int count = 0;
        	for (Iterator it = rows.iterator(); it.hasNext();) {
        		Row r = (Row) it.next();
        		if (r.getMultiplicityCount() == multiplicityFilter.get(x)) {
        				count += 1;
        		}
        	}
        	bw.write(String.valueOf(multiplicityFilter.get(x))+","+String.valueOf(count)+"\n");
        }
    }//end of saveMultiplicitySummary
    
    public static EventCandidates read(File in, File out, int csc, int dir,
            int eventStart, String eventNum) throws Exception {
    	EventCandidates ec = null;
    	try {
	        ec = new EventCandidates(new EventsComparator(csc, dir));
	        ec.read(in, out, eventStart, eventNum);
    	} catch (Exception e) {
    		System.out.println("Error in EventCandidates: "+e.getMessage());
    	}
        return ec;
    }

    public static class Row {
        private int eventCoincidence;
        private int numDetectors;
        private int eventNum;
        private int line;
        private Date date;
        private String[] ids;
        private String[] multiplicity;
				private Double[] deltaT;
				private int multiplicityCount;

        public int getEventCoincidence() {
            return eventCoincidence;
        }

        public void setEventCoincidence(int eventCoincidence) {
            this.eventCoincidence = eventCoincidence;
        }

        public int getNumDetectors() {
            return numDetectors;
        }

        public void setNumDetectors(int numDetectors) {
            this.numDetectors = numDetectors;
        }

        public int getEventNum() {
            return eventNum;
        }

        public void setEventNum(int eventNum) {
            this.eventNum = eventNum;
        }

        public int getLine() {
            return line;
        }

        public void setLine(int line) {
            this.line = line;
        }

        public Date getDate() {
            return date;
        }
        
        public String getDateF() {
        	return DateFormatUtils.format(date, DATEFORMAT, TIMEZONE);
        }

        public void setDate(Date date) {
            this.date = date;
        }

        public String[] getIds() {
            return ids;
        }

        public void setIds(String[] ids) {
            this.ids = ids;
        }

        public String[] getMultiplicity() {
            return multiplicity;
        }

        public void setMultiplicity(String[] multiplicity) {
            this.multiplicity = multiplicity;
        }
        
        public int getMultiplicityCount() {
        	return multiplicityCount;
        }
        
        public void setMultiplicityCount() {
        	this.multiplicityCount = multiplicity.length;
        }

        public void setDeltaT(Double[] deltaT) {
            this.deltaT = deltaT;
        }

				public Double[] getDeltaT() {
						return deltaT;
				}

				public Double getDeltaTShower() {
				// returns deltaT[1] in ns, reported to tenths place
				// format specific to Shower Analysis		
						DecimalFormat df = new DecimalFormat("#.0");
						df.setRoundingMode(RoundingMode.HALF_UP);
						return df.format(deltaT[1]*timeUnitNano);
				}
				
        public TreeMap<String,String> getIdsMult() {
        	TreeMap<String,String> idsMult = new TreeMap<String, String>();
        	for (int i=0; i < ids.length; i++) {
        		int counter = 0;
        		for (int j=0; j < multiplicity.length; j++) {
        			if (multiplicity[j].startsWith(ids[i])) {
        				counter += 1;
        			}
        		}
        		idsMult.put(ids[i], String.valueOf(counter));
        	}
        	return idsMult;
        }
    }

    public static class EventsComparator implements Comparator {
        private int csc;
        private int dir;

        public EventsComparator(int csc, int dir) {
            this.csc = csc;
            this.dir = dir;
        }

        public int compare(Object o1, Object o2) {
            Row m1 = (Row) o1;
            Row m2 = (Row) o2;
            int c = 0;
            if (csc == 0) {
                c = m1.getDate().compareTo(m2.getDate());
            }
            else if (csc == 1) {
                c = m1.getEventCoincidence() - m2.getEventCoincidence();
            }
            else if (csc == 2) {
                c = m1.getNumDetectors() - m2.getNumDetectors();
            }
            else if (csc == 3) {
                c = m1.getMultiplicityCount() - m2.getMultiplicityCount();
            }
            if (c == 0) {
                if (csc == 0) {
                    return dir * (m1.getEventCoincidence() - m2.getEventCoincidence()); 
                }
                else {
                    return m1.getLine() - m2.getLine();
                }
            }
            else {
                return dir * c;
            }
        }
    }
}
