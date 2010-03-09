<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Upload Raw Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/upload.js"></script>
        <script type="text/javascript" src="../../dwr/interface/UploadMonitor.js"></script>
        <script type="text/javascript" src="../../dwr/engine.js"></script>
        <script type="text/javascript" src="../../dwr/util.js"></script>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<h1>Upload results</h1>


<%

	String lfn="";              //lfn on the USERS home computer
	String fn = "";             //filename without slashes
	String ds = "";
	File f = new File((String) results.getAnalysis().getParameter("in"));
	String detectorId = (String) results.getAnalysis().getParameter("detectorid");
	String comments = (String) results.getAnalysis().getParameter("comments");
	String dataDir = elab.getProperties().getDataDir();
	int channels[] = new int[4];

	List splits = new ArrayList();  //for both the split name and the channel validity information

	boolean c = true;
	String splitPFNs = "";
	String cpldFrequency = "";
	String rawName = f.getName();
	CatalogEntry entry;
	
	//get metadata which contains the lfns of the raw filename AND the split files
	ArrayList meta = null;
	boolean metaSuccess = false;
	boolean totalSuccess = true;        //false if there are any rc.data or meta errors
	File fmeta = new File(f.getAbsolutePath() + ".meta");     //depends on Split.pl writing the meta to rawName.meta
	if (fmeta.canRead()) {
    	BufferedReader br = new BufferedReader(new FileReader(fmeta));
        String line = null;
        String currLFN = null;
        String currPFN = null;
        while ((line = br.readLine()) != null) {
            String[] temp = line.split("\\s", 3);

            //if this is a new lfn to add...
            if(temp[0].equals("[SPLIT]") || temp[0].equals("[RAW]")){
	            //add metadata if we have all the information for a previous LFN
    	        if(meta != null && currLFN != null) {
        	        try {
        	            entry = DataTools.buildCatalogEntry(currLFN, meta);
        	            elab.getDataCatalogProvider().insert(entry);
                	} 
        	        catch (ElabException e) {
                	    throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
                    }
                }

                //start a new metadata array
                meta = new ArrayList();
                currPFN = temp[1];
	            currLFN = temp[1].substring(temp[1].lastIndexOf('/') + 1);
    	        if(temp[0].equals("[RAW]")) {
        	        //don't write the raw datafile to rc.data - already written above
        	        rawName = currLFN;
                }
                else if(temp[0].equals("[SPLIT]")) {
                    // Add split physical file name to array list used by ThresholdTimes.
	                // we actually don't use that any more
	                splits.add(currLFN);
                }

                //metadata for both RAW and SPLIT files
                meta.add("origname string " + lfn); //add in the original name from the users computer to metadata
                meta.add("blessed boolean false");
	            meta.add("group string " + user.getName());
    	        meta.add("teacher string " + elab.getUserManagementProvider().getTeacher(user).getName());
        	    meta.add("school string " + user.getSchool());
            	meta.add("city string " + user.getCity());
                meta.add("state string " + user.getState());
                meta.add("year string " + user.getYear());
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

        //do one last add at the end of reading the temp metadata file
        if (meta != null && currLFN != null) {
            try {
                entry = DataTools.buildCatalogEntry(currLFN, meta);
				elab.getDataCatalogProvider().insert(entry);
			}
			catch (ElabException e) {
				throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
            }
        }
	}
    else {
        throw new ElabJspException("Error reading metadata file: " + f.getAbsolutePath() + ".meta");
    }

	Iterator l = splits.iterator();
	List entries = new ArrayList();
	while (l.hasNext()) {
	    CatalogEntry s = elab.getDataCatalogProvider().getEntry((String) l.next());
	    entries.add(s);
	    for (int k = 0; k < 4; k++) {
	        channels[k] += ((Long) s.getTupleValue("chan" + (k + 1))).intValue();
	    }
	}
	request.setAttribute("channels", channels);
	request.setAttribute("splitEntries", entries);
	CatalogEntry e = elab.getDataCatalogProvider().getEntry(rawName);
	request.setAttribute("entry", e);
	request.setAttribute("id", detectorId);
	request.setAttribute("lfnssz", new Integer(entries.size()));
	File geoFile = new File(new File(dataDir, detectorId), detectorId + ".geo");
	if (geoFile.exists() && geoFile.isFile() && geoFile.canRead()) {
	    request.setAttribute("geoFileExists", Boolean.TRUE);
	}
	else {
	    request.setAttribute("geoFileExists", Boolean.FALSE);
	}
	%>
    	
    	<c:choose>
    		<c:when test="${geoFileExists}">
    			If you have <strong>changed</strong> the configuration of your detector 
    			since your last upload, please check to make sure that your <br/>
    			<a href="../geometry/edit.jsp?detectorID=${id}&jd=${entry.tupleMap.julianstartdate}&latitude=${entry.tupleMap.avglatitude}&longitude=${entry.tupleMap.avglongitude}&altitude=${entry.tupleMap.avgaltitude}">
					Geometry Information</a> was updated correctly.<br/><br/>
    		</c:when>
    		<c:otherwise>
    			This looks like the first file you've uploaded for detector ${id} <br/>
    			Please check to make sure that your 
    			<a href="../geometry/new.jsp?detectorID=${id}&jd=${entry.tupleMap.julianstartdate}&latitude=${entry.tupleMap.avglatitude}&longitude=${entry.tupleMap.avglongitude}&altitude=${entry.tupleMap.avgaltitude}">
					Geometry Information</a> was updated correctly.<br/><br/>
    		</c:otherwise>
    	</c:choose>
    	<hr/>
    	<h2>File Summary:</h2>
    
    	Your data was split into ${lfnssz} ${lfnssz == 1 ? 'day' : 'days'} spanning from:<br/>
    	${entry.tupleMap.startdate} to ${entry.tupleMap.enddate}
    	
    	<table id="channels-table">
    		<tr>
    			<th></th>
    			<th>Chan 1</th>
    			<th>Chan 2</th>
    			<th>Chan 3</th>
    			<th>Chan 4</th>
    		</tr>
    		<tr>
    			<td>Total Events</td>
    			<td>${channels[0]}</td>
    			<td>${channels[1]}</td>
    			<td>${channels[2]}</td>
    			<td>${channels[3]}</td>
    		</tr>
		</table>

		<c:choose>
			<c:when test="${entry.tupleMap.avglatitude == '0'}">
				<%--if it were truly 0, it would be 0.0.0 in the metadata --%>
				No valid GPS information found in your data.<br/>
				Either the "DG" command was not run or the GPS did not see enough satellites.<br/><br/>
			</c:when>
			<c:otherwise>
				Average latitude: ${entry.tupleMap.avglatitude}<br/>
				Average longitude: ${entry.tupleMap.avglongitude}<br/>
				Average altitude: ${entry.tupleMap.avgaltitude}<br/>
			</c:otherwise>
		</c:choose>		

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
