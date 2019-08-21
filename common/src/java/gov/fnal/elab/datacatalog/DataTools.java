//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 20, 2007
 */
package gov.fnal.elab.datacatalog;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.RawDataFileResolver;
import gov.fnal.elab.datacatalog.StructuredResultSet.File;
import gov.fnal.elab.datacatalog.StructuredResultSet.Month;
import gov.fnal.elab.datacatalog.StructuredResultSet.School;
import gov.fnal.elab.datacatalog.impl.vds.VDSCatalogEntry;
import gov.fnal.elab.datacatalog.query.CatalogEntry;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.datacatalog.query.In;
import gov.fnal.elab.datacatalog.query.Equals;
import gov.fnal.elab.datacatalog.query.Between;
import gov.fnal.elab.datacatalog.query.Like;
import gov.fnal.elab.datacatalog.query.And;
import gov.fnal.elab.datacatalog.query.ResultSet;
import gov.fnal.elab.util.DatabaseConnectionManager;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.util.ElabUtil;
import gov.fnal.elab.ElabFactory;
import gov.fnal.elab.analysis.AnalysisRun;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.codec.net.URLCodec;
import org.griphyn.vdl.dbschema.AnnotationSchema;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.AbstractCollection;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.SortedMap;
import java.util.Map.Entry;
import java.util.Set;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.*;
import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A few convenience functions for dealing with QuarkNet data
 * 
 *TODO cosmic things to cosmic
 */
public class DataTools {
    public static String buildQueryURLParams(Elab elab, String key, String value) {
        return "?submit=true&key=" + key + "&value=" + value;
    }

    private static final Map<String, Integer> KEYS;
    
    static {
        KEYS = new HashMap<String, Integer>();
        KEYS.put("school", 0);
        KEYS.put("startdate", 1);
        KEYS.put("blessed", 2);
        KEYS.put("stacked", 3);
        KEYS.put("chan1", 4);
        KEYS.put("chan2", 5);
        KEYS.put("chan3", 6);
        KEYS.put("chan4", 7);
        KEYS.put("city", 8);
        KEYS.put("state", 9);
        KEYS.put("enddate", 10);
        KEYS.put("detectorid", 11);
        //EPeronja-02/04/2013: Bug472- added to retrieve new attributes 
        KEYS.put("blessfile", 12);
        KEYS.put("ConReg0", 13);
        KEYS.put("ConReg1", 14);
        KEYS.put("ConReg2", 15);
        KEYS.put("ConReg3", 16);      
        //EPeronja-04/25/2013: Benchmark File attributes
        KEYS.put("benchmarkfile", 17);
        KEYS.put("benchmarkdefault", 18);
        KEYS.put("benchmarklabel", 19);
        KEYS.put("benchmarkreference", 20);
        KEYS.put("benchmarkfail", 21);
        //EPeronja-06/25/2013: 289- Lost functionality on data search
        KEYS.put("group", 22);
        KEYS.put("creationdate",23);
        KEYS.put("comments", 24);
        KEYS.put("fileduration", 25);
        KEYS.put("triggers", 26);
    }

    public static final int SCHOOL = 0;
    public static final int STARTDATE = 1;
    public static final int BLESSED = 2;
    public static final int STACKED = 3;
    public static final int CHAN1 = 4;
    public static final int CHAN2 = 5;
    public static final int CHAN3 = 6;
    public static final int CHAN4 = 7;
    public static final int CITY = 8;
    public static final int STATE = 9;
    public static final int ENDDATE = 10;
    public static final int DETECTORID = 11; 
    //EPeronja-02/04/2013: Bug472- added to retrieve new attributes 
    public static final int BLESSFILE = 12;
    public static final int CONREG0 = 13;
    public static final int CONREG1 = 14;
    public static final int CONREG2 = 15;
    public static final int CONREG3 = 16;
    //EPeronja-04/25/2013: Benchmark File attributes
    public static final int BENCHMARKFILE = 17;
    public static final int BENCHMARKDEFAULT = 18;
    public static final int BENCHMARKLABEL = 19;
    public static final int BENCHMARKREFERENCE = 20;
    public static final int BENCHMARKFAIL = 21;
    //EPeronja-06/25/2013: 289- Lost functionality on data search
    public static final int GROUP = 22;
    public static final int CREATIONDATE = 23;
    public static final int COMMENTS = 24;
    public static final int FILEDURATION = 25;
    public static final int TRIGGERS = 26;
    //EPeronja-03/11/2015: Check the file actually has an entry in the geometry file
    //					   backing up the geometry icon. The stacked label doesn't cut it.
    
    
    public static final String MONTH_FORMAT = "MMMM yyyy";

