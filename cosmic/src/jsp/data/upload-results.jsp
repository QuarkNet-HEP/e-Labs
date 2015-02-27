<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.analysis.ElabAnalysis" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.CosmicPostUploadTasks" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ page import="gov.fnal.elab.cosmic.bless.BlessProcess" %>
<%@ page import="gov.fnal.elab.cosmic.analysis.ThresholdTimes" %>

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
	//String lfn="";              //lfn on the USERS home computer
	//String fn = "";             //filename without slashes
	//String ds = "";
	File f = new File((String) results.getAnalysis().getParameter("in"));
	String detectorId = (String) results.getAnalysis().getParameter("detectorid");
	//String comments = (String) results.getAnalysis().getParameter("comments");
	//String benchmark = (String) results.getAnalysis().getParameter("benchmark");
	
	String dataDir = elab.getProperties().getDataDir();
	int channels[] = new int[4];

	List splits = new ArrayList();  //for both the split name and the channel validity information
	
	//boolean c = true;
	//String splitPFNs = "";
	//String cpldFrequency = "";
	String rawName = f.getName();
	CatalogEntry entry;
	String errorMessage = "";
	
	//get metadata which contains the lfns of the raw filename AND the split files
	ArrayList meta = null;
	//boolean metaSuccess = false;
	//boolean totalSuccess = true;        //false if there are any rc.data or meta errors
	File fmeta = new File(f.getAbsolutePath() + ".meta");     //depends on Split.pl writing the meta to rawName.meta
	String sqlErrors = "";
	//EPeronja-added the following code for admin to be able to access the upload results
    String userParam = (String) request.getParameter("user");
    if (userParam == null) {
    	userParam = (String) session.getAttribute("userParam");
    }
    session.setAttribute("userParam", userParam);
    ElabGroup auser = user;
    if (userParam != null) {
       auser = elab.getUserManagementProvider().getGroup(userParam);
    }
    if (fmeta.canRead()) {
    	BufferedReader br = new BufferedReader(new FileReader(fmeta));
        String line = null;
        String currLFN = null;
        String currPFN = null;
        while ((line = br.readLine()) != null) {
            String[] temp = line.split("\\s", 3);

            //read from .meta to display results
            if(temp[0].equals("[SPLIT]") || temp[0].equals("[RAW]")){
                currPFN = temp[1];
	            currLFN = temp[1].substring(temp[1].lastIndexOf('/') + 1);
    	        if(temp[0].equals("[RAW]")) {
        	        //don't write the raw datafile to rc.data - already written above
        	        rawName = currLFN;
                }
                else if(temp[0].equals("[SPLIT]")) {
	                splits.add(currLFN);
                }
            }
        }   //done reading file

		//to display channels
        Iterator l = splits.iterator();
		List entries = new ArrayList();
		while (l.hasNext()) {
			try {
			    CatalogEntry s = elab.getDataCatalogProvider().getEntry((String) l.next());
			    entries.add(s);
			    for (int k = 0; k < 4; k++) {
			        channels[k] += ((Long) s.getTupleValue("chan" + (k + 1))).intValue();
			    }
			} catch (Exception e) {
				errorMessage = e.getMessage();
			}
		}
		

		request.setAttribute("detectorId", detectorId);
		sqlErrors = (String) results.getAnalysis().getParameter("message");
		request.setAttribute("sqlErrors", sqlErrors);
		ArrayList<String> benchmarkMessages = (ArrayList<String>) results.getAnalysis().getParameter("benchmarkMessages");
		request.setAttribute("benchmarkMessages", benchmarkMessages);
		request.setAttribute("channels", channels);
		request.setAttribute("splitEntries", entries);
		request.setAttribute("errorMessage", errorMessage);
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
    	<h2>File Summary for DAQ: <%=detectorId %></h2>
 
<c:choose>
	<c:when test='${errorMessage == "" }'>    
    	Your data was split into ${lfnssz} ${lfnssz == 1 ? 'day' : 'days'} spanning from:<br/>
    	${entry.tupleMap.startdate} to ${entry.tupleMap.enddate}<br/>
    	The uploaded file contained ${entry.tupleMap.totalDataLines} accepted data lines. We ignored ${entry.tupleMap.GPSSuspects} line(s) due to a suspect GPS date.
    	
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
		<br />	
		<c:choose>
			<c:when test="${not empty benchmarkMessages}">
			   <table>
			   		<tr><th>Benchmark Results</th></tr>
					<c:forEach items="${benchmarkMessages}" var="benchmarkMessages">
						<tr><td>${benchmarkMessages}</td></tr>
					</c:forEach>
				</table>
			</c:when>
		</c:choose>
		<c:choose>		
			<c:when test="${not empty sqlErrors}">
				<p>Error(s) updating metadata, please send the message below to <a href="mailto:e-labs@fnal.gov">e-labs@fnal.gov</a></p>
				<p>${sqlErrors}</p>
			</c:when>
		</c:choose>
	</c:when>
	<c:otherwise>
		These files do not exist any longer in our server. They may have been deleted.<br />
		If you have any questions please send a message to <a href="mailto:e-labs@fnal.gov">e-labs@fnal.gov</a>	
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
