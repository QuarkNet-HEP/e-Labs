package gov.fnal.elab.cosmic;

import gov.fnal.elab.analysis.*;
import gov.fnal.elab.*;
import gov.fnal.elab.util.*;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.cosmic.*;
import gov.fnal.elab.cosmic.beans.*;
import gov.fnal.elab.cosmic.bless.BlessProcess;
import gov.fnal.elab.cosmic.analysis.ThresholdTimes;
import gov.fnal.elab.notifications.*;

import java.io.*;
import java.util.*;
/**
 * Finishes up cosmic upload tasks after the split is done: 
 * -inserts metadata
 * -runs blessing
 * -creates the threshold times file(s)
 */
public class CosmicPostUploadTasks {
	public ElabAnalysis ea;
	public String message;
	public ArrayList<String> benchmarkMessages;
	public File f;
	public File fmeta;
	public String detectorId;
	public String comments;
	public String benchmark;
	public Elab elab;
	public ElabGroup auser;
	public String lfn="";
	public List splits = new ArrayList();  //for both the split name and the channel validity information

    public CosmicPostUploadTasks(ElabAnalysis ea) {
    	this.ea = ea;
		benchmarkMessages = new ArrayList<String>();
		message = "";
		this.elab = ea.getElab();
		this.f = new File((String) ea.getParameter("in"));
		this.fmeta = new File(f.getAbsolutePath() + ".meta");
		this.detectorId = (String) ea.getParameter("detectorid");
		this.comments = (String) ea.getParameter("comments");
		this.benchmark = (String) ea.getParameter("benchmark");
		this.auser = (ElabGroup) ea.getUser();
    }
    
    public void runTasks() {
    	createMetadata();
    	runBenchmark();
    	createThresholdTimes();
    	ea.setParameter("message", getMessage());
    	ea.setParameter("benchmarkMessages", getBenchmarkMessages());
    }
    
	public void createMetadata() {
		//get metadata which contains the lfns of the raw filename AND the split files
		ArrayList meta = null;	
		CatalogEntry entry;
		String rawName = f.getName();
		String cpldFrequency = "";
    	try {
		    if (fmeta.canRead()) {
		    	BufferedReader br = new BufferedReader(new FileReader(fmeta));
		        String line = null;
		        String currLFN = null;
		        String currPFN = null;
		        while ((line = br.readLine()) != null) {
		            String[] temp = line.split("\\s", 3);
	
		            //if this is a new lfn to add...
		            if(temp[0].equals("[SPLIT]") || temp[0].equals("[RAW]")){
		    	        if(meta != null && currLFN != null) {
		        	        try {
		        	            entry = DataTools.buildCatalogEntry(currLFN, meta);
		        	            elab.getDataCatalogProvider().insert(entry);
		                	} 
		        	        catch (ElabException e) {
		        				//EPeronja-585: Sql Errors when uploading data, give meaningful message
		        	        	message += "Error setting metadata for "+currLFN+":" + e.getMessage()+ "<br />";
		                	    //throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
		                    }
		                }
	
		                meta = new ArrayList();
		                currPFN = temp[1];
			            currLFN = temp[1].substring(temp[1].lastIndexOf('/') + 1);
		    	        if(temp[0].equals("[RAW]")) {
		        	        rawName = currLFN;
		                }
		                else if(temp[0].equals("[SPLIT]")) {
			                splits.add(currLFN);
		                }
	
		                //metadata for both RAW and SPLIT files
		                meta.add("origname string " + lfn); //add in the original name from the users computer to metadata
		                meta.add("blessed boolean false");
			            meta.add("group string " + auser.getName());
		    	        meta.add("teacher string " + elab.getUserManagementProvider().getTeacher(auser).getName());
		    	        meta.add("email string " + elab.getUserManagementProvider().getTeacher(auser).getEmail());
		        	    meta.add("school string " + auser.getSchool());
		            	meta.add("city string " + auser.getCity());
		                meta.add("state string " + auser.getState());
		                meta.add("year string " + auser.getYear());
		                meta.add("project string " + elab.getName());
			            comments = comments.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
		                meta.add("comments string " + comments);
		            }
		            else {
		                meta.add(line);
		                String[] tmp = line.split("\\s", 3);
		                if (tmp[0].equals("cpldfrequency")) {
			                cpldFrequency += tmp[2] + " ";
		                }
		                else if (tmp[0].equals("julianstartdate")) {
		                	Geometry geometry = new Geometry(elab.getProperties().getDataDir(), Integer.parseInt(detectorId));
		                	if (geometry != null && !geometry.isEmpty()) {
		                		SortedMap geos = geometry.getGeoEntriesBefore(tmp[2]);
		                		if (!geos.isEmpty()) {
		                			GeoEntryBean g = (GeoEntryBean) geos.get(geos.lastKey());
		                			meta.add("stacked boolean " + ("0".equals(g.getStackedState()) ? "false" : "true"));	
		                		}
		                	}
		                }
		            }
		        }   //done reading file
		        br.close();
		        
		        //do one last add at the end of reading the temp metadata file
		        if (meta != null && currLFN != null) {
		            try {					
						entry = DataTools.buildCatalogEntry(currLFN, meta);
		                elab.getDataCatalogProvider().insert(entry);
					}
					catch (ElabException e) {
						//EPeronja-585: Sql Errors when uploading data, give meaningful message
					        	message += "Error setting metadata for "+currLFN+":" + e.getMessage()+ "<br />";
						//throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
				            }
				        }
					}
				    else {
						//EPeronja-585: Sql Errors when uploading data, give meaningful message
				    	message += "Error reading metadata file: " + f.getAbsolutePath() + ".meta.<br />";
				        //throw new ElabJspException("Error reading metadata file: " + f.getAbsolutePath() + ".meta");
				    }
    	} catch (Exception ex) {
    		message += "Error setting metadata " + ex.getMessage() + "<br />";
    	}
	}//end of createMetadata
    	
