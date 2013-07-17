<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>

<%
	ElabUserManagementProvider p = elab.getUserManagementProvider();
	CosmicElabUserManagementProvider cp = null;
	if (p instanceof CosmicElabUserManagementProvider) {
		cp = (CosmicElabUserManagementProvider) p;
	}
	else {
		throw new ElabJspException("The user management provider does not support management of DAQ IDs. ");
	}    
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	
	String reqType = request.getParameter("submitButton");
	String selectedBenchmark = request.getParameter("selectedBenchmark");
	String includeBlessed = request.getParameter("includeBlessed");
	String selectedDetector = "";
	String benchmark = "";
	ArrayList<String> results = new ArrayList<String>();

	//save changes if we get all parameters to do so
	if ("Bless Files".equals(reqType)){
		selectedDetector = request.getParameter("detector");
		benchmark = request.getParameter("benchmark");
		
		String[] filesToBless = request.getParameterValues("blessfiles");
		if (filesToBless != null) {
			BlessProcess bp = new BlessProcess();
			results = bp.BlessDatafiles(elab, selectedDetector, filesToBless, benchmark);
		}
	}
	request.setAttribute("results", results);
	//get detectors and benchmark files
	Collection detectors = cp.getDetectorIds(user);
	ResultSet searchResults = null;
	String defaultBenchmark = "";
	String firstDataFile = "";
	TreeMap<String, String> filenameDisplay = new TreeMap<String, String>();
	TreeMap<String, Integer> unblessedForDetector = new TreeMap<String, Integer>();
	TreeMap<String, VDSCatalogEntry> benchmarkTuples = new TreeMap<String, VDSCatalogEntry>();
	
	if (!selectedDetector.equals("")) {
	  	//retrieve unblessed files for this detector
	  	Integer key = Integer.parseInt(selectedDetector);
		//get benchmark files so we can retrieve candidates for the selected detector
	  	searchResults = Benchmark.getBenchmarkFileName(elab, key);
  		String[] benchmarks = searchResults.getLfnArray();
		defaultBenchmark = "";
		for (int i = 0; i < benchmarks.length; i++){
			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(benchmarks[i]);
  			benchmarkTuples.put(benchmarks[i], e);
  		  	//if there is no selected benchmark, then we need to use the default		
  			if (selectedBenchmark.equals("")) {
	  			if (e != null) {
					if (e.getTupleValue("benchmarkdefault").toString().equals("true")) {
						defaultBenchmark = e.getLFN();					
		  			}
				}
  			} else {
  				defaultBenchmark = selectedBenchmark;
  			}
		}
		if (defaultBenchmark != null && !defaultBenchmark.equals("")) {
			if (includeBlessed.equals("YES")) {
				searchResults = Benchmark.getAllFilesByBenchmarkGeometry(elab, key, defaultBenchmark);
			} else {
				searchResults = Benchmark.getUnblessedFilesByBenchmarkGeometry(elab, key, defaultBenchmark);
			}
			if (searchResults != null) {
				String [] filenames = searchResults.getLfnArray();
		  		for (int i=0; i < filenames.length; i++) {
					VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);		  			
					String display = Benchmark.getIcons(entry);
		  			unblessedForDetector.put(filenames[i], key);
		  			filenameDisplay.put(display, filenames[i]);
		  		}
				if (filenameDisplay.size() > 0) {
					Entry<String,String> firstEntry = filenameDisplay.firstEntry();
					firstDataFile = firstEntry.getValue();
				}
				request.setAttribute("firstDataFile", firstDataFile);
			}
		}
	}//end of checking if there was a detector selected
	request.setAttribute("detectors", detectors);

	if (benchmarkTuples.isEmpty()) {
		request.setAttribute("unblessedForDetector", "");		
	} else {
		request.setAttribute("unblessedForDetector", unblessedForDetector);		
	}
	request.setAttribute("benchmarkTuples", benchmarkTuples);
	request.setAttribute("defaultBenchmark", defaultBenchmark);
	request.setAttribute("detector", selectedDetector);
	request.setAttribute("filenameDisplay", filenameDisplay);
%>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<title>Blessing Process</title>
			<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
			<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
			<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
			<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>
			<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>		
			<script type="text/javascript" src="../include/elab.js"></script>
        	<script type="text/javascript" src="../../dwr/interface/UploadMonitor.js"></script>
        	<script type="text/javascript" src="../../dwr/engine.js"></script>
        	<script type="text/javascript" src="../../dwr/util.js"></script>
		</head>
		
		<body id="benchmark-process">
			<!-- entire page container -->
			<div id="container">
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
						<%@ include file="../include/nav-rollover.jspf" %>
					</div>
				</div>
				<div id="content">
			<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
			<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
			<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
			<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
			<script type="text/javascript" src="../include/excanvas.min.js"></script>
			<script type="text/javascript" src="blessing.js"></script>	
			<script type="text/javascript" src="benchmark.js"></script>      
			<script>
			$(document).ready(function() {
				if ("<%=firstDataFile%>" != null && "<%=firstDataFile%>" != "") {
					showCharts("<%=firstDataFile%>", "get-data.jsp?file=");
				}
			});		
			</script>			
