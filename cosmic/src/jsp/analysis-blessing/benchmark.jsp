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
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>

<%
	// EPeronja-05/21/2013: 472-Benchmark file maintenance
	//						Add, remove and set default benchmark files per detector.
	//	TODO: create a css file for benchmark
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
	
	//save changes when submitting
	String reqType = request.getParameter("submitButton");
	if ("Save Changes".equals(reqType)){
		//check if we are changing default benchmark file
		String filename = request.getParameter("filename");
		if (!filename.equals("")) {
			//first check if there is a default and set it to false
			String detectorId = request.getParameter("detectorId");
			Integer detector = Integer.parseInt(detectorId);
			String defaultBenchmark = Benchmark.getDefaultBenchmark(elab, detector);
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			if (!defaultBenchmark.equals("")) {
		    	CatalogEntry ce = dcp.getEntry(defaultBenchmark);
		    	ce.setTupleValue("benchmarkdefault", false);
		    	dcp.insert(ce);
		    }
			//now make the chosen one default
			String def = request.getParameter("defaultBenchmark");
			boolean defaultIt = (def.equals("true") ? true: false);
			CatalogEntry entry = dcp.getEntry(filename);
			entry.setTupleValue("benchmarkdefault", defaultIt);
			dcp.insert(entry);			
		}//end of setting/removing default benchmark file
		
		//check if we are removing a benchmark file			
		String removeBenchmark = request.getParameter("removeBenchmark");
		if (!removeBenchmark.equals("")) {
			//look for all the datafiles that have this file set as their benchmark reference
			ResultSet rsBlessed = Benchmark.getBlessedDataFilesByBenchmark(elab, removeBenchmark);
	  		String[] blessedFiles = rsBlessed.getLfnArray();
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			//remove the reference
		    for (int i = 0; i < blessedFiles.length; i++) {
		    	CatalogEntry ce = dcp.getEntry(blessedFiles[i]);
		    	ce.setTupleValue("benchmarkreference","");
		    	dcp.insert(ce);
		    }
		    //now let's deal with the benchmark file
			CatalogEntry entry = dcp.getEntry(removeBenchmark);					
			entry.setTupleValue("benchmarkfile", false);
			entry.setTupleValue("benchmarkdefault", false);
			dcp.insert(entry);			
		}//end of removing benchmark file		
	}
	
	//get detectors and benchmark files
	Collection detectors = cp.getDetectorIds(user);
	Iterator iterator = detectors.iterator();
	TreeMap<String, Integer> detectorBenchmark = new TreeMap<String, Integer>();
	TreeMap<String, VDSCatalogEntry> benchmarkTuples = new TreeMap<String, VDSCatalogEntry>();
	ResultSet searchResults = null;

	//loop through detectors
	while (iterator.hasNext()) {
		Integer key = Integer.parseInt((String) iterator.next());
	  	//retrieve benchmark files from database
  		searchResults = Benchmark.getBenchmarkFileName(elab, key);
	  	if (searchResults != null) {
	 		String[] filenames = searchResults.getLfnArray();
	 		for (int i = 0; i < filenames.length; i++){
				VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
				if (e != null) {
					benchmarkTuples.put(filenames[i], e);
					detectorBenchmark.put(filenames[i], key);				}				
			}//end for loop
	  	}//end check searchResults
	}//end looping through detectors

	//set the calendar to a month prior by default 
	//the criteria to retrieve datafiles will probably change but we need some type of range otherwise
	//we will be retrieving all the files.
	Calendar lastMonth = Calendar.getInstance();
	lastMonth.add(Calendar.MONTH,-1);				
	request.setAttribute("lastMonth", lastMonth);
	request.setAttribute("detectors", detectors);
	request.setAttribute("detectorBenchmark", detectorBenchmark);
	request.setAttribute("benchmarkTuples", benchmarkTuples);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark File</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>		
		<script type="text/javascript" src="../include/elab.js"></script>
		<script>
			$(document).ready(function() {
				var calendarParam = {
						showOn: 'button', 
						buttonImage: '../graphics/calendar-blue.png',
						buttonImageOnly: true, 
						changeMonth: true,
						changeYear: true, 
						showButtonPanel: true,
						minDate: new Date(2000, 11-1, 30), // Earliest known date of data - probably should progamatically find. 
						maxDate: new Date() // Should not look later than today
				}
			$('.datepicker').datepicker(calendarParam);
			$("#sinceDate").datepicker('option', 'buttonText', 'Choose start date for data files.');
			$('img.ui-datepicker-trigger').css('vertical-align', 'text-bottom'); 			
			});				
		</script>	
		<script>
			function setDefault(checkedObject, detector, fileName) {
				var filename = document.getElementById("filename");
				filename.value = fileName;
				var detectorId = document.getElementById("detectorId");
				detectorId.value = detector;				
				var def = document.getElementById("defaultBenchmark");
				if (checkedObject.checked) {
					def.value = "true";
				} else {
					def.value = "false";
				}
				document.getElementById('submitButton').click();
			}	
			function deleteBenchmark(filename, defaultFlag) {
				if (defaultFlag) {
					var messages = document.getElementById("messages");
					messages.innerHTML = "<i>* Cannot remove a default benchmark file</i>"
					return false;
				} else {
					var removeBenchmark = document.getElementById("removeBenchmark");
					removeBenchmark.value = filename;
					document.getElementById('submitButton').click();	
				}
			}
			function addBenchmarkFiles(detector, dateObject) {
				var date = document.getElementById(dateObject);
				var params = 'width=1000,height=750,top=10,left=150';
				var newwindow = window.open("add-benchmark.jsp?detector="+detector+"&sinceDate="+date.value, "addBenchmark", params);
				if (window.focus) {newwindow.focus()}
			}
			
			function popUpClosed() {
					window.location.reload();
			}			
		</script>
	</head>
	
	<body id="benchmark">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<h1>Select benchmark files.</h1>
