package be.telio.mediastore.ui.upload;
import java.util.*;
import java.io.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.*;
import java.text.*;
import java.util.Collection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
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

/**
 * //EPeronja-10/22/2025: new upload code
 */

@WebServlet("/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 500, 
    maxFileSize = 1024 * 1024 * 1000,      
    maxRequestSize = 1024 * 1024 * 5000    
)
public class Upload extends HttpServlet
{
    private HttpServletRequest request;
    private String in = "";
    private String daqId = "";
    private String uploadComments = "";
    private String uploadBenchmark = "";
    private String time = "";
    
    public Upload(HttpServletRequest request, Elab elab) throws Exception
    {
		long lStartTime = new Date().getTime();
		String dataDir = elab.getProperties().getDataDir();
		String detectorId = "";     //detector id
		String comments = "";       //optional comments on raw data file
		String benchmark = "";
		String usebenchmark = "";
		System.out.println("it gets here");
		/*		
		try {
		    UploadListener listener = new UploadListener(request, 0);
		    Collection<Part> parts = request.getParts();
		    for (Part part : parts) {
                String fileName = part.getSubmittedFileName();
                if (fileName != null) { // It's a file part
                	System.out.println(fileName);
					if (StringUtils.isBlank(fileName)) {
	                	throw new Exception("Missing file.");
	    	        }
					if (part.getSize() == 0) {
						throw new Exception("Your file is zero-length. You must upload a file which has some data.");
					}
	                //new algorithm for filenaming:
	   	            //name the raw file id.yyyy.mmdd.index.raw and save the original name in metadata
	       	        //index starts at 0 and increments when there are collisions with other filenames
	                Date now = new Date();
	                DateFormat df = new SimpleDateFormat("yyyy.MMdd");
	                String fnow = df.format(now);
	                System.out.println(dataDir);
					File f = File.createTempFile(detectorId + "." + fnow + ".", ".raw", new File(dataDir));
	               	String rawName = f.getName();
	               	System.out.println("<!-- " + rawName + " added to Catalog -->");					
	               	InputStream is = part.getInputStream(); 
	               	Files.copy(is, f.toPath(), StandardCopyOption.REPLACE_EXISTING);
	                is.close();
	                setIn(f.getAbsolutePath());
                } else {		    
			    	String partName = part.getName();
			    	String fieldValue = request.getParameter(partName);
			    	if ("detector".equals(partName)) {
			    		if (StringUtils.isBlank(fieldValue)) {
	    					System.out.println("You must enter a detector number for this data.");		    			
			    		} else {
			    			detectorId = fieldValue;
			    		}} 
			    		else if (("benchmark_"+detectorId).equals(partName)) {
		    				benchmark = fieldValue;
		    			} else if ("comments".equals(partName)) {
		    				if (StringUtils.isNotBlank(fieldValue)) {
		    					comments = fieldValue; 
		    				}
		    			}
						comments = ElabUtil.stringSanitization(comments, elab, "Cosmic Upload");
		       	        setDetectorId(detectorId);
		       	        setComments(comments);
		       	        setBenchmark(benchmark);
		      			long lEndTime = new Date().getTime();
		      			String uploadtime = "upload.jsp: " +String.valueOf(lEndTime - lStartTime)+ " ms";
		      			setTime(uploadtime);		       	        
			    	}
                }
		} catch (Exception e) {
			throw new Exception("A problem occurred while uploading your file." + 
							   "Please send an e-mail to <a href=\'mailto:e-labs@fnal.gov\'>e-labs@fnal.gov</a> with the following error: " +
								e.toString());
		}
*/
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
