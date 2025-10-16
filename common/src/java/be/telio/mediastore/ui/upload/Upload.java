package be.telio.mediastore.ui.upload;

import javax.servlet.http.HttpServletRequest;
import java.util.*;
import java.io.*;
import java.text.*;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.lang.*;
import org.apache.commons.io.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.util.*;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.upload.*;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.datacatalog.impl.vds.*;  
import gov.fnal.elab.usermanagement.*;
import gov.fnal.elab.usermanagement.impl.*;

public class Upload
{
    private HttpServletRequest request;
    private long delay = 0;
    private long startTime = 0;
    private long totalToRead = 0;
    private long totalBytesRead = 0;
    private int totalFiles = -1;
    private String in = "";
    private String daqId = "";
    private String uploadComments = "";
    private String uploadBenchmark = "";
    private String time = "";

    public Upload(HttpServletRequest request, Elab elab)
    {
		long lStartTime = new Date().getTime();
		String dataDir = elab.getProperties().getDataDir();
		File tempRepo = new File(dataDir + "/temp"); 
		int sizeThreshold = 0; 		
		String lfn="";              //lfn on the USERS home computer
		String fn = "";             //filename without slashes
		String ds = "";
		String detectorId = "";             //detector id
		String comments = "";       //optional comments on raw data file
		String benchmark = "";
		String usebenchmark = "";
		int channels[] = new int[4];
		
		try {
			request.setAttribute("datadir", dataDir);
			
		    UploadListener listener = new UploadListener(request, 0);
	
		    // Create a factory for disk-based file items
		    FileItemFactory factory = new NewLineConvertingMonitoredDiskFileItemFactory(
		    		sizeThreshold, tempRepo, listener); 
	
	    	// Create a new file upload handler
		    ServletFileUpload upload = new ServletFileUpload(factory);
	    	
			List<DiskFileItem> fileItems = upload.parseRequest(request); 
	    	
	    	for (DiskFileItem fi : fileItems) { 
	    		if (fi.isFormField()) {
	    			String name = fi.getFieldName();
	    			String content = fi.getString();
	    			if ("detector".equals(name)) {
	    				if (StringUtils.isBlank(content)) {
	    					System.out.println("You must enter a detector number for this data.");
	    				}
	    				else {
	    					detectorId = content;
	    				}
	    			}
	    			else if (("benchmark_"+detectorId).equals(name)) {
	    				benchmark = content;
	    			}
	    			else if ("comments".equals(name)) {
	    				if (StringUtils.isNotBlank(content)) {
	    					comments = content; 
	    				}
	    			}
	    		}
	    	}
			
			for (DiskFileItem fi : fileItems) {
				if (!fi.isFormField()) {
					lfn = fi.getName();
					if (StringUtils.isBlank(lfn)) {
	                	System.out.println("Missing file.");
	    	        }
		            //fn is the filename without slashes (which lfn has)    	       
		            fn = FilenameUtils.getName(lfn);
					if (fi.getSize() == 0) {
					    System.out.println("Your file is zero-length. You must upload a file which has some data.");
					}
	                //new algorithm for filenaming:
	   	            //name the raw file id.yyyy.mmdd.index.raw and save the original name in metadata
	       	        //index starts at 0 and increments when there are collisions with other filenames
	                Date now = new Date();
	                DateFormat df = new SimpleDateFormat("yyyy.MMdd");
	                String fnow = df.format(now);
					//even newer algorithm: use File.createTempFile!
					File f = File.createTempFile(detectorId + "." + fnow + ".", ".raw", 
					        new File(dataDir));
	               	String rawName = f.getName();
	
	               	// write the file from memory or relocate it on disk.
	               	if (fi.isInMemory()) {
	               		fi.write(f);
	               	}
	               	else {
	               		fi.getStoreLocation().renameTo(f);
	               	}
					comments = ElabUtil.stringSanitization(comments, elab, "Cosmic Upload");
	       	        System.out.println("<!-- " + rawName + " added to Catalog -->");
	       	        setIn(f.getAbsolutePath());
	       	        setDetectorId(detectorId);
	       	        setComments(comments);
	       	        setBenchmark(benchmark);
	      			long lEndTime = new Date().getTime();
	      			String uploadtime = "upload.jsp: " +String.valueOf(lEndTime - lStartTime)+ " ms";
	      			setTime(uploadtime);
	
				} //'twas a file
			} //while through the file
		} catch (Exception e) {
			System.out.println("A problem occurred while uploading your file." + 
							   "Please send an e-mail to <a href=\'mailto:e-labs@fnal.gov\'>e-labs@fnal.gov</a> with the following error: " +
								e.toString());
		}

    }
    public void setIn(String value) {
    	in = value;
    }
    public String getIn() {
    	return in;
    }
    public void setDetectorId(String value) {
    	daqId = value;
    }
    public String getDetectorId() {
    	return daqId;
    }
    public void setComments(String value) {
    	uploadComments = value;
    }
    public String getComments() {
    	return uploadComments;
    }    
    public void setBenchmark(String value) {
    	uploadBenchmark = value;
    }
    public String getBenchmark() {
    	return uploadBenchmark;
    }    
    public void setTime(String value) {
    	time = value;
    }
    public String getTime() {
    	return time;
    } 
}