<ul>
	<li>Select date to retrieve benchmark candidates for a detector and add files.</li>
	<li>Select a default benchmark file.</li>
	<li>Remove benchmark files (this will also remove the references to this file in former blessed datafiles).</li>
</ul>
<form id="benchmarkFileForm" method="post">
<table style="border: 1px solid black; width: 100%; padding: 20px;" >
    <tr style="vertical-align: top; text-align: center;">
    	<td class="benchmarkHeader">Detector</td>
    	<td class="benchmarkHeader">Add Files From Date</td>
    	<td class="benchmarkHeader">Benchmark files and labels</td>
    </tr>
	<c:forEach var="detector" items="${detectors}">
	     <tr class="benchmarkRow">
	     	<td><strong>${detector}</strong></td>
		 	<td><input readonly type="text" name="sinceDate${detector}" id="sinceDate${detector}" size="15" value="<%=DATEFORMAT.format(lastMonth.getTime()) %>" class="datepicker" ></input>
				<input type="button" name="addBenchmarkFiles${detector}" id="addBenchmarkFiles${detector}" value="+" onclick='javascript:addBenchmarkFiles(${detector}, "sinceDate${detector}");'/>
			</td>
			<td>
				<table class="innerTable">
				<c:forEach var="detectorBenchmark" items="${detectorBenchmark}">
					<c:choose>
						<c:when test="${detectorBenchmark.value == detector}">
								<c:forEach var="benchmarkTuples" items="${benchmarkTuples}">
									<tr>
										<c:choose>
											<c:when test="${benchmarkTuples.key == detectorBenchmark.key}">
												<td style="vertical-align: bottom; width: 115px;">${benchmarkTuples.key}</td>
												<td style="vertical-align: bottom; width: 20px;">
													<c:choose>
														<c:when test="${benchmarkTuples.value.tupleMap.benchmarkdefault}">
															<input type="checkbox" name="default${benchmarkTuples.key}" id="default${benchmarkTuples.key}" 
																		value="${benchmarkTuples.key}" checked onclick='javascript:setDefault(this, "${detector}", "${benchmarkTuples.key}")'></input>
														</c:when>
														<c:otherwise>
															<input type="checkbox" name="default${benchmarkTuples.key}" id="default${benchmarkTuples.key}" 
																		value="${benchmarkTuples.key}" onclick='javascript:setDefault(this, "${detector}", "${benchmarkTuples.key}")'></input>
														</c:otherwise>																	
													</c:choose>
											    </td>													
												<td style="vertical-align: center; width: 40px;"><input type=button name="removeBenchmarkFile${benchmarkTuples.key}" id="removeBenchmarkFile${benchmarkTuples.key}" value="-" onclick='javascript:deleteBenchmark("${benchmarkTuples.key}", ${benchmarkTuples.value.tupleMap.benchmarkdefault});'></input></td>
												<td style="vertical-align: bottom;"><strong>${benchmarkTuples.value.tupleMap.benchmarklabel}</strong></td>
											</c:when>
										</c:choose>																							
									</tr>
								</c:forEach>															
						</c:when>
					</c:choose>						
				</c:forEach>							
				</table>
			</td>
	  </tr>
	</c:forEach>
	<tr>
		<td colspan="3" class="benchmarkFooter"><div id="messages"></div></td>
	</tr>
</table>
<input type="hidden" name="filename" id="filename" value=""></input>
<input type="hidden" name="optInOut" id="optInOut" value=""></input>
<input type="hidden" name="detectorId" id="detectorId" value =""></input>
<input type="hidden" name="defaultBenchmark" id="defaultBenchmark" value=""></input>
<input type="hidden" name="removeBenchmark" id="removeBenchmark" value=""></input>
<input type="submit" name="submitButton" id="submitButton" value="Save Changes" style="visibility: hidden;" />
</form>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
