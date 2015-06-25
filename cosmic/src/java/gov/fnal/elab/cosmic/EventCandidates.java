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
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class EventCandidates {
    public static final String[] colNames = new String[] { "date",
            "eventCoincidence", "numDetectors" };
    public static final int[] defDir = new int[] { 1, -1, -1 };

    private Collection rows;
    private Row crt;
    private Set allIds;
    private String eventNum;
    private String userFeedback;
    
    public static final String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
    public static final TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");

    public EventCandidates(Comparator c) {
        rows = new TreeSet(c);
        allIds = new HashSet();
    }

    private static final String[] STRING_ARRAY = new String[0];

    public void read(File in, int eventStart, String en)
            throws Exception {
        this.eventNum = en;
        int lineNo = 1;
        BufferedReader br = new BufferedReader(new FileReader(in));
        String line = br.readLine();
        Set ids = new HashSet();
        Set multiciplicities = new HashSet();
        ElabMemory em = new ElabMemory();
        userFeedback = "";
        while (line != null) {
            // ignore comments in the file
            if (!line.matches("^.*#.*")) {
                lineNo++;
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
                    multiciplicities.clear();
                    for (int i = 3; i < arr.length; i += 3) {
                        String[] idchan = arr[i].split("\\.");
                        //idchan[0] = idchan[0].intern();
                        if (!ids.contains(idchan[0])) {
                        	ids.add(idchan[0]);
                        }
                        //String mult = arr[i].intern();
                        if (!multiciplicities.contains(arr[i])) {
                        	multiciplicities.add(arr[i]);
                        }
                        allIds.add(idchan[0]);
                    }
                    
                    row.setIds((String[]) ids.toArray(STRING_ARRAY));
                    row.setMultiplicity((String[]) multiciplicities.toArray(STRING_ARRAY));

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
                    em.refresh();
                    if (em.isCritical()) {
                    	Exception e = new Exception("Heap memory left: "+String.valueOf(em.getFreeMemory())+"MB");
                    	Elab elab = Elab.getElab(null, "cosmic");
                    	String emailMessage = 	"The code stopped processing the eventCandidates file: "+in.getAbsolutePath()+"\n"+
                    							"at line: "+line+"\n"+
                    							"Total heap memory: "+ String.valueOf(em.getTotalMemory())+"\n"+
                    							"Max heap memory: "+ String.valueOf(em.getMaxMemory())+"\n"+
                    							"Used heap memory: "+ String.valueOf(em.getUsedMemory())+"\n"+
                    							"Free heap memory: "+ String.valueOf(em.getFreeMemory())+"\n"+
                    							"Had we continued processing the server would have died with an OutOfMemoryError.";
                    							
                    	em.notifyAdmin(elab, emailMessage);
                    	userFeedback = "We stopped processing the eventCandidates file at line: <br />"+line+".<br/>" +
                    				   "Please select fewer files or files with fewer events.";
                    	throw e;
                    }
                }
            }
            line = br.readLine();
        }
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
    
    public String getUserFeedback() {
    	return this.userFeedback;
    }

    public static EventCandidates read(File in, int csc, int dir,
            int eventStart, String eventNum) throws Exception {
    	EventCandidates ec = null;
    	try {
	        ec = new EventCandidates(new EventsComparator(csc, dir));
	        ec.read(in, eventStart, eventNum);
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
