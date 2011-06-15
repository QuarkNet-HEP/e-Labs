package gov.fnal.elab.cosmic.bless;

import java.util.*;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.util.ElabException;


public class Bless {
	public static void setBlessedState(Elab elab, String file, String state) throws ElabException {
		CatalogEntry ce = elab.getDataCatalogProvider().getEntry(file);
		if (ce == null) {
			throw new ElabException("File " + file + " does not exist in our data catalog.");
		}
		else {
			ce.setTupleValue("blessed", state);
			elab.getDataCatalogProvider().insert(ce);
		}
	}
	
	public static void setGoldenState(Elab elab, String file, boolean state) throws ElabException {
		CatalogEntry ce = elab.getDataCatalogProvider().getEntry(file);
		if (ce == null) {
			throw new ElabException("File " + file + " does not exist in our data catalog.");
		}
		else {
			ce.setTupleValue("golden", state);
			ce.setTupleValue("blessed", "blessed"); // golden files are implicitly blessed
			elab.getDataCatalogProvider().insert(ce);
		}
	}
	
	public static boolean checkForExistingGolden(Elab elab, int detector, Date startDate, Date endDate) throws ElabException {
		In and = new In();

		and.add(new Equals("project", "cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Between("startdate", startDate, endDate));
		and.add(new Equals("detector", detector));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		
		if (rs.size() == 1) {
			return true;
		}
		else if (rs.size() == 0) {
			return false; 
		}
		else {
			throw new ElabException("Multiple golden files exist for this date range; this should not be happening :(");
		}
	}
	
	public static String getGoldenFileName(Elab elab, int detector, Date startDate, Date endDate) throws ElabException {
		In and = new In();

		and.add(new Equals("project", "cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Between("startdate", startDate, endDate));
		and.add(new Equals("detector", detector));
		and.add(new Equals("golden", true));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs.size() == 1) {
			return rs.getLfnArray()[0]; 
		}
		else if (rs.size() == 0) {
			return null; 
		}
		else {
			throw new ElabException("Multiple golden files exist for this date range; this should not be happening :(");
		}
	}
	
	public static Date getGoldenFileDate(Elab elab, int detector, Date startDate, Date endDate) throws ElabException {
		In and = new In();

		and.add(new Equals("project", "cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Between("startdate", startDate, endDate));
		and.add(new Equals("detector", detector));
		and.add(new Equals("golden", true));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs.size() == 1) {
			for (CatalogEntry ce : rs) {
				return (Date) ce.getTupleValue("startdate");
			}
		}
		else if (rs.size() == 0) {
			return null; 
		}
		
		throw new ElabException("Multiple golden files exist for this date range; this should not be happening :(");
		
	}
	
	public static void setBlessedStates(Elab elab, int detector, Date startDate, Date endDate, String state) throws ElabException {
		In and = new In();

		and.add(new Equals("project", "cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Between("startdate", startDate, endDate));
		and.add(new Equals("detector", detector));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and); 
		
		for (CatalogEntry ce : rs) {
			String blessedState = (String) ce.getTupleValue("blessed");
			if (!"unknown state".equals(blessedState) && !"cannot bless".equals(blessedState)) {
				ce.setTupleValue("blessed", state);
				elab.getDataCatalogProvider().insert(ce);
			}
		}
	}
	
}
