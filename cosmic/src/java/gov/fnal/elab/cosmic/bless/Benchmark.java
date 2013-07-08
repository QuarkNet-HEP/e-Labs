package gov.fnal.elab.cosmic.bless;

import gov.fnal.elab.*;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.datacatalog.query.GreaterThan;
import gov.fnal.elab.datacatalog.query.Like;
import gov.fnal.elab.datacatalog.query.GreaterOrEqual;
import gov.fnal.elab.datacatalog.query.In;
import gov.fnal.elab.datacatalog.query.Not;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.datacatalog.*;
import gov.fnal.elab.datacatalog.impl.*;
import gov.fnal.elab.datacatalog.impl.vds.*;
import gov.fnal.elab.datacatalog.query.*;
import gov.fnal.elab.cosmic.*;
import gov.fnal.elab.cosmic.beans.*;

import java.io.File;
import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.*;

public class Benchmark {
	public static ResultSet getBenchmarkFileName(Elab elab, Integer detectorid) throws ElabException {
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Like("detectorid", Integer.toString(detectorid)));
		and.add(new Equals("benchmarkfile", true));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		return rs;
	}
	public static String getDefaultBenchmark(Elab elab, Integer detectorid) throws ElabException {
		String benchmarkDefault = "";
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Like("detectorid", Integer.toString(detectorid)));
		and.add(new Equals("benchmarkfile", true));
		and.add(new Equals("benchmarkdefault", true));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs != null && rs.size() > 0) {
			benchmarkDefault = rs.getLfnArray()[0];
		}
		return benchmarkDefault;
	}
	public static ResultSet getBlessedDataFilesByBenchmark(Elab elab, String benchmarkfile) throws ElabException {
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Equals("benchmarkreference", benchmarkfile));
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
	//public static ResultSet getUnblessedFilesByDetector(Elab elab, Integer detectorid) throws ElabException {
	//	In and = new In();
	//	and.add(new Equals("project","cosmic"));
	//	and.add(new Equals("type", "split"));
	//	and.add(new Like("detectorid", Integer.toString(detectorid)));
	//	and.add(new Equals("blessed", false));
	//	and.add(new Like("blessfile", "%.bless%"));
	//	ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
	//	rs.sort("creationdate", true);
	//	return rs;
	//}
	public static ResultSet getUnblessedFilesByBenchmarkGeometry(Elab elab, Integer detectorid, String benchmark) throws ElabException {
		VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
		String julianDate = e.getTupleValue("julianstartdate").toString();
		Geometries geometries = new Geometries(elab, detectorid);
		Geometry g = geometries.getGeometry(detectorid);
		SortedMap geos = g.getGeoEntriesBefore(julianDate);
		GeoEntryBean geoEntry = (GeoEntryBean) geos.get(geos.lastKey()); 
		
        Iterator<GeoEntryBean> j = g.getGeoEntries();
        
        Date endDate = new Date();
        while (j.hasNext()) {
            GeoEntryBean gb = j.next();
            if (geoEntry.getDate().equals(gb.getDate()) && j.hasNext()) {
                endDate = j.next().getDate();
            }
        }
        
		Date startDate = geoEntry.getDate(); 
		In and = new In();
		and.add(new Equals("project","cosmic"));
		and.add(new Equals("type", "split"));
		and.add(new Like("detectorid", Integer.toString(detectorid)));
		and.add(new Equals("blessed", false));
		and.add(new Like("blessfile", "%.bless%"));
        and.add(new Between("startdate", startDate, endDate));
        ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		rs.sort("creationdate", true);
		return rs;
	}          
 }