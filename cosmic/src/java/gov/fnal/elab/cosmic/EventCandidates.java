/*
 * Created on Jan 8, 2008
 * Updated Dec 2016 to add Delta-t function (JG)
 * Edit Peronja: May 29, 2018:
 * 		Removed all commented out code
 * 		Added delta T code
 */

/*
 * Created on Jan 8, 2008
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
import java.util.*;

public class EventCandidates {
    public static final String[] colNames = new String[] { "date",
            "eventCoincidence", "numDetectors", "multiplicityCount", "deltaT"};
    public static final int[] defDir = new int[] { 1, -1, -1 };

    private Collection rows;
    private Collection filteredRows;
    private Row crt;
    private Set allIds;
    private String eventNum;
    private String userFeedback;
    private String deltaTFirstId;
    private Boolean deltaTFirstIdAdded;
    private ArrayList<Integer> multiplicityFilter = new ArrayList<Integer>(); 
    
    public static final String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
    public static final TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");
    public int eventThreshold = 400000;
    public int eventNdx = 0;
    
    public EventCandidates(Comparator c) {
        rows = new TreeSet(c);
        filteredRows = new TreeSet(c);
        allIds = new HashSet();
    }

    private static final String[] STRING_ARRAY = new String[0];

    public void read(File in, File out, File outDelta, int eventStart, String en, String[] deltaTIDs)
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
        BufferedWriter bwDelta = new BufferedWriter(new FileWriter(outDelta));
        String line = br.readLine();
        Set ids = new HashSet();
        Set multiplicities = new HashSet();
        Set deltaTDetector = new HashSet();
        List deltaT = new ArrayList();
        ElabMemory em = new ElabMemory();
        //deltaTFirstIdAdded = false;
        userFeedback = "";
        while (line != null) {
            // ignore comments in the file
            if (!line.matches("^.*#.*")) {
                lineNo++;
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

                if (lineNo >= eventStart) {
                    Row row = new Row();
                    String[] arr = line.split("\\s");
                    row.setEventCoincidence(Integer.parseInt(arr[1]));
                    row.setNumDetectors(Integer.parseInt(arr[2]));
                    row.setEventNum(Integer.parseInt(arr[0]));
                    row.setLine(lineNo);
                    if (this.eventNum == null) {
                        this.eventNum = arr[0];
                    }
                    ids.clear();
                    multiplicities.clear();
                    deltaT.clear();
                    deltaTDetector.clear();
                    for (int i = 3; i < arr.length; i += 3) {
                        String[] idchan = arr[i].split("\\.");
                        idchan[0] = idchan[0].intern();
                        ids.add(idchan[0]);
                        if (!deltaTDetector.contains(idchan[0]) && deltaTDetector.size() < 3) {
                        	for (int ndx = 0; ndx < deltaTIDs.length; ndx++) {
                        		if (idchan[0].equals(deltaTIDs[ndx])) {
                                	deltaTDetector.add(idchan[0]);
                                	deltaT.add(idchan[0]);
                                	deltaT.add(arr[i+2]);                        			
                        		}
                        	}
                        }
                        String mult = arr[i].intern();
                        multiplicities.add(mult);
                        allIds.add(idchan[0]);
                    }
                    
                    row.setIds((String[]) ids.toArray(STRING_ARRAY));
                    row.setMultiplicity((String[]) multiplicities.toArray(STRING_ARRAY));
                    row.setMultiplicityCount();
                    if (deltaTIDs != null) {
                    	row.setDeltaTFirstId(deltaTIDs[0]);
                    } else {
                    	row.setDeltaTFirstId("None");
                    }
                    if (deltaT.size() > 0) {
                    	row.setDeltaT((String[]) deltaT.toArray(STRING_ARRAY));
                    } else {
                    	deltaT.add("None");
                    	deltaT.add("0");
                    	deltaT.add("None");
                    	deltaT.add("0");
                    	row.setDeltaT((String[]) deltaT.toArray(STRING_ARRAY));
                    }
                    setMultiplicityFilter(multiplicities.size());
                    
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
    	//write Delta T
		try {
			saveDeltaT(bwDelta);
		} catch (Exception e) {
			throw new Exception(e.getMessage());
		}

    	//write multiplicity summary
        try {
        	saveMultiplicitySummary(bw);
        } catch (Exception e) {
        	throw new Exception(e.getMessage());
        }

        bw.close();
        br.close();
        bwDelta.close();
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

    public void saveDeltaT(BufferedWriter bwDelta) throws Exception {
    	bwDelta.write("#Delta T between the first two detectors found:\n");
    	bwDelta.write("#First Detector, Time, Second Detector, Time, Delta T\n");
    	Object[] allR = rows.toArray();
    	for (int i = 0; i < allR.length; i++) {
    		Row r = (Row) allR[i];
    		String[] temp = r.getDeltaT();
    		//($REtime-$startTime)*1e9*86400
         	bwDelta.write(temp[0] + "," +temp[1]+","+temp[2]+","+temp[3]+","+String.valueOf(r.getDeltaTValue())+"\n");
    	}    	
    }//end of saveDeltaT
    
    public static EventCandidates read(File in, File out, File outDelta, int csc, int dir,
            int eventStart, String eventNum, String[] deltaTIDs) throws Exception {
    	EventCandidates ec = null;
    	try {
	        ec = new EventCandidates(new EventsComparator(csc, dir));
	        ec.read(in, out, outDelta, eventStart, eventNum, deltaTIDs);
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
        private double deltaT;
        private String[] deltaTComponents;
        private String deltaTFirstId;
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

        public void setDeltaTFirstId(String deltaTFirstId) {
        	this.deltaTFirstId = deltaTFirstId;
        }
        
        public String[] getDeltaT() {
        	return deltaTComponents;
        }

        public double getDeltaTValue() {
        	return deltaT;
        }
      
        public void setDeltaT(String[] deltaT) {
        	this.deltaTComponents = deltaT;
        	if (deltaT.length == 4) {
	        	if (deltaT[0].equals(deltaTFirstId)) {
	        		this.deltaT = (Double.parseDouble(deltaTComponents[1]) - Double.parseDouble(deltaTComponents[3]))*1e9*86400;
	        	} else {
	        		this.deltaT = (Double.parseDouble(deltaTComponents[3]) - Double.parseDouble(deltaTComponents[1]))*1e9*86400;        		
	        	}
        	}
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
            	double diff = (m1.getDeltaTValue()*10000) - (m2.getDeltaTValue()*10000) ;
                c = (int) diff;
            }
            else if (csc == 3) {
                c = m1.getNumDetectors() - m2.getNumDetectors();
            }
            else if (csc == 4) {
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
        }//end of EventsComparator
    }
}
