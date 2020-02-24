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
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.lang.*;

import org.apache.commons.lang.time.DateFormatUtils;

/**
 * Benchmark contains tools to
 * 	-get all benchmark files given a detector
 *  -get the default benchmark for a given detector
 *  -get all files that have been blessed by a certain benchmark file
 *  -get all regular files which are benchmark candidates for a given detector
 *  -set a file as a benchmark file (and return the duration)
 *  -
 *  -
 *  -get list of splits plus relevant icons in the formatted string for display purposes
 */

public class Benchmark {
	public static ResultSet getUnblessedWithBenchmark(Elab elab, Date startDate, Date endDate) throws ElabException {
		ResultSet rs = null;
		if (elab != null && startDate != null && endDate != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Equals("blessed", false));
			and.add(new Like("benchmarkreference", "%"));
			and.add(new GreaterOrEqual("creationdate", startDate));
			and.add(new LessOrEqual("creationdate", endDate));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		return rs;
	}// end of getUnblessedWithBenchmark

	//EPeronja: get all the benchmark info for splits given a period of time
	public static ResultSet getSplitBenchmarkInfoByInterval(Elab elab, Date startDate, Date endDate) throws ElabException {
		ResultSet rs = null;
		if (elab != null && startDate != null && endDate != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new GreaterOrEqual("creationdate", startDate));
			and.add(new LessOrEqual("creationdate", endDate));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		if (rs != null) {
			rs.sort("name", true);
		}
		return rs;
	}//end of getSplitBenchmarkInfoByInterval

	//EPeronja: get unblessed files
	public static ResultSet getUnblessedSplitDetails(Elab elab, Date startDate, Date endDate) throws ElabException {
		ResultSet rs = null;
		if (elab != null && startDate != null && endDate != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Equals("blessed", false));
			and.add(new Like("benchmarkfail", "%"));
			and.add(new GreaterOrEqual("creationdate", startDate));
			and.add(new LessOrEqual("creationdate", endDate));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		if (rs != null) {
			rs.sort("name", true);
		}
		return rs;
	}//end of getSplitBenchmarkInfoByInterval

	//EPeronja: get the benchmark files for the given detector
	public static ResultSet getBenchmarkFileName(Elab elab, Integer detectorid) throws ElabException {
		ResultSet rs = null;
		if (elab != null && detectorid != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Like("detectorid", Integer.toString(detectorid)));
			and.add(new Equals("benchmarkfile", true));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		return rs;
	}//end of getBenchmarkFileName

	//EPeronja: get the default benchmark file for a given detector
	public static String getDefaultBenchmark(Elab elab, Integer detectorid) throws ElabException {
		String benchmarkDefault = "";
		if (detectorid != null && elab != null) {
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
		}
		return benchmarkDefault;
	}//end of getDefaultBenchmark
	
	//EPeronja: retrieve all split files blessed by the benchmark in the argument
	public static ResultSet getBlessedDataFilesByBenchmark(Elab elab, String benchmarkfile) throws ElabException {
		ResultSet rs = null;
		if (benchmarkfile != null && elab != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Equals("benchmarkreference", benchmarkfile));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		return rs;
	}//end of getBlessedDataFilesByBenchmark