	public void runBenchmark() {
		String no_benchmark_message = "You uploaded data without using a benchmark.<br />"+
				 "Your data is NOT blessed by default so it is not available to the general public.<br />"+
				 "Contact <a href=\"/elab/cosmic/teacher/forum/HelpDeskRequest.php\">Helpdesk</a> if you would like to know more about data blessing.";
	  			
		if (benchmark != null && !benchmark.equals("") && !benchmark.equals("No benchmark")) {
			if (fmeta.canRead() && splits.size() > 0) {
				BlessProcess bp = new BlessProcess();
				for (int i = 0; i < splits.size(); i++) {
					try {
						benchmarkMessages.add(bp.BlessDatafile(elab, detectorId, splits.get(i).toString(), benchmark)); 		
					} catch (Exception e) {
						benchmarkMessages.add(e.getMessage());
					}
				}
			}
		} else {
			benchmarkMessages.add(no_benchmark_message + "<br />Also check <a href=\"../analysis-blessing/benchmark-tutorial.jsp\">Tutorial on Benchmark</a>");
			//send notification about uploading without benchmark
	        ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
	        Notification n = new Notification();
	        try {
	        	ElabGroup notif_admin = elab.getUserManagementProvider().getGroup("admin"); 
		        n.setCreatorGroupId(notif_admin.getId());
		        n.setMessage(no_benchmark_message);
		        GregorianCalendar gc = new GregorianCalendar();
		        gc.add(Calendar.DAY_OF_MONTH, 2);
		        n.setExpirationDate(gc.getTimeInMillis());
		        try {
		        	np.addNotification(auser, n);
		        }
		        catch (ElabException e) {
		                System.err.println("Failed to send notification: " + e.getMessage());
		        }		
	        } catch (Exception ex) {
	        	 System.err.println("Failed to send notification: " + ex.getMessage());
	        }
		}
	}//end of runBenchmark
	
	public void createThresholdTimes() {
	  	if (fmeta.canRead() && splits.size() > 0) {
	  		String[] inputFiles = new String[splits.size()];
			for (int i = 0; i < splits.size(); i++) {
				inputFiles[i] = splits.get(i).toString();			
			}
			if (inputFiles.length > 0) {
				ThresholdTimes t = new ThresholdTimes(elab, inputFiles, detectorId);
				t.createThresholdFiles();
			}
	  	}
	}//end of createThresholdTimes
	
	public String getMessage() {
		return this.message;
	}
	
	public ArrayList<String> getBenchmarkMessages() {
		return this.benchmarkMessages;
	}
}//end of CosmicPostUploadTasks
