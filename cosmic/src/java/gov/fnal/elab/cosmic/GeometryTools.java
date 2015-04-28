package gov.fnal.elab.cosmic;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.DataTools;
import gov.fnal.elab.datacatalog.impl.vds.VDSCatalogEntry;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.datacatalog.query.*;

import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.*;

public class GeometryTools {
	boolean hasGeometry;
	String julianday;
	boolean stacked;
	TreeMap<String, String> filesGeoMistmatch;
	
	public GeometryTools() {
		filesGeoMistmatch = new TreeMap<String, String>();
	}//end of constructor

	public TreeMap<String, String> checkResultSet(ResultSet rs) throws ElabException {
        for (CatalogEntry e : rs) {
        	Boolean entry_stacked = (Boolean) e.getTupleValue("stacked");
        	Double jd = (Double) e.getTupleValue("julianstartdate");
        	checkGeoEntryFile(e.getLFN());
        	if (entry_stacked != stacked) {
        		String message = " metadata "+String.valueOf(jd)+": "+String.valueOf(entry_stacked)+ " - geo file "+julianday+": "+String.valueOf(stacked);
        		filesGeoMistmatch.put(e.getLFN(), message);
        	}
        }
        return filesGeoMistmatch;
	}//end of checkResultSet
	
    public void checkGeoEntryFile(String filename) throws ElabException {
    	hasGeometry = false;
    	Elab elab = Elab.getElab(null, "cosmic");
		VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filename);
		String julianDate = e.getTupleValue("julianstartdate").toString();
		Integer detectorid = Integer.valueOf(e.getTupleValue("detectorid").toString());

		String geoFile = elab.getProperties().getDataDir() + java.io.File.separator + String.valueOf(detectorid)+ java.io.File.separator + String.valueOf(detectorid)+".geo";
        Pattern p1 = Pattern.compile("^[0-9]{7}(\\.[0-9]*)*$");
        try {
	        LineNumberReader in = new LineNumberReader(new FileReader(geoFile));
	        String s = "";
	        ArrayList jd = new ArrayList();
	        ArrayList lat = new ArrayList();
	        ArrayList lon = new ArrayList();
	        ArrayList alt = new ArrayList();
	        ArrayList stack = new ArrayList();
	        ArrayList chan1 = new ArrayList();
	        ArrayList chan2 = new ArrayList();
	        ArrayList chan3 = new ArrayList();
	        ArrayList chan4 = new ArrayList();
	        ArrayList gp = new ArrayList();
	        while ((s = in.readLine()) != null) {
	        	if (s != null) {
	                if (!s.matches("^[0-9]{7}(\\.[0-9]*)*$")) {
	                	gp.add(s);
	                	s = in.readLine();
	                } 
	                if (s != null) {
		        		Matcher m1 = p1.matcher(s);
		                if (m1.matches()) {
		                	jd.add(s);
		                }
		                lat.add(getLatitude(in.readLine()));
		                lon.add(getLongitude(in.readLine()));
		                alt.add(in.readLine());
		                stack.add(getStacked(in.readLine()));
		                chan1.add(in.readLine());
		                chan2.add(in.readLine());
		                chan3.add(in.readLine());
		                chan4.add(in.readLine());
	                }
	        	}
	        }
	        if (jd.size() > 0) {
	        	Double filejd = Double.valueOf(julianDate);
	        	for (int i = 0; i < jd.size(); i++) {
	        		Double jditem = Double.valueOf(jd.get(i).toString());
	        		if (jditem < filejd) {
	        			hasGeometry = true;
	                	julianday = jd.get(i).toString();
	                	stacked = (Boolean) stack.get(i);
	        		}
	        	}
	        }
	        in.close();
        } catch (Exception ex) {
        	throw new ElabException(ex);
        }

    }//end of checkGeoEntryFile	

    public String getLatitude(String s) {
    	String temp = "";
    	if (s != null) {
	    	String[] split = s.split("\\.");
	    	if (split[0].startsWith("-")) {
	    		temp = split[0].substring(1) + ":" + split[1]
	                + "." + split[2] + " S";
	    	}
	    	else {
	    		temp = split[0] + ":" + split[1] + "."
	                + split[2] + " N";
	    	}
    	}
    	return temp;
    }//end of getLatitude
    
    public String getLongitude(String s) {
    	String temp = "";
    	if (s != null) {
	    	String[] split = s.split("\\.");
	    	if (split[0].startsWith("-")) {
	    		temp = split[0].substring(1) + ":" + split[1]
	                    + "." + split[2] + " W";
	    	}
	    	else {
	    		temp = split[0] + ":" + split[1] + "."
	                    + split[2] + " E";
	    	}
    	}
    	return temp;
    }//end of getLatitude

    public boolean getStacked(String s) {
    	boolean temp = false;
    	if (s != null) {
    		if (s.equals("1")) {
    			temp = true;
    		} else {
    			temp = false;
    		}
    	}
    	return temp;
    }//end of getLatitude   
    
 
}//end of class GeometryTools