<h1>Bless uploaded datafiles.</h1>
<ul>
	<li>Select <strong>detector</strong> to display unblessed datafiles. Select <strong>'Retrieve All' checkbox</strong> if you want to re-bless files.</li>
	<li>Select <strong>benchmark</strong> file from drowpdown.</li>
	<li>Select <strong>files to bless</strong> from datafiles uploaded with the same geometry as the selected benchmark.</li>
	<li><strong>Bless</strong> files.</li>
</ul>
<form id="benchmarkProcessForm" method="post" >
	<table style="border: 1px solid black; width: 100%; padding: 10px;">
	    <tr class="benchmarkRow">
	    	<td class="benchmarkHeader">Detector<br />
	    		<select name="detectorId" id="detectorId" onChange="javascript:showAllFiles(this);">
   			    	<option>Choose detector</option>
   						<c:forEach items="${detectors}" var="detectors">
   				  			<c:choose>
		   				  		<c:when test="${detectors == detector}">
		 						      <option value="${detectors}" selected="true">${detectors}</option>
		 						</c:when>
		 						<c:otherwise>
		 						      <option value="${detectors}">${detectors}</option> 						
		 						</c:otherwise>
		 				   	</c:choose>
	   					</c:forEach>
   				</select>
   				<input type="checkbox" id="blessAll" name="blessAll" onclick="javascript:retrieveAll();">Retrieve all</input>
   			</td>
   			<td class="benchmarkHeader">Benchmark<br />
  			    <c:choose>
   			      <c:when test="${not empty benchmarkTuples}">
		   				<select name="benchmark" id="benchmark" onChange="javascript:showCandidates(this);">
	   						<c:forEach items="${benchmarkTuples}" var="benchmarkTuples">
	   				  			<c:choose>
			   				  		<c:when test="${benchmarkTuples.key == defaultBenchmark}">
			 						      <option value="${benchmarkTuples.key}" selected="true">${benchmarkTuples.value.tupleMap.benchmarklabel}</option>
			 						</c:when>
			 						<c:otherwise>
			 						      <option value="${benchmarkTuples.key}">${benchmarkTuples.value.tupleMap.benchmarklabel}</option> 						
			 						</c:otherwise>
			 				   	</c:choose>
		   					</c:forEach>
		   				</select>   
		   			</c:when>
		   			<c:otherwise>
		   				<a href="benchmark.jsp">Add</a>
		   			</c:otherwise>
				</c:choose>   			   			
   			</td>
   			<td class="benchmarkHeader">
				<input type="submit" name="submitButton" id="submitButton" value="Bless Files" ></input>
   			</td>
   	    </tr>
	    <c:choose>
		     <c:when test="${not empty unblessedForDetector}">
	    	 	<tr>
					<td class="benchmarkHeader" colspan="3"><input type="checkbox" name="checkAll" id="checkAll" onclick="javascript:selectAll(this);">Bless all files</input></td>
	    	 	</tr>
	    	 </c:when>
	    	 <c:otherwise>
		    	 <c:choose>
		    	 	<c:when test="<%= selectedDetector == null %>">
			    		<tr>
			    			<td>There are no benchmark files set for this detector. <a href="benchmark.jsp">Add</a> file.</td>
			    		</tr> 
	 		   		</c:when>
	    		</c:choose>
	    	 </c:otherwise>
	    </c:choose>
   	 	<tr>
		  	<td colspan="3"><div name="messages" id="messages" class="messages"></div></td>
  	   </tr>   	    
	  <tr>
	    <td nowrap class="detectorList">
    		<c:choose>
    		  <c:when test="${not empty unblessedForDetector }"> 				  
    		  	<div class="detectorTable" id="tableWrapper">
					<c:forEach items="${filenameDisplay}" var="filename">
					  <div id="${filename.value}">
     					<table id="table${filename.value}" class="highlight">
							<tr>
								<td class="benchmarkSelection"><input type="checkbox" name="blessfiles" id="checkbox_${filename.value}" value="${filename.value}"></input></td>
								<td><a href="#charts" onclick='javascript:showCharts("${filename.value}", "get-data.jsp?file=");'>${filename.value}</a> ${filename.key}</td>
							</tr>
						</table>
					  </div>
					</c:forEach>					
				</div>
			  </c:when>
			</c:choose>
		</td>
		<td style="vertical-align: top;" colspan="2">
    		<c:choose>
    		  <c:when test="${not empty unblessedForDetector }"> 				  
				<%@ include file="benchmark-charts.jspf" %>
			  </c:when>
		 	</c:choose>
		</td>
      </tr>
  	  <c:if test="${empty unblessedForDetector}">
		<c:if test="${not empty benchmarkTuples}">
			<tr>
				<td colspan="3">There are NO unblessed files with the same geometry as the benchmark.</td>
			</tr>
		</c:if>
	  </c:if>
	</table>
	<input type="hidden" name="detector" id="detector" value="${detector}"></input>
	<input type="hidden" name="selectedBenchmark" id="selectedBenchmark" value="${selectedBenchmark}"></input>
	<input type="hidden" name="includeBlessed" id="includeBlessed" value="NO"></input>
</form>
<c:choose>
     <c:when test="${not empty results}">
 			<c:forEach items="${results}" var="result">
 				<p>${result}</p>
 			</c:forEach>
	</c:when>
</c:choose>
				</div>
				<!-- end content -->	
			
				<div id="footer">
				</div>
			</div>
			<!-- end container -->
		</body>
	</html>
	