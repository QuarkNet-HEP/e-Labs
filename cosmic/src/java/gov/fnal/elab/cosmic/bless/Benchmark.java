package gov.fnal.elab.cosmic.bless;

import gov.fnal.elab.Elab;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.datacatalog.query.Like;
import gov.fnal.elab.datacatalog.query.GreaterOrEqual;
import gov.fnal.elab.datacatalog.query.In;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;

import java.util.*;

public class Benchmark {
	public static ResultSet getBenchmarkFileName(Elab elab, Integer detectorid) throws ElabException {
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Like("detectorid", Integer.toString(detectorid)));
		and.add(new Equals("goldenfile", true));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		return rs;
	}
	
	public static ResultSet getBlessedDataFilesByBenchmark(Elab elab, String benchmarkfile) throws ElabException {
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Equals("goldenreference", benchmarkfile));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		return rs;
	}

	public static ResultSet getBenchmarkCandidates(Elab elab, Integer detectorid, Date startDate) throws ElabException {
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Like("detectorid", Integer.toString(detectorid)));
		and.add(new GreaterOrEqual("startdate", startDate));
		
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		rs.sort("creationdate", true);
		return rs;
	}

}