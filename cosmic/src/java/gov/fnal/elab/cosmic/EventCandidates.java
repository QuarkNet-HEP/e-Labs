/*
 * Created on Jan 8, 2008
 * Updated Dec 2016 to add Delta-t function (JG)
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
// for Shower delta-t only:
import java.text.DecimalFormat;
import java.math.RoundingMode;
//
import java.util.*;

public class EventCandidates {
		/* "colNames" appears to be unused.  If used, should add Delta-t as a
			 column name */
    //public static final String[] colNames = new String[] { "date",
    //        "eventCoincidence", "numDetectors", "multiplicityCount" };
		/* 
		 * defDir is "default direction of sort" for output.jsp columns
		 * Does not include Multiplicity Totals, since it's hidden by default
		 *	 1 is lowest-to-highest (ascending, "a")
		 *  -1 is highest-to-lowest (descending, "d")
		 */
		//public static final int[] defDir = new int[] { 1, -1, -1 };
    public static final int[] defDir = new int[] { 1, -1, -1, 1 };
		
    private Collection rows;
    private Collection filteredRows;
		// public static class Row() defined below
    private Row crt;
    private Set allIds;
    private String eventNum;
    private String userFeedback;
    private ArrayList<Integer> multiplicityFilter = new ArrayList<Integer>(); 
    
    public static final String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
    public static final TimeZone TIMEZONE = TimeZone.getTimeZone("UTC");
		// Maximum number of events before we need start checking if memory
		//   can handle it:
		public int eventThreshold = 400000;
    public int eventNdx = 0;
		
    public EventCandidates(Comparator c) {
        rows = new TreeSet(c);
        filteredRows = new TreeSet(c);
        allIds = new HashSet();
    }

		// Dummy variables used to cast using Set/List.toArray()
    private static final String[] STRING_ARRAY = new String[0];
    // private static final Double[] DOUBLE_ARRAY = new Double[0];
		
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
				// Change ids from HashSet to ArrayList to keep ordering for deltaT
				//Set ids = new HashSet();
        List<String> ids = new ArrayList<String>();
        Set multiplicities = new HashSet();
        ElabMemory em = new ElabMemory();
				// For deltaT:
				////List<Double> firstHitTimes = new ArrayList<Double>();
				////Double deltaT = new Double(0.0);
				////Integer[] dTDetectors = FindDeltaTDetectors(in);
				//String detOne = null;
				//String detTwo = null;
				//int dtSign = 0;
				//
				
        userFeedback = "";
        while (line != null) {
            // ignore any line with "#" (comment)
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
								// For every line of the input file that isn't null or a comment
								//   and is gte the input eventStart:
								if (lineNo >= eventStart) {
										Row row = new Row();
										// Each line of the eventCandidates file is divided at spaces
										//   into the array arr[]
										String[] arr = line.split("\\s");
										// The first three row elements:
                    row.setEventNum(Integer.parseInt(arr[0]));
                    if (this.eventNum == null) {
                        this.eventNum = arr[0];
                    }
                    row.setEventCoincidence(Integer.parseInt(arr[1]));
                    row.setNumDetectors(Integer.parseInt(arr[2]));
                    row.setLine(lineNo);

										// remaining elements in sets of three
                    ids.clear();
                    multiplicities.clear();
										////firstHitTimes.clear();
										/* Loop over each individual line of eventCandidates.
											 Note the increment of 3 such that arr[i] will always
											   be <String> detector.channel */
										for (int i = 3; i < arr.length; i += 3) {
												String[] idchan = arr[i].split("\\.");
												/* For every idchan[0]=detector,
													 Add the detector to ids[] if it isn't there already
													 Add the time of that first hit to firstHitTimes[] */
												if (!ids.contains(idchan[0])) {
														ids.add(idchan[0]);
														////firstHitTimes.add(Double.parseDouble(arr[i+2]));
												}
												/* Add <String> dectector.channel to multiplicities[]
													 if it isn't there already */
												String mult = arr[i].intern();
                        multiplicities.add(mult);
												/* Add the detector to allIds[] w/o regard to whether
													 it's there already */
                        allIds.add(idchan[0]);
										}

										/* deltaT additions - JG Mar2017 */
										/* 
										 * By convention, we compare the first two detectors to fire,
										 *   even if there are more than two in the analysis.
										 * deltaT compares the first two detectors to fire,
										 *	 as recorded on the first row (eventNum=1)
										 * Determine these from ids[] after constructing it for
										 *   that row
										 * Is there any danger that this code can be executed
										 *   with eventNum != 1 as the first event?
										 */
										//if (Integer.parseInt(arr[0]) == 1) {
										//		detOne = ids.get(0);
										//	  detTwo = ids.get(1);
										//		dtSign = Integer.signum(Integer.parseInt(detOne) -
										//														Integer.parseInt(detTwo));
										//}
										
										//if (detOne != null && detTwo != null) {
										//		deltaT = dtSign*(firstHitTimes.get(ids.indexOf(detOne)) -
										//										 firstHitTimes.get(ids.indexOf(detTwo)));
										//}
										//else {
										//		deltaT = 0.0;
										//		// throw error
										//}

										////if( ids.contains(dTDetectors[0]) && ids.contains(dTDetectors[1]) ) {
										////deltaT = firstHitTimes.get(ids.indexOf(dTDetectors[1])) - firstHitTimes.get(ids.indexOf(dTDetectors[0]));
										////}
										////else {
										////		deltaT = null;
										////}
										
                    row.setIds((String[]) ids.toArray(STRING_ARRAY));
                    row.setMultiplicity((String[]) multiplicities.toArray(STRING_ARRAY));
                    row.setMultiplicityCount();
                    setMultiplicityFilter(multiplicities.size());
										////row.setDeltaT(deltaT);
										
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
						// Read in the next line
            line = br.readLine();
        }
        // Set the event position
				Object[] allR = rows.toArray();
				for (int i = 0; i < allR.length; i++) {
						Row r = (Row) allR[i];
						if (r.getEventNum() == Integer.parseInt(eventNum)) {
								eventNdx = i;
								break;
						}
				}
        // Write multiplicity summary
        try {
        	saveMultiplicitySummary(bw);
        } catch (Exception e) {
        	throw new Exception(e.getMessage());
        }
        bw.close();
        br.close();
    } // end of read()
    
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
    } // end of saveMultiplicitySummary()

		/* 
		 * Added Mar2017 JG
		 * Find the two detectors used for DeltaT comparision, defined as 
		 *   the first two detectors listed in the first row of eventCandidates 
		 *   that includes two distinct detectors
		 * Integer[] instead of int[] to allow for null values
		 */
		private Integer[] FindDeltaTDetectors(File infile) throws IOException {
				//try {
				////BufferedReader br = new BufferedReader(new FileReader(infile));
				//} catch(FileNotFoundException fnfe) { 
				//System.out.println(fnfe.getMessage());
				//}
				////String line = br.readLine();
				////List<String> ids = new ArrayList<String>();
				
				////while (line != null) {
		////String[] arr = line.split("\\s");
						
		////		ids.clear();
						// loop over elements of a single line to form ids[] for that line:
		////		for (int i=3; i< arr.length; i+=3) {
		////				String[] detchan = arr[i].split("\\.");
		////				detchan[0] = detchan[0].intern();
		////				ids.add(detchan[0]);
		////		}
						
						// check ids[] for Dt conditions
		////		if ((ids.size() > 1) && (ids.get(0) != null) && (ids.get(1) != null)) {
		////				Integer[] dets = {Integer.parseInt(ids.get(0)), Integer.parseInt(ids.get(1))};
		////				br.close();
		////				return dets;
		////		}
						// if not found, advance to the next line
		////		else {
		////				line = br.readLine();
		////		}
		////}
				// if not found in any line, there is no valid set for DeltaT
				////Integer[] dets = {null,null};
				////br.close();
				////return dets;
		}

		// read() method overload
		// Accepts int csc, int dir input and returns EventCandidates object
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
				//private Double deltaT;
				//private Integer testInteger;
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

        public void setDeltaT(Double deltaT) {
				////this.deltaT = deltaT;
        }

				public Double getDeltaT() {
				////		return deltaT;
				}
					
				public String getDeltaTShower() {
				// Returns <String> deltaT in nanoseconds to one decimal place
				////DecimalFormat df = new DecimalFormat("#.0");
				////df.setRoundingMode(RoundingMode.HALF_UP);
						// deltaT is calculated in days.  Convert to ns for display
						////return df.format(deltaT*86400e9);
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

		/* A class to manage sorting of output.jsp rows based on 
			 comparison of column fields */
    public static class EventsComparator implements Comparator {
        /* csc is the column sort index */
				private int csc;
        /* dir is the direction of sort
				 *   "a" for "ascending" maps to +1
				 *   "d" for "descending" maps to -1 */
        private int dir;

        public EventsComparator(int csc, int dir) {
            this.csc = csc;
            this.dir = dir;
        }

				/* Number of columns in output.jsp hard-coded here */
        public int compare(Object o1, Object o2) {
            /* 
						 *  Order two EventCandidates.Row() objects by comparing 
						 *  columns according to input csc \in (0,1,2,3,4)
						 *  0 = Event Date            (Date)
						 *  1 = Hit Coincidence       (int)
						 *  2 = Detector Coincidence  (int)
						 *  3 = Delta-t               (Double, null)
						 *  4 = Multiplicity Totals   (int)
						 */
						Row m1 = (Row) o1;
            Row m2 = (Row) o2;
            int c = 0;
						/*
						 * c < 0  Row 1 criteria ordered before Row 2 criteria
						 * c = 0  Row 1 criteria identical to Row 2 criteria
						 * c > 0  Row 1 criteria ordered after Row 2 criteria
						 */
            if (csc == 0) {
                c = m1.getDate().compareTo(m2.getDate());
            }
            else if (csc == 1) {
                c = m1.getEventCoincidence() - m2.getEventCoincidence();
            }
            else if (csc == 2) {
                c = m1.getNumDetectors() - m2.getNumDetectors();
            }
						// added 29Mar2016 JG for DeltaT analysis
						////else if (csc == 3) {
						////if ( (m1.getDeltaT() != null) && (m2.getDeltaT() != null) ) {
						////		c = m1.getDeltaT().compareTo(m2.getDeltaT());
						////}
								/* If exactly one deltaT is null, non-null ordered before null */
						////	else if ( (m1.getDeltaT() != null) && (m2.getDeltaT() == null) ) {
						////		c = +1;
						////	}
						////else if ( (m1.getDeltaT() == null) && (m2.getDeltaT() != null) ) {
						////		c = -1;
						////}
								/* If both are null, default to sort by line number and return */
								////else {
						////return m1.getLine() - m2.getLine();
						////}
						////}
            ////else if (csc == 4) {
						////c = m1.getMultiplicityCount() - m2.getMultiplicityCount();
            ////}
						else if (csc == 3) {
                c = m1.getMultiplicityCount() - m2.getMultiplicityCount();
            }



						/* If the two criteria are equal: */
            if (c == 0) {
								/* If Dates are equal, default to Hit Coincidence (col 1) sort, 
								 * modified by input dir */
                if (csc == 0) {
                    return dir * (m1.getEventCoincidence() - m2.getEventCoincidence()); 
                }
								/* Otherwise, default to sort by line number, unmodified by dir */
								else {
										/* int Row.getLine() returns the row line number */
										return m1.getLine() - m2.getLine();
                }
            }
						
						/* If the two criteria are unequal, return c modified by input dir */
            else {
                return dir * c;
            }
        }
    }
}
