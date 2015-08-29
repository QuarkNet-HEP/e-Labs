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
import java.text.*;
/**
 * Finishes up cosmic upload tasks after the split is done: 
 * -inserts metadata
 * -runs blessing
 * -creates the threshold times file(s)
 */
public class CosmicPostUploadTasks {
	public ElabAnalysis ea;
	public String message;
	public String gpsMessage;
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
		gpsMessage = "";
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
    	ea.setParameter("gspMessage", getGPSMessage());
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
		        String geoLatitude = "";
		        String geoLongitude = "";
		        String metaLatitude = "";
		        String metaLongitude = "";
		        
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
		                			geoLatitude = g.getFormattedLatitude();
		                			if (geoLatitude == null) { geoLatitude = ""; }
		                			geoLongitude = g.getFormattedLongitude();
		                			if (geoLongitude == null) { geoLongitude = ""; }
		                			meta.add("stacked boolean " + ("0".equals(g.getStackedState()) ? "false" : "true"));	
		                		}
		                	}
		                }
		                else if (tmp[0].equals("avglatitude")) {
		                	if (tmp[2] != null) {
		                		metaLatitude = tmp[2];
		                	}
		                }
		                else if (tmp[0].equals("avglongitude")) {
		                	if (temp[2] != null) {
		                		metaLongitude = tmp[2];
		                	}
		                }
		            }
		        }   //done reading file
		        br.close();
		        
		        if (!metaLatitude.equals("") && !metaLongitude.equals("") && !geoLatitude.equals("") && !geoLongitude.equals("")) {
		        	Double latOffset = getGPSOffset(metaLatitude, geoLatitude);
		        	Double lonOffset = getGPSOffset(metaLongitude, geoLongitude);

		        	//5K tolerance
		        	if (latOffset > 5000 || lonOffset > 5000) {
		        		gpsMessage = "Your detector GPS reports a position greater than 5 kilometers ("+String.format("%.2f", latOffset)+" meters for the latitude<br />"+
		        					 "and "+String.format("%.2f", lonOffset)+" meters for the longitude) <br />"+
		        					 "from the Geometry on file in the CR e-Lab. Please check your listed Geometry and effective Entry Date.<br />";
		        	} else {
		        		gpsMessage = "We have found an acceptable offset of "+String.format("%.2f", latOffset)+" meters for the latitude<br />"+
		        					 "and "+String.format("%.2f", lonOffset)+" meters for the longitude between your uploaded data and the<br />"+
		        					 "geometry configuration.<br />";
		        	}
		        } else {
		        	gpsMessage = "We were unable to compare the GPS data from your file to the geometry.<br />"+
		        				"Please check your geometry configuration and include the GD command with your data-taking.<br />";
		        }
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
	
	public Double getGPSOffset(String meta, String geo) {
		Double offset = 0.0;
		String[] metaParts = meta.split("\\.");
		String[] geoParts = geo.split("(:)|(\\.)");
		metaParts[2] = String.format("%1$-6s", metaParts[2]).replace(' ', '0');
		geoParts[2] = String.format("%1$-6s", geoParts[2]).replace(' ', '0');		
		Double metaPos = Double.parseDouble(metaParts[0])+(Double.parseDouble(metaParts[1])/60)+(Double.parseDouble(metaParts[2])/1000000/60);
		Double geoPos = Double.parseDouble(geoParts[0])+(Double.parseDouble(geoParts[1])/60)+(Double.parseDouble(geoParts[2])/1000000/60);
		Double posOff = metaPos - geoPos;
		offset = calculateDegreesToMeters(posOff, metaPos);
		return offset;
	}//end of getGPSOffset
	
	public Double calculateDegreesToMeters(Double posOff, Double metaPos) {
		Double xoff = 0.0;
		Double radius = 6378137.0; //radius of the earth
		Double pi = 3.1415926535897932;
		Double perimeter = radius*2*pi;
		xoff = Math.abs(posOff*(Math.cos(metaPos*Math.PI/180)*perimeter/360));
		return xoff;
	}//end of calculateDegreesToMeters
	
	public String getMessage() {
		return this.message;
	}

	public String getGPSMessage() {
		return this.gpsMessage;
	}

	public ArrayList<String> getBenchmarkMessages() {
		return this.benchmarkMessages;
	}
}//end of CosmicPostUploadTasks