	//EPeronja: get split files that could be selected as benchmark files for the given detector
	public static ResultSet getBenchmarkCandidates(Elab elab, Integer detectorid, Date startDate, Date endDate) throws ElabException {
		ResultSet rs = null;
		if (elab != null && detectorid != null && startDate != null && endDate != null) {
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Like("detectorid", Integer.toString(detectorid)));
			and.add(new GreaterOrEqual("startdate", startDate));
			Calendar c = Calendar.getInstance();
			c.setTime(endDate);
			c.add(Calendar.DATE, 1);
		    endDate = c.getTime();
			and.add(new LessOrEqual("enddate", endDate));
			rs = elab.getDataCatalogProvider().runQuery(and);
		}
		return rs;
	}//end of getBenchmarkCandidates

	//EPeronja: set file as new default benchmark
	public static Long setFileAsBenchmark(DataCatalogProvider dcp, String benchmark, String benchmarkLabel) throws ElabException {
	    Long duration = 0L;
	    //set new benchmark and make it default
	    if (dcp != null && benchmark != null && !benchmark.equals("")) {
			CatalogEntry entry = dcp.getEntry(benchmark);
			//get all the tuples needed for blessing when using this benchmark file
			Long chan1 = (Long) entry.getTupleValue("chan1");
			Long chan2 = (Long) entry.getTupleValue("chan2");
			Long chan3 = (Long) entry.getTupleValue("chan3");
			Long chan4 = (Long) entry.getTupleValue("chan4");
			Long triggers = (Long) entry.getTupleValue("triggers");
			Date startdate = (Date) entry.getTupleValue("startdate");
			Date enddate = (Date) entry.getTupleValue("enddate");
			double chan1Rate, chan2Rate, chan3Rate, chan4Rate, triggerRate;
			try {
				duration = (Long) (enddate.getTime() - startdate.getTime()) / 1000;
				if (duration > 0) {
					chan1Rate = chan1.doubleValue()/ duration;
					chan2Rate = chan2.doubleValue() / duration;
					chan3Rate = chan3.doubleValue() / duration;
					chan4Rate = chan4.doubleValue() / duration;
					triggerRate = triggers.doubleValue() / duration;
				} else {
					chan1Rate = chan2Rate = chan3Rate = chan4Rate = triggerRate = 0;
				}
			} catch (Exception e) {
				chan1Rate = chan2Rate = chan3Rate = chan4Rate = triggerRate = 0;
			}
			if (duration > 0) {
				entry.setTupleValue("blessed", true);
				entry.setTupleValue("blessedstatus", "blessed");
				entry.setTupleValue("benchmarkfail","");
				entry.setTupleValue("benchmarkerrorcode","");
				entry.setTupleValue("benchmarkfailurechannel","");
				entry.setTupleValue("benchmarkquality","");
				entry.setTupleValue("benchmarkrate","");
				entry.setTupleValue("benchmarksplitrate","");
				dcp.insert(entry);
				ArrayList meta = new ArrayList();
				meta.add("benchmarkfile boolean true");
				meta.add("benchmarkreference string none");
				meta.add("benchmarkdefault boolean true");
				if (benchmarkLabel == null || benchmarkLabel.equals("")) {
					benchmarkLabel = "Empty Label: " + benchmark;
				}
				meta.add("benchmarklabel string "+benchmarkLabel);
				meta.add("duration int " + String.valueOf(duration));
				meta.add("chan1Rate float " + String.valueOf(chan1Rate));
				meta.add("chan2Rate float " + String.valueOf(chan2Rate));
				meta.add("chan3Rate float " + String.valueOf(chan3Rate));
				meta.add("chan4Rate float " + String.valueOf(chan4Rate));
				meta.add("triggerRate float " + String.valueOf(triggerRate));
				dcp.insert(DataTools.buildCatalogEntry(benchmark, meta));
			} else {
				throw new ElabException("Duration is either zero or negative");
			}
		}
		return duration;
	}//end of setFileAsBenchmark

	//EPeronja: retrieve all the files that share geometry with the benchmark
	public static ResultSet getAllFilesByBenchmarkGeometry(Elab elab, Integer detectorid, String benchmark) throws ElabException {
		ResultSet rs = null;
		if (elab != null && detectorid != null && benchmark != null && !benchmark.equals("")) {
			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
			String julianDate = e.getTupleValue("julianstartdate").toString();
			Geometries geometries = new Geometries(elab, detectorid);
			Geometry g = geometries.getGeometry(detectorid);
			SortedMap geosBefore = g.getGeoEntriesBefore(julianDate);
			Date startDate = new Date();
			if (geosBefore != null && !geosBefore.isEmpty()) {
				GeoEntryBean geoEntryBefore = (GeoEntryBean) geosBefore.get(geosBefore.lastKey());
				Iterator<GeoEntryBean> j = g.getGeoEntries();
				Date endDate = new Date();
				while (j.hasNext()) {
					GeoEntryBean gb = j.next();
					if (geoEntryBefore.getDate().equals(gb.getDate()) && j.hasNext()) {
						startDate = j.next().getDate();
					}
				}
			}
			SortedMap geosAfter = g.getGeoEntriesAfter(julianDate);
			Date endDate = new Date();
			if (geosAfter != null && !geosAfter.isEmpty()) {
				geosAfter.remove(geosAfter.firstKey());
				if (!geosAfter.isEmpty()) {
					GeoEntryBean geoEntryAfter = (GeoEntryBean) geosAfter.get(geosAfter.firstKey());
					Iterator<GeoEntryBean> j = g.getGeoEntries();
					while (j.hasNext()) {
						GeoEntryBean gb = j.next();
						if (geoEntryAfter.getDate().equals(gb.getDate()) && j.hasNext()) {
							endDate = geoEntryAfter.getDate();
						}
					}
				}
			}
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Like("detectorid", Integer.toString(detectorid)));
			and.add(new Like("blessfile", "%.bless%"));
	        and.add(new Between("startdate", startDate, endDate));
	        rs = elab.getDataCatalogProvider().runQuery(and);
			if (rs != null) {
				rs.sort("creationdate", true);
			}
		}
		return rs;
	}//end of getAllFilesByBenchmarkGeometry

	//EPeronja: retrieve all the unblessed files that share geometry with the given benchmark
	public static ResultSet getUnblessedFilesByBenchmarkGeometry(Elab elab, Integer detectorid, String benchmark) throws ElabException {
		ResultSet rs = null;
		if (elab != null && detectorid != null && benchmark != null && !benchmark.equals("")) {
			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmark);
			String julianDate = e.getTupleValue("julianstartdate").toString();
			Geometries geometries = new Geometries(elab, detectorid);
			Geometry g = geometries.getGeometry(detectorid);
			SortedMap geosBefore = g.getGeoEntriesBefore(julianDate);
			Date startDate = new Date();
			if (geosBefore != null && !geosBefore.isEmpty() && geosBefore.lastKey() != null) {
				GeoEntryBean geoEntryBefore = (GeoEntryBean) geosBefore.get(geosBefore.lastKey());
				Iterator<GeoEntryBean> j = g.getGeoEntries();
				startDate = geoEntryBefore.getDate();
				while (j.hasNext()) {
					GeoEntryBean gb = j.next();
					if (geoEntryBefore.getDate().equals(gb.getDate()) && j.hasNext()) {
						startDate = j.next().getDate();
					}
				}
			}
			SortedMap geosAfter = g.getGeoEntriesAfter(julianDate);
			Date endDate = new Date();
			if (geosAfter != null && !geosAfter.isEmpty() && geosAfter.firstKey() != null) {
				geosAfter.remove(geosAfter.firstKey());
				if (!geosAfter.isEmpty()) {
					GeoEntryBean geoEntryAfter = (GeoEntryBean) geosAfter.get(geosAfter.firstKey());
					Iterator<GeoEntryBean> j = g.getGeoEntries();
					while (j.hasNext()) {
						GeoEntryBean gb = j.next();
						if (geoEntryAfter.getDate().equals(gb.getDate()) && j.hasNext()) {
							endDate = geoEntryAfter.getDate();
						}
					}
				}
			}
			In and = new In();
			and.add(new Equals("project","cosmic"));
			and.add(new Equals("type", "split"));
			and.add(new Like("detectorid", Integer.toString(detectorid)));
			and.add(new Equals("blessed", false));
			and.add(new Like("blessfile", "%.bless%"));
	        and.add(new Between("startdate", startDate, endDate));
	        rs = elab.getDataCatalogProvider().runQuery(and);
			if (rs != null) {
				rs.sort("creationdate", true);
			}
		}
		return rs;
	}//end of getUnblessedFilesByBenchmarkGeometry

	//EPeronja: get the string to display the split files
	public static String getSplitBlessLink(VDSCatalogEntry entry) throws ElabException {
		StringBuilder sb = new StringBuilder("");
		if (entry != null) {
			String filename = entry.getLFN();
	        sb.append("<a class=\"file-link\" href=\"../analysis-blessing/compare1.jsp?file=");
	        sb.append(filename);
	        sb.append("\">");
	        sb.append(filename);
	        sb.append("</a>");
		}
		return sb.toString();
	}//end of getSplitDetails

	//EPeronja: get the string to display the split files plus the blessed, unblessed, comments, stacked, unstacked icons.
	public static String getIcons(VDSCatalogEntry entry) throws ElabException {
		StringBuilder sb = new StringBuilder("");
		if (entry != null) {
			String filename = entry.getLFN();
			sb.append("<a href=\"../jsp/comments-add.jsp?fileName="+filename);
			String comments = (String) entry.getTupleValue("comments");
			if (comments != null && !comments.equals("")) {
				sb.append("\"><img src=\"../graphics/balloon_talk_blue.gif\"/></a>");
			} else {
				sb.append("\"><img src=\"../graphics/balloon_talk_empty.gif\"/></a>");
			}

			if (entry.getTupleValue("stacked") != null) {
				Boolean stacked = (Boolean) entry.getTupleValue("stacked");
				if (stacked) {
					sb.append("<img alt=\"Stacked data\" src=\"../graphics/stacked.gif\"/>");
				} else {
					sb.append("<img alt=\"Unstacked data\" src=\"../graphics/unstacked.gif\"/>");
				}
			} else {
				sb.append("<i>No Geo</i>");
			}
			if (entry.getTupleValue("blessed") != null) {
				Boolean blessed = (Boolean) entry.getTupleValue("blessed");
				if (blessed) {
					sb.append("<img alt=\"Blessed data\" src=\"../graphics/star.gif\"/>");
				} else {
					sb.append("<img alt=\"Unblessed data\" src=\"../graphics/unblessed.gif\"/>");
				}
			}
		}
		return sb.toString();
	}//end of getIcons
}