    /**
     * Organizes the search results in a hierarchical fashion and returns a
     * {@link StructuredResultSet}
     * 
     * @param rs
     *            A {@link ResultSet} presumably obtained by running a query.
     * @return A {@link StructuredResultSet} with the organized data.
     * 
     */
    public static StructuredResultSet organizeSearchResults(ResultSet rs, String benchmarksearch, String username, String teacher) {
        Date startDate = null, endDate = null;

        StructuredResultSet srs = new StructuredResultSet();
        //srs.setDataFileCount(rs.size());
        int new_count = 0;
        for (CatalogEntry e : rs) {
        	//EPeronja-11/21/2013: added checks for not displaying unblessed data by default
        	if (benchmarksearch.equals("default")) {
        		//String data_owner = "";
        		//if (e.getTupleValue("group") != null) {
        		//	data_owner = (String) e.getTupleValue("group");
        		//}
        		Boolean data_blessed = false;
        		if (e.getTupleValue("blessed") != null) {
        			data_blessed = (Boolean) e.getTupleValue("blessed");
        		}
        		String data_blessfile = "";
        		if (e.getTupleValue("blessfile") != null) {
        			data_blessfile = (String) e.getTupleValue("blessfile");
        		}
        		//if user doesn't own the data we have to look further
        		String groupteacher = "";
        		if (e.getTupleValue("teacher") != null) {
        			groupteacher = (String) e.getTupleValue("teacher");
        		}
        		if (!groupteacher.equals(teacher) || groupteacher.equals("")) {
        			if (!data_blessed || data_blessfile.equals("")) {
        				continue;
        			}
        		}
        	}
        	new_count++;
          Object[] data = new Object[KEYS.size()];
            
          for (Tuple t : e) {
              Integer index = KEYS.get(t.getKey());
              if (index != null) {
                  data[index.intValue()] = t.getValue();
              }
          }

          String schoolName = (String) data[SCHOOL];
          if (StringUtils.isBlank(schoolName)) {
              System.out.println("WARNING: School name is missing for file " + e.getLFN());
              schoolName = "Unknown School";
          }
          String cityName = (String) data[CITY];
          if (StringUtils.isBlank(cityName)) {
              System.out.println("WARNING: City name is missing for file " + e.getLFN());
              cityName = "Unknown City";
          }
          String stateName = (String) data[STATE];
          if (StringUtils.isBlank(stateName)) {
              System.out.println("WARNING: State name is missing for file " + e.getLFN());
              stateName = "Unknown State";
          }
            
          School school = srs.getSchool(schoolName, cityName, stateName);
          if (school == null) {
              school = new School(schoolName, cityName, stateName);
              srs.addSchool(school);
          }
            
          /* Correct city and state names if there some metadata pieces have bad data.
            if (school.getCity().equals("Unknown City") && !cityName.equals("Unknown City"))
            	school.setCity(cityName);
            if (school.getState().equals("Unknown State") && !stateName.equals("Uknown State"))
            	school.setState(stateName);
          */
            
          Timestamp ts = (Timestamp) data[STARTDATE];
          String startdate = DateFormatUtils.format(ts.getTime(), MONTH_FORMAT);
          Month month = school.getMonth(startdate);
          if (month == null) {
           	month = new Month(startdate, ts);
            school.addDay(month);
          }

          File file = new File(e.getLFN());
          file.setStartDate((Timestamp) data[STARTDATE]);
          file.setEndDate((Timestamp) data[ENDDATE]);
            
          long totalEvents = 0;
          try {
          	totalEvents += (Long) data[CHAN1];
          }
          catch(Exception ee) {}
          try {
           	totalEvents += (Long) data[CHAN2]; 
          }
          catch(Exception ee) {}
          try {
           	totalEvents += (Long) data[CHAN3]; 
          }
          catch(Exception ee) {}
          try {
           	totalEvents += (Long) data[CHAN4]; 
          }
          catch(Exception ee) {}
  
          file.setTotalEvents(totalEvents);

          try {
            file.setDetector(Integer.parseInt((String) data[DETECTORID]));
          }
          catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " has a malformed detector ID. Skipping.");
            continue;
          }
          //EPeronja-02/04/2013: Bug472- added to set new attributes         
          try {
           	file.setBlessFile((String) data[BLESSFILE]);
          } catch (Exception ex) {
           	System.out.println("WARNING: File " + e.getLFN() + " does not have a bless file. Skipping.");
           	continue;
          }
          try {
           	file.setBlessFile((String) data[CONREG0]);
          } catch (Exception ex) {
           	System.out.println("WARNING: File " + e.getLFN() + " does not have register 0 conf. Skipping.");
           	continue;
          }
          try {
           	file.setBlessFile((String) data[CONREG1]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have register 1 conf. Skipping.");
            continue;
          }
          try {
            file.setBlessFile((String) data[CONREG2]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have register 2 conf. Skipping.");
            continue;
          }
          try {
           	file.setBlessFile((String) data[CONREG3]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have register 3 conf. Skipping.");
            continue;
          }
          //EPeronja-04/25/2013: Golden File attributes
          try {
            file.setBenchmarkFile((Boolean) data[BENCHMARKFILE]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a benchmark file. Skipping.");
            continue;
          }
          try {
            file.setBenchmarkDefault((Boolean) data[BENCHMARKDEFAULT]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a benchmark file. Skipping.");
            continue;
          }  
          try {
            file.setBenchmarkLabel((String) data[BENCHMARKLABEL]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a benchmark label. Skipping.");
            continue;
          }  
          try {
            file.setBenchmarkReference((String) data[BENCHMARKREFERENCE]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a benchmark reference. Skipping.");
            continue;
          }  
          try {
            file.setBenchmarkFail((String) data[BENCHMARKFAIL]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a benchmark failure. Skipping.");
            continue;
          }  
          //EPeronja-06/25/2013: 289- Lost functionality on data search
          try {
            file.setGroup((String) data[GROUP]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a group failure. Skipping.");
            continue;
          }  

          try {
          	file.setComments((String) data[COMMENTS]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a comments. Skipping.");
            continue;
          } 

          try {
            file.setCreationDate((java.util.Date) data[CREATIONDATE]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have a creation date failure. Skipping.");
            continue;
          }  
          try {
            file.setChannel1((Long) data[CHAN1]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have channel failure. Skipping.");
            continue;
          }  
          try {
            file.setChannel2((Long) data[CHAN2]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have channel failure. Skipping.");
            continue;
          }  
          try {
            file.setChannel3((Long) data[CHAN3]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have channel failure. Skipping.");
            continue;
          }  
          try {
            file.setChannel4((Long) data[CHAN4]);
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + " does not have channel failure. Skipping.");
            continue;
          }  

          if (file.getStartDate() == null) {
            System.out.println("WARNING: File " + e.getLFN() + " is missing the start date. Skipping.");
            continue;
          }
          if (file.getEndDate() == null) {
            System.out.println("WARNING: File " + e.getLFN() + " is missing the end date. Defaulting to start date.");
            file.setEndDate(file.getStartDate());
          }

          if (startDate == null || startDate.after(file.getStartDate())) {
            startDate = file.getStartDate();
          }

          if (endDate == null || endDate.before(file.getEndDate())) {
            endDate = file.getEndDate();
          }
            
          //EPeronja-07/22/2013: 556- Cosmic data search: requests from fellows 07/10/2013 (added duration and triggers)
          try {
            file.setTriggers((Long) data[TRIGGERS]);
          } catch (Exception ex) {
            file.setTriggers(0L);
            System.out.println("WARNING: File " + e.getLFN() + " does not have triggers. Skipping.");
          }  
			    Long duration = (Long) (file.getEndDate().getTime() - file.getStartDate().getTime()) / 1000;
			    if (duration > 0) {
				    file.setFileDuration(duration);
			    } else {
				    file.setFileDuration(0L);
			    }
			
          if (Boolean.TRUE.equals(data[BLESSED])) {
            file.setBlessed(true);
            school.incBlessed();
          }
 
          //EPeronja-03/11/2015: 657-Check if there is any entry in the geo file backing up the stacked flag.
          boolean hasGeoEntry = false;
          try {
            hasGeoEntry = getGeoFileEntry(e.getLFN());
          } catch (Exception ex) {
            System.out.println("WARNING: File " + e.getLFN() + ". Failed to find geo entry.");
          }
          //EPeronja-03/12/2015: 657-Check before trusting the metadata stacked field.
          if (hasGeoEntry) {
		        file.setStacked((Boolean) data[STACKED]);
		        if (Boolean.TRUE.equals(data[STACKED])) {
		          school.incStacked();
		        }
          }
	        int events = 0;
          for (int k = CHAN1; k <= CHAN4; k++) {
            if (data[k] != null) {
              events += ((Long) data[k]).intValue();
            }
          }
          //EPeronja-07/22/2013: 556- Cosmic data search: requests from fellows 07/10/2013 (now total events == triggers)
          //school.incEvents(events);

          int triggers = 0;
          if (data[TRIGGERS] != null) {
            triggers = ((Long) data[TRIGGERS]).intValue();
          }
            
          school.incEvents((int) triggers);

          school.incDataFiles();
          month.addFile(file);
        }
        srs.setStartDate(startDate);
        srs.setEndDate(endDate);
        srs.setDataFileCount(new_count);
        return srs;
    }
    
    public static final DateFormat TZ_DATE_TIME_FORMAT;

    static {
        TZ_DATE_TIME_FORMAT = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
    }

    //EPeronja-03/11/2015: 657-Check if there is any entry in the geo file backing up the stacked flag status
    public static boolean getGeoFileEntry(String filename) throws ElabException {
    	boolean hasGeoEntry = false;
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
	      while ((s = in.readLine()) != null) {
	      	if (s != null) {
	      		Matcher m1 = p1.matcher(s);
	          if (m1.matches()) {
	           	jd.add(s);
	          }
	         }
	      }
	      if (jd.size() > 0) {
	       	Double filejd = Double.valueOf(julianDate);
	        for (int i = 0; i < jd.size(); i++) {
	        	Double jditem = Double.valueOf(jd.get(i).toString());
	        	if (jditem < filejd) {
	        		hasGeoEntry = true;
	        	}
	        }
	      }
	      in.close();
        } catch (Exception ex) {
        	throw new ElabException(ex);
        }
        return hasGeoEntry;
    }//end of getGeoFileEntry
    
    //EPeronja-05/20/2014: Insert Analysis results for statistics
    public static void insertAnalysisResults(AnalysisRun ar, Elab elab) throws ElabException {
        Connection conn = null;
        PreparedStatement psAnalysisResult;
        try {
            conn = DatabaseConnectionManager.getConnection(elab.getProperties());
            boolean ac = conn.getAutoCommit();
            psAnalysisResult = conn.prepareStatement(
            				"INSERT INTO analysis_results (job_id, date_started, date_finished, study_type, study_runmode, rawdata, study_result, research_group) " +
                    		"VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id;");
            try {
                conn.setAutoCommit(false);
                
                psAnalysisResult.setString(1, ar.getId());
                Long startmillis = ar.getStartTime().getTime();
                java.sql.Timestamp startDate = new java.sql.Timestamp(startmillis);
                psAnalysisResult.setTimestamp(2, startDate);
                Long endmillis = ar.getStartTime().getTime();
                java.sql.Timestamp endDate = new java.sql.Timestamp(endmillis);
                psAnalysisResult.setTimestamp(3, endDate);
                String type = (String) ar.getAttribute("type");
                if (type == null || type.equals("")) {
                	type = "unknown";
                }
                psAnalysisResult.setString(4, type);
                String runmode = (String) ar.getAttribute("runMode");
                if (runmode == null || runmode.equals("")) {
                	runmode = "local";
                }
                psAnalysisResult.setString(5, runmode);
                Collection rawdata = (Collection) ar.getAttribute("inputfiles");
                if (rawdata != null) {
                	psAnalysisResult.setString(6, Arrays.toString(rawdata.toArray()));
                } else {
                	psAnalysisResult.setString(6, "unknown");
                }
                psAnalysisResult.setString(7, String.valueOf(ar.getStatus()));
                String owner = (String) ar.getAttribute("owner");
                if (owner == null || owner.equals("")) {
                	owner = "unknown";
                }
                psAnalysisResult.setString(8, owner);
                java.sql.ResultSet rs = psAnalysisResult.executeQuery();
                conn.commit();
            }
            catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            finally {
                conn.setAutoCommit(ac);
            }
        }
        catch (SQLException e) {
            throw new ElabException(e);
        }
        finally {
            if (conn != null) {
                DatabaseConnectionManager.close(conn);
            }
        }	
    }//end of insertAnalysisResults
    
    //EPeronja-07/25/2013: Poster Tags
    public static void removePosterTags(Elab elab, String[] removeTags) throws ElabException {
    	for (int i = 0; i < removeTags.length; i++) {
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
	    	And and = new And();
		    and.add(new Equals("type", "poster"));
		    and.add(new Equals("postertag", removeTags[i]));
			ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
			if (rs != null && rs.size() > 0) {
		  		String[] taggedFiles = rs.getLfnArray();
				//remove the reference
			    for (int x = 0; x < taggedFiles.length; x++) {
			    	CatalogEntry ce = dcp.getEntry(taggedFiles[x]);
			    	ce.setTupleValue("postertag","");
			    	dcp.insert(ce);
			    }
			}
	    	CatalogEntry tag = dcp.getEntry(removeTags[i]);
			dcp.delete(tag);
    	}
    }//end of removePosterTags

    public static void insertTags(Elab elab, String[] newTags) {
		DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
    	for (int i = 0; i < newTags.length; i++) {
			//insert new tags
			if (!newTags[i].equals("")) {
				ArrayList meta = new ArrayList();
				newTags[i] = newTags[i].replace(" ", "_");
				meta.add("type string postertag");
				meta.add("project string " + elab.getName());
				try {
					dcp.insert(buildCatalogEntry(newTags[i], meta));
				} catch (ElabException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
    }//end of insertTags
    
	public static ResultSet retrieveTags(Elab elab) throws ElabException {
		In and = new In();
		and.add(new Equals("type", "postertag"));
		and.add(new Equals("project", elab.getName()));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		return rs;
	}

    //EPeronja-06/21/2013: 222-Allow Admin user to delete data files but check dependencies
    public static int checkFileDependency(Elab elab, String filename) throws ElabException{
    	int count = 0;
		In and = new In();
		and.add(new Equals("type", "plot"));
		and.add(new Like("source", "%"+filename+"%"));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs != null && rs.size() > 0) {
	  		count = rs.size();
		}
        return count;
    }

    public static String[] getFileDependency(Elab elab, String filename) throws ElabException{
    	String[] plots = null;
		In and = new In();
		and.add(new Equals("type", "plot"));
		and.add(new Like("source", "%"+filename+"%"));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs != null && rs.size() > 0) {
	  		plots = rs.getLfnArray();
		}
        return plots;
    }
  
    //check benchmark dependency
    public static int checkBenchmarkDependency(Elab elab, String filename) throws ElabException{
    	int count = 0;
		In and = new In();
		and.add(new Equals("type", "split"));
		and.add(new Equals("benchmarkreference", filename));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs != null && rs.size() > 0) {
	  		count = rs.size();
		}
        return count;
    }

    public static String[] getBenchmarkDependency(Elab elab, String filename) throws ElabException{
    	String[] blessedFiles = null;
		In and = new In();
		and.add(new Equals("type", "split"));
		and.add(new Equals("benchmarkreference", filename));
		ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
		if (rs != null && rs.size() > 0) {
			blessedFiles = rs.getLfnArray();
		}
        return blessedFiles;
    }
    //EPeronja-06/11/2013: 254-When deleting files, be sure there are not dependent files
    //                       This function will check plots in the logbook and posters
    public static int checkPlotDependency(Elab elab, String plotName, int figureNumber) throws ElabException {
        int count = 0;
        Connection con = null;
        PreparedStatement ps = null;
        //check logbook first
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties());
            
            ps = con.prepareStatement(
                    "SELECT count(*) as COUNT " +
                    "  FROM log " +
                    "WHERE log_text like ?;");
            URLCodec urlCodec = new URLCodec();
            String fileName = plotName;
            try {
                fileName = urlCodec.encode(plotName);
            } catch (Exception e) {
                throw new ElabException("Problem with encoding the name in DataTools.checkPlotDependency().");
            }
            ps.setString(1, "%"+fileName+"%");    
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.checkPlotDependency(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }
        
        In and = new In();
        and.add(new Like("type","poster"));
        and.add(new Like("FIG:FIGURE" + String.valueOf(figureNumber), plotName));
        ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
        if (rs.size() > 0) {
            count = count + rs.size();
        }
        return count;
    }//end of checkPlotDependency()
    
    //EPeronja-06/14/2015: get resultset with all states
    public static TreeMap<Integer,ArrayList> getStates(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
    	TreeMap<Integer, ArrayList> states = new TreeMap<Integer, ArrayList>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = con.prepareStatement(
                    "SELECT id, name, abbreviation " +
                    "  FROM state " +
                    " ORDER BY type, name;");

            rs = ps.executeQuery();
        	if (rs != null) {
        		while (rs.next()) {
           			ArrayList singleState = new ArrayList();
           			singleState.add(rs.getInt(1));
           			singleState.add(rs.getString(2));
           			singleState.add(rs.getString(3));
           			states.put(rs.getInt(1), singleState);
        		}
        	}

        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getStates(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }
    	return states;
    }//end of getStates

    //EPeronja-06/14/2015: get state abbreviation
    public static String getStateAbbrev(Elab elab, int id) throws ElabException {
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        String abbrev = "";
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties());
            ps = con.prepareStatement(
                    "SELECT abbreviation " +
                    "  FROM state " +
                    " WHERE id = ? ;");
            ps.setInt(1, id);
            rs = ps.executeQuery();
        	if (rs != null) {
        		while (rs.next()) {
        			abbrev = rs.getString(1);
        		}
        	}
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getStateAbbrev(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return abbrev;
    }//end of getStateAbbrev
    
    //EPeronja-06/15/2015: add new state 
    public static int insertState(Elab elab, String state, String abbrev, int type) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (state != null && !state.equals("") && abbrev != null && !abbrev.equals("") && type > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " INSERT INTO state (name,abbreviation,type) "+
	            		" VALUES (?, ?, ?) RETURNING id;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setString(1, state);
		            ps.setString(2, abbrev);
		            ps.setInt(3, type);
		            java.sql.ResultSet rs = ps.executeQuery(); 
		            if (rs != null) {
		        		while (rs.next()) {
		        			recordId = rs.getInt(1);
		        		}
		            }
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertState
    
        
    //EPeronja-06/15/2015: delete state 
    public static void deleteState(Elab elab, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM state "+
	            		" WHERE id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteState
  
    //EPeronja-06/14/2015: get all cities
    public static TreeMap<Integer, ArrayList> getCities(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
    	TreeMap<Integer, ArrayList> cities = new TreeMap<Integer, ArrayList>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    " SELECT city.id, state.abbreviation, city.name " +
                    " FROM city "+
                    " INNER JOIN state " +
                    " on city.state_id = state.id "+
                    " ORDER by state.abbreviation, city.name ;");

            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			ArrayList singleCity = new ArrayList();
        			singleCity.add(rs.getInt(1));
        			singleCity.add(rs.getString(2));
        			singleCity.add(rs.getString(3));
        			cities.put(rs.getInt(1), singleCity);
        		}
        	}   
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getCities(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return cities;
    }//end of getCities

    //EPeronja-06/14/2015: get city name
    public static String getCityName(Elab elab, int id) throws ElabException {
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        String name = "";
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    "SELECT city.name " +
                    "  FROM city " +
                    " WHERE city.id = ?;");
            ps.setInt(1, id);
            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			name = rs.getString(1);
        		}
        	}            
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getCityId(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return name;
    }//end of getCityName    
    
    //EPeronja-06/15/2015: add new city 
    public static int insertCity(Elab elab, String city, int stateId) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (city != null && !city.equals("") && stateId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " INSERT INTO city (name, state_id) " + 
	            		" VALUES (?, ?) RETURNING id;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setString(1, city);
		            ps.setInt(2, stateId);
		            java.sql.ResultSet rs = ps.executeQuery(); 
		            if (rs != null) {
			            while (rs.next()) {
		        			recordId = rs.getInt(1);
		        		}
		            }
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertState    
 
    //EPeronja-06/15/2015: delete city 
    public static void deleteCity(Elab elab, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM city "+
	            		" WHERE id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteCity

    //EPeronja-06/14/2015: get all schools
    public static TreeMap<Integer, ArrayList> getSchools(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
    	TreeMap<Integer, ArrayList> schools = new TreeMap<Integer, ArrayList>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    " SELECT school.id, state.abbreviation, city.name, school.name " +
                    " FROM school "+
                    " INNER JOIN city " +
                    " ON school.city_id = city.id "+
                    " INNER JOIN state " +
                    " ON city.state_id = state.id "+
                    " ORDER by state.abbreviation, city.name, school.name;");

            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			ArrayList singleSchool = new ArrayList();
        			singleSchool.add(rs.getInt(1));
        			singleSchool.add(rs.getString(2));
        			singleSchool.add(rs.getString(3));
        			singleSchool.add(rs.getString(4));
        			schools.put(rs.getInt(1), singleSchool);
        		}
        	}   
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getSchools(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return schools;
    }//end of getSchools

    //EPeronja-06/16/2015: get school name
    public static String getSchoolName(Elab elab, int id) throws ElabException {
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        String name = "";
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    "SELECT name " +
                    "  FROM school " +
                    " WHERE id = ? ;");
            ps.setInt(1, id);
            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			name = rs.getString(1);
        		}
        	}            
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getSchoolId(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return name;
    }//end of getSchoolName    
    
    //EPeronja-06/15/2015: add new school 
    public static int insertSchool(Elab elab, String school, int cityId) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (school != null && !school.equals("") && cityId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " INSERT INTO school (name, city_id) " + 
	            		" VALUES (?, ?) RETURNING id;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setString(1, school);
		            ps.setInt(2, cityId);
		            java.sql.ResultSet rs = ps.executeQuery(); 
		            if (rs != null) {
		        		while (rs.next()) {
		        			recordId = rs.getInt(1);
		        		}
		            }
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertSchool    

    //EPeronja-06/16/2015: delete school 
    public static void deleteSchool(Elab elab, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM school "+
	            		" WHERE id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteSchool
 
    //EPeronja-06/16/2015: get all teachers
    public static TreeMap<Integer, ArrayList> getTeachers(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
    	TreeMap<Integer, ArrayList> teachers = new TreeMap<Integer, ArrayList>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    " SELECT teacher.id, teacher.name, teacher.email, state.abbreviation, city.name, school.name, research_group.name " +
                    " FROM teacher "+
                    " INNER JOIN research_group " +
                    "    ON research_group.teacher_id = teacher.id "+
                    " INNER JOIN school " +
                    "    ON teacher.school_id = school.id "+
                    " INNER JOIN city " +
                    "    ON school.city_id = city.id "+
                    " INNER JOIN state " +
                    "    ON city.state_id = state.id "+
                    " WHERE research_group.role = 'teacher' " +
                    " ORDER by state.abbreviation, city.name, school.name;");

            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			ArrayList singleTeacher = new ArrayList();
        			singleTeacher.add(rs.getInt(1));
        			singleTeacher.add(rs.getString(2));
        			singleTeacher.add(rs.getString(3));
        			singleTeacher.add(rs.getString(4));
        			singleTeacher.add(rs.getString(5));
        			singleTeacher.add(rs.getString(6));
        			singleTeacher.add(rs.getString(7));
        			teachers.put(rs.getInt(1), singleTeacher);
        		}
        	}   
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getTeachers(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return teachers;
    }//end of getTeachers
  
    //EPeronja-06/16/2015: get teacher name
    public static String getTeacherName(Elab elab, int id) throws ElabException {
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        String name = "";
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    "SELECT name " +
                    "  FROM teacher " +
                    " WHERE id = ? ;");
            ps.setInt(1, id);
            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			name = rs.getString(1);
        		}
        	}            
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getTeacherId(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return name;
    }//end of getTeacherName   

    //EPeronja-06/15/2015: add new teacher 
    public static int insertTeacher(Elab elab, String teacher, String email, int schoolId) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (teacher != null && !teacher.equals("") && schoolId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " INSERT INTO teacher (name, email, school_id, cosmic_all_data_access) " + 
	            		" VALUES (?, ?, ?, true) RETURNING id;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setString(1, teacher);
		            ps.setString(2, email);
		            ps.setInt(3, schoolId);
		            java.sql.ResultSet rs = ps.executeQuery(); 
		            if (rs != null) {
		        		while (rs.next()) {
		        			recordId = rs.getInt(1);
		        		}
		            }
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertTeacher    

    //EPeronja-06/16/2015: delete teacher 
    public static void deleteTeacher(Elab elab, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM teacher "+
	            		" WHERE id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteTeacher
    
    //EPeronja-06/16/2015: get all groups
    public static TreeMap<Integer, ArrayList> getGroups(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
    	TreeMap<Integer, ArrayList> groups = new TreeMap<Integer, ArrayList>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    " SELECT id, name, teacher_id, userarea, ay " +
                    " FROM research_group ;");

            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			ArrayList singleGroup = new ArrayList();
        			singleGroup.add(rs.getInt(1));
        			singleGroup.add(rs.getString(2));
        			groups.put(rs.getInt(1), singleGroup);
        		}
        	}   
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getGroups(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return groups;
    }//end of getGroups

    //EPeronja-06/15/2015: add new research group 
    public static int insertGroup(Elab elab, String group, String hashedPassword, String role, String newUserArea, String ay, String survey, int teacherId) throws ElabException {
       	java.sql.ResultSet rs;
        Connection conn = null;
        int recordId = 0;
        PreparedStatement ps = null;
        if (group != null && !group.equals("") && teacherId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
                String SQLstatement = "INSERT INTO research_group (name, hashedpassword, teacher_id, role, userarea, ay, active, survey) SELECT " +
                        "'" + group + "', " +
                        "'" + hashedPassword + "', " +
                        "id, " +
                        "'" + role + "', " +
                        "'" + newUserArea + "', " + 
                        "'" + ay + "', " +
                        "true, " +
                        "'" + survey + "'" +
                        "FROM teacher WHERE teacher.id ='" + teacherId + "' RETURNING research_group.id;";
                ps = conn.prepareStatement(SQLstatement);
                try{
		            conn.setAutoCommit(false);
                   	rs = ps.executeQuery();
		            if (rs != null) {
		            	if (rs.next()) {
		            		recordId = rs.getInt(1);
		            	}
		            }
                	conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertGroup    

    //EPeronja-06/16/2015: delete group 
    public static void deleteGroup(Elab elab, int id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM research_group "+
	            		" WHERE id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteGroup
    
    //EPeronja-06/15/2015: add new research group/project
    public static int insertGroupProject(Elab elab, int projectId, int researchGroupId) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (projectId > 0 && researchGroupId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " INSERT INTO research_group_project (research_group_id, project_id) " +
                        " VALUES (?, ?) ;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, researchGroupId);
		            ps.setInt(2, projectId);
		            recordId = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    	return recordId;
    }//end of insertGroupProject

    //EPeronja-06/16/2015: delete research group/project
    public static void deleteGroupProject(Elab elab, int research_group_id, int project_id) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (research_group_id > 0 && project_id > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM research_group_project "+
	            		" WHERE research_group_id = ? and project_id = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, research_group_id);
		            ps.setInt(2, project_id);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteGroupProject
    
    //EPeronja-06/15/2015: add new research group/detector
    public static int insertGroupDetector(Elab elab, int researchGroupId, String[] detectorIds) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        int recordId = 0;
        if (detectorIds != null  && researchGroupId > 0 ) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            for (int i = 0; i < detectorIds.length; i++) {
	            	ps = conn.prepareStatement(
	            			" INSERT INTO research_group_detectorid (research_group_id, detectorid) " +
	            		    " VALUES (?,?);"); 
	            	try {
	            		conn.setAutoCommit(false);
	            		ps.setInt(1, researchGroupId);
	            		ps.setInt(2, Integer.valueOf(detectorIds[i]));
			            recordId = ps.executeUpdate();
			            conn.commit();
	            	} catch (SQLException e) {
	            		conn.rollback();
	            		throw e;
	            	} finally {
	            		conn.setAutoCommit(ac);
	            	}
	            }
	         } catch (SQLException e) {
	        	 throw new ElabException(e);
	         } finally {
	        	 if (conn != null) {
	        		 DatabaseConnectionManager.close(conn, ps);
	        	 }
	         }
        }
    	return recordId;
    }//end of insertGroupDetector    

    //EPeronja-06/16/2015: delete research group/detector
    public static void deleteGroupDetector(Elab elab, int group, int detector) throws ElabException {
        Connection conn = null;
        PreparedStatement ps = null;
        if (group > 0 && detector > 0) {
	        try {
	            conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	            boolean ac = conn.getAutoCommit();
	            ps = conn.prepareStatement(
	                    " DELETE FROM research_group_detectorid "+
	            		" WHERE research_group_id = ? and detectorid = ?;"); 
	            try {
		            conn.setAutoCommit(false);
		            ps.setInt(1, group);
		            ps.setInt(2, detector);
		            int i = ps.executeUpdate();
		            conn.commit();
	            } catch (SQLException e) {
		            conn.rollback();
		            throw e;
		        } finally {
		            conn.setAutoCommit(ac);
		        }
	        } catch (SQLException e) {
		        throw new ElabException(e);
	        } finally {
		        if (conn != null) {
		            DatabaseConnectionManager.close(conn, ps);
		        }
		    }    	
        }
    }//end of deleteGroupDetector    
    
    //EPeronja-06/16/2015: get all groups
    public static TreeMap<Integer, String> getProjects(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        TreeMap<Integer, String> projects = new TreeMap<Integer, String>();
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
						/* Created `project_active` to account for projects becoming 
							 inactive - JG 21Aug2019 */
            /*ps = con.prepareStatement(
                    " SELECT id, name " +
                    " FROM project ;"); */
						ps = con.prepareStatement(
										" SELECT project.id, project.name " +
										" FROM project " +
										" INNER JOIN project_active " +
										" ON (project.id = project_active.project_id);");
            rs = ps.executeQuery(); 
        	if (rs != null) {
        		while (rs.next()) {
        			projects.put(rs.getInt(1), rs.getString(2));
        		}
        	}   
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getProjects(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return projects;
    }//end of getProjects

     //EPeronja-06/12/2013: 63: Data search by state requires 2-letter state abbreviation
    public static String checkStateSearch(Elab elab, String userInput) throws ElabException {
    	String abbreviation = "";
        Connection con = null;
        PreparedStatement ps = null;
        //check state
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    "SELECT abbreviation " +
                    "  FROM state " +
                    " WHERE lower(name) = ?" +
                    "    OR lower(abbreviation) = ?" +
                    " LIMIT 1;");
            ps.setString(1, userInput.toLowerCase());
            ps.setString(2, userInput.toLowerCase());
            java.sql.ResultSet rs = ps.executeQuery(); 
            if (rs.next()) {
                abbreviation = rs.getString(1);
            }
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.checkStateSearch(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        

    	return abbreviation;
    }//end of checkStateSearch
    
    /**
     * Builds a figure caption from a set of data files. This is Cosmic specific
     * and should be moved there. The caption is composed of the list of data
     * files, the set of detectors that captured the data and the set of
     * channels in the data.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A list of logical file names for the data
     * 
     * @return A figure caption
     */
    public static String getFigureCaption(Elab elab, Collection<String> files)
            throws ElabException {
        if (files == null || files.size() == 0) {
            return "";
        }
        StringBuffer data = new StringBuffer();
        Set<Object> detectors = new HashSet<Object>();
        

        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        data.append("Data: ");
        int dataCount = 0;
        
        Iterator<CatalogEntry> i = rs.iterator();
        while (i.hasNext()) {
            CatalogEntry e = i.next();
            if (e == null) {
                continue;
            }
            //EPeronja: do not add to caption if file does not exists
    		String dataFile = RawDataFileResolver.getDefault().resolve(elab, e.getLFN());
    		java.io.File df = new java.io.File(dataFile);
    		try {
    			if (!df.exists()) {
    				continue;
    			}
    		} catch (Exception ex) {
    			data.append(ex.toString()+"\n");
    		}
            detectors.add(e.getTupleValue("detectorid"));
            if (dataCount < 8) {
                data.append(e.getTupleValue("school"));
                data.append(' ');
                Object date = e.getTupleValue("startdate");
            
                if (date != null) {
                    data.append(TZ_DATE_TIME_FORMAT.format(date));
                    data.append(" UTC");
                    dataCount++;
                }
                if (i.hasNext()) {
                    data.append("\n");
                }
            }
            else if (dataCount != Integer.MAX_VALUE) {
                data.deleteCharAt(data.length() - 1);
                data.append("\n...");
                dataCount = Integer.MAX_VALUE;
            }
        }
        data.append('\n');
        if (detectors.size() > 1) {
            data.append("Detectors: ");
        }
        else {
            data.append("Detector: ");
        }
        data.append(ElabUtil.join(detectors, ", "));
        return data.toString();
    }
    
    public static String getFigureCaption(Elab elab, String[] files) throws ElabException {
        return getFigureCaption(elab, Arrays.asList(files));
    }

    public static TreeMap<String,String> getDAQLatestUploadData(Elab elab) throws ElabException{
    	java.sql.ResultSet rs;
        Connection con = null;
        PreparedStatement ps = null;
        TreeMap<String,String> daqUploadDetails = new TreeMap<String,String>();
        try {
            con = DatabaseConnectionManager.getConnection(elab.getProperties()); 
            ps = con.prepareStatement(
                    " SELECT detectorid, " +
                    "        latest_upload_date, " +
                    "        total_uploads, " +
                    "        teacher, " +
                    "        school, " +
                    "        city, " +
                    "        state, " +
                    "		 stacked " +
                    " FROM detector_upload_details;");

            rs = ps.executeQuery(); 
            if (rs != null) {
           	 while (rs.next()) {
                  SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
           		  String upload_date = dateFormat.format(rs.getTimestamp(2));
           		  String details = rs.getString(5) + "," + rs.getString(6) + "," + rs.getString(7) + "," + Boolean.toString(rs.getBoolean(8)) + "," + rs.getString(4) + "," + upload_date + "," + String.valueOf(rs.getString(3));
           		  daqUploadDetails.put(rs.getString(1), details);
           	 }
            }            
        }
        catch (SQLException e) {
            throw new ElabException("In DataTools.getDAQLatestUploadData(): " + e.getMessage());
        }
        finally {
            DatabaseConnectionManager.close(con, ps);
        }        
    	return daqUploadDetails;
     }//end of getDAQLatestUploadData
    
    public static void updateDAQLatestUploadData(Elab elab, String detectorid, String latest_upload_date, String count, 
    			String teacher, String school, String city, String state, String stacked) throws Exception{
        Connection conn = null;
        PreparedStatement ps = null;
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        Date parsedDate = dateFormat.parse(latest_upload_date);
        Timestamp timestamp = new java.sql.Timestamp(parsedDate.getTime());
        int recordId = 0;
	    try {
	    	conn = DatabaseConnectionManager.getConnection(elab.getProperties()); 
	        boolean ac = conn.getAutoCommit();
	        //update or insert
	        ps = conn.prepareStatement(
	                " SELECT total_uploads " +
	                " FROM detector_upload_details" +
	                " WHERE detectorid = ?;");
	        ps.setString(1, detectorid);
	        java.sql.ResultSet rs = ps.executeQuery(); 
	        int uploadCount = 0;
	        if (rs.next()) {
	        	uploadCount = rs.getInt(1);
	        }
	        
	        if (uploadCount == 0) {
	        	//insert
            	ps = conn.prepareStatement(
            			" INSERT INTO detector_upload_details (detectorid, latest_upload_date, total_uploads, teacher, school, city, state, stacked) " +
            		    " VALUES (?,?,?,?,?,?,?,?);"); 
            	try {
            		conn.setAutoCommit(false);
            		ps.setString(1, detectorid);
            		ps.setTimestamp(2, timestamp);
            		ps.setInt(3, Integer.parseInt(count));
            		ps.setString(4, teacher);
            		ps.setString(5, school);
            		ps.setString(6, city);
            		ps.setString(7, state);
            		ps.setBoolean(8, Boolean.valueOf(stacked));
            		recordId = ps.executeUpdate();
		            conn.commit();
            	} catch (SQLException e) {
            		conn.rollback();
            		throw e;
            	} finally {
            		conn.setAutoCommit(ac);
            	}

	        } else {
	        	//update

	        	ps = conn.prepareStatement(
            			" UPDATE detector_upload_details "+ 
            		    "    SET latest_upload_date = ?, total_uploads = ?, teacher = ?, school = ?, city = ?, state = ?, stacked = ? " +
            		    " WHERE detectorid = ?;"); 
            	try {
            		conn.setAutoCommit(false);
            		ps.setTimestamp(1, timestamp);
            		ps.setInt(2, uploadCount + Integer.parseInt(count));
            		ps.setString(3, teacher);
            		ps.setString(4, school);
            		ps.setString(5, city);
            		ps.setString(6, state);
            		ps.setBoolean(7, Boolean.valueOf(stacked));
               		ps.setString(8, detectorid);
               	    recordId = ps.executeUpdate();
		            conn.commit();
            	} catch (SQLException e) {
            		conn.rollback();
            		throw e;
            	} finally {
            		conn.setAutoCommit(ac);
            	}
	        }	       
	      } catch (SQLException e) {
	        	 throw new ElabException(e);
	      } finally {
	        	 if (conn != null) {
	        		 DatabaseConnectionManager.close(conn, ps);
	        	 }
	      }
    }//end of updateDAQLatestUploadData
    
    //EPeronja-08/13/2015: Retrieve the saved plot names by user and project
    public static ArrayList<String> getPlotNamesByGroup(Elab elab, String group, String project) throws ElabException {
 		ResultSet rs = null;
		ArrayList<String> plotNames = new ArrayList<String>();
		if (group != null && elab != null && project != null) {
			In and = new In();
			and.add(new Equals("project",project));
			and.add(new Equals("type", "plot"));
			and.add(new Equals("group", group));
			rs = elab.getDataCatalogProvider().runQuery(and);
			if (rs != null && !rs.isEmpty()) {
            	if (project.equals("ligo")) {
    				rs.sort("title", false);            		
            	} else {
    				rs.sort("name", false);
            	}
				Iterator it = rs.iterator();
				while (it.hasNext()) {
		            CatalogEntry e = (CatalogEntry) it.next();
		            String plotName = (String)e.getTupleValue("name");
	            	if (project.equals("ligo")) {
	            		plotName = (String)e.getTupleValue("title");
	            	}
					plotNames.add(plotName);
				}
			}
		}
    	return plotNames;
    }//end of getPlotNamesByGroup

    //EPeronja-08/13/2015: Retrieve the entries within a date range for reporting
    public static TreeMap<Integer,VDSCatalogEntry> getVDSCatalogEntries(Elab elab, Date startDate, Date endDate, String project, String type) throws ElabException {
 		ResultSet rs = null;
 		TreeMap<Integer,VDSCatalogEntry> results = new TreeMap<Integer,VDSCatalogEntry>();
		if (startDate != null && elab != null && startDate != null && type != null && project != null) {
			In and = new In();
			if (!project.equals("")) {
				and.add(new Equals("project",project));
			}
			and.add(new Equals("type", type));
			if (type.equals("poster")) {
				and.add(new Between("date", startDate, endDate));					
			} else {
				and.add(new Between("creationdate", startDate, endDate));	
			}
			rs = elab.getDataCatalogProvider().runQuery(and);
			Integer i = 0;
			if (rs != null && !rs.isEmpty()) {
				Iterator it = rs.iterator();
				while (it.hasNext()) {
					VDSCatalogEntry e = (VDSCatalogEntry) it.next();
					results.put(i, e);
		            i++;
				}
			}
		}
    	return results;
    }//end of getVDSCatalogEntries
    
    
    private static final String[] STRING_ARRAY = new String[0];

    /**
     * Returns a {@link Collection} of values that correspond to a specific
     * metadata key for a {@link Collection} of logical file names. Values are
     * guaranteed to not appear twice in the {@link Collection}.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A {@link Collection} of logical file names
     * @param key
     *            A metadata key
     * 
     * @return A {@link Collection} of values
     * 
     */
    public static Collection<Object> getUniqueValues(Elab elab, String[] files,
            String key) throws ElabException {
        return getUniqueValues(elab, Arrays.asList(files),
                key);
    }

    /**
     * Returns a {@link Collection} of values that correspond to a specific
     * metadata key for an array of logical file names. Values are guaranteed to
     * not appear twice in the {@link Collection}.
     * 
     * @param elab
     *            The current {@link Elab}
     * @param files
     *            A {@link Collection} of logical file names
     * @param key
     *            A metadata key
     * 
     * @return A {@link Collection} of values
     * 
     */
    public static Collection<Object> getUniqueValues(Elab elab, Collection<String> files,
            String key) throws ElabException {
        ResultSet rs = elab.getDataCatalogProvider().getEntries(files);
        Set<Object> s = new HashSet<Object>();
        for (CatalogEntry e : rs) {
        	if (e != null && e.getTupleValue(key) != null) {
        		s.add(e.getTupleValue(key));
        	}
        }
        return s;
    }
    
    public static final DateFormat DF0 = new SimpleDateFormat("MM/dd/yyyy");

    public static final DateFormat[] DFORMATS = new DateFormat[] {
            DateFormat.getDateTimeInstance(), DF0,
            DateFormat.getDateInstance(), DateFormat.getTimeInstance() };

    protected static Object coerce(String type, String value, String name) {
        try {
            if (type.equals("string")) {
                return value;
            }
            else if (type.equals("int") || type.equals("integer")
                    || type.equals("i") || type.equals("long")) {
                return Long.valueOf(value);
            }
            else if (type.equals("float") || type.equals("double")) {
                return Double.valueOf(value);
            }
            else if (type.equals("date")) {
                try {
                    return Timestamp.valueOf(value);
                }
                catch (Exception e) {
                }
                for (int i = 0; i < DFORMATS.length; i++) {
                    try {
                        return new Timestamp(DFORMATS[i].parse(value).getTime());
                    }
                    catch (Exception e) {
                    }
                }
                throw new IllegalArgumentException("Could not parse date: "
                        + value);
            }
            else if (type.equals("boolean")) {
                return Boolean.valueOf(value);
            }
            else {
                throw new IllegalArgumentException("cannot convert to type '"
                        + type + "'");
            }
        }
        catch (Exception e) {
            if (e.getClass().equals(IllegalArgumentException.class)) {
                throw (IllegalArgumentException) e;
            }
            throw new IllegalArgumentException("Could not convert " + name + " = " + value
                    + " to " + type + ": " + e.getMessage());
        }
    }

    /**
     * Builds a {@link CatalogEntry} from a logical file name and a
     * {@link Collection} of metadata descriptors. Each metadata descriptor is a
     * string of three space separated items:
     * <ol>
     * <li>The key (name)</li>
     * <li>A type. Possible values are
     * <code>"string", "integer", "int", "i", "long", "float", "double", "date"</code></li>
     * <li>The value</li>
     * </ol>
     * 
     * This method will attempt to interpret and convert the value to the
     * specified type before constructing the {@link CatalogEntry}
     * 
     * @param lfn
     *            The logical file name
     * @param metadata
     *            A {@link Collection} of metadata descriptors
     * 
     * @return A {@link CatalogEntry}
     */
    public static CatalogEntry buildCatalogEntry(final String lfn,
            final Collection<String> metadata) {
        final Map<String, Object> tuples = new HashMap<String, Object>();
        for (String m : metadata) {
            int n = m.indexOf(' ');
            int t = m.indexOf(' ', n + 1);
            if (n == -1 || t == -1) {
                throw new IllegalArgumentException("Invalid metadata entry: "
                        + m);
            }
            String name = m.substring(0, n);
            String type = m.substring(n + 1, t);
            String value = m.substring(t + 1);

            try {
            	tuples.put(name, coerce(type, value, name));
            }
            catch(IllegalArgumentException iae) {
            	// empty non-string values get ignored, all others get thrown (VDS cannot handle empty non-string metadata) 
            	if (!"string".equals(type) && StringUtils.isNotBlank(value)) {
            		throw iae; 
            	}
            }
        }

        return new CatalogEntry() {

            public String getLFN() {
                return lfn;
            }

            public Object getTupleValue(String key) {
                return tuples.get(key);
            }

            public Collection getTuples() {
                return new AbstractCollection() {
                    public Iterator iterator() {
                        return tupleIterator();
                    }

                    public int size() {
                        return tuples.size();
                    }
                };
            }

            public void setTupleValue(String key, Object value) {
                throw new UnsupportedOperationException("setTupleValue");
            }

            public Iterator<Tuple> tupleIterator() {
                final Iterator<Entry<String, Object>> i = tuples.entrySet().iterator();

                return new Iterator<Tuple>() {
                    public boolean hasNext() {
                        return i.hasNext();
                    }

                    public Tuple next() {
                        Entry<String, Object> e = i.next();
                        return new Tuple(e.getKey(), e.getValue());
                    }

                    public void remove() {
                        throw new UnsupportedOperationException("remove");
                    }
                };
            }
        };
    }
}

