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
	// EPeronja-05/21/2013: 472-Benchmark file maintenance
	//						Add, remove and set default benchmark files per detector.
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
		//get all the files that have been blessed by this benchmark
		String[] blessed = request.getParameterValues(removeBenchmark);
		String confirmDelete = request.getParameter("confirmDelete");
		if (!removeBenchmark.equals("")) {
			request.setAttribute("removeBenchmark", removeBenchmark);
			request.setAttribute("blessed", blessed);
		}
		if (!removeBenchmark.equals("") && confirmDelete.equals("YES")) {
			//look for all the datafiles that have this file set as their benchmark reference
			ResultSet rsBlessed = Benchmark.getBlessedDataFilesByBenchmark(elab, removeBenchmark);
	  		String[] blessedFiles = rsBlessed.getLfnArray();
			DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
			//remove the reference
		    for (int i = 0; i < blessedFiles.length; i++) {
		    	CatalogEntry ce = dcp.getEntry(blessedFiles[i]);
		    	ce.setTupleValue("benchmarkreference","");
		    	ce.setTupleValue("blessed", false);
		    	dcp.insert(ce);
		    }
		    //now let's deal with the benchmark file
			CatalogEntry entry = dcp.getEntry(removeBenchmark);					
			entry.setTupleValue("benchmarkfile", false);
			entry.setTupleValue("benchmarkdefault", false);
			dcp.insert(entry);			
			request.setAttribute("blessed", null);
		}//end of removing benchmark file		
	}
	
	//get detectors and benchmark files
	Collection detectors = cp.getDetectorIds(user);
	Iterator iterator = detectors.iterator();
	TreeMap<String, Integer> detectorBenchmark = new TreeMap<String, Integer>();
	TreeMap<String, VDSCatalogEntry> benchmarkTuples = new TreeMap<String, VDSCatalogEntry>();
	ResultSet searchResults = null;
	//retrieve all the files blessed by these benchmarks
	TreeMap<String, String> blessedByBenchmark = new TreeMap<String,String>();
	
	String selectedDetector = request.getParameter("detector");
	String firstDataFile ="";
	if (selectedDetector != null) {
		//loop through detectors
		while (iterator.hasNext()) {
			String d = (String) iterator.next();
			if (d.equals(selectedDetector)) {
				Integer key = Integer.parseInt(d);
			  	//retrieve benchmark files from database
		  		searchResults = Benchmark.getBenchmarkFileName(elab, key);
			  	if (searchResults != null) {
			 		String[] filenames = searchResults.getLfnArray();
			 		for (int i = 0; i < filenames.length; i++){
						VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
						if (e != null) {
							benchmarkTuples.put(filenames[i], e);
							detectorBenchmark.put(filenames[i], key);				
						}
						//retrieve all blessed files by these benchmarks
						ResultSet rs = Benchmark.getBlessedDataFilesByBenchmark(elab, filenames[i]);
						if (rs != null) {
							String[] blessed = rs.getLfnArray();
							for (int x = 0; x < blessed.length; x++) {
								blessedByBenchmark.put(blessed[x], filenames[i]);
							}
						}
					}//end for loop
					if (detectorBenchmark.size() > 0) {
						Entry<String,Integer> firstEntry = detectorBenchmark.firstEntry();
						firstDataFile = firstEntry.getKey();
					}
					request.setAttribute("firstDataFile", firstDataFile);
			  	}//end check searchResults
			}//end of checking if key is the same as selected detectors
		}//end looping through detectors
	}//check for selectedDetector

	//set the calendar to a month prior by default 
	//the criteria to retrieve datafiles will probably change but we need some type of range otherwise
	//we will be retrieving all the files.
	Calendar lastMonth = Calendar.getInstance();
	lastMonth.add(Calendar.MONTH,-1);				
	request.setAttribute("lastMonth", lastMonth);
	request.setAttribute("detectors", detectors);
	request.setAttribute("detector", selectedDetector);
	request.setAttribute("detectorBenchmark", detectorBenchmark);
	request.setAttribute("benchmarkTuples", benchmarkTuples);
	request.setAttribute("blessedByBenchmark", blessedByBenchmark);
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
			$("#fromDate").datepicker('option', 'buttonText', 'Choose start date for data files.');
			$("#toDate").datepicker('option', 'buttonText', 'Choose start date for data files.');
			$('img.ui-datepicker-trigger').css('vertical-align', 'text-bottom'); 			
			});				
		</script>
		<script>
			function popUpClosed() {
				document.getElementById('submitButton').click();
					//window.location.reload();
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
<h1>Select benchmark files.</h1>
<ul>
	<li>Choose a <strong>detector</strong> from the drop-down.</li>
	<li>Select <strong>a date range</strong> to choose a benchmark file.</li>
	<li>Click <strong>Add Benchmark</strong> to retrieve benchmark candidates.</li>
	<li>Select/Unselect a <strong>default benchmark</strong> file.</li>
	<li>Remove benchmark files (this will also <strong>remove the references</strong> to this file in former blessed datafiles and <strong>unbless</strong> them).</li>
</ul>
<form id="benchmarkFileForm" method="post">
<c:if test="${not empty blessed }">
	<table style="border: 1px solid black; width: 100%; padding: 10px;" >
		<tr>
			<c:forEach items="${blessed}" var="blessed" varStatus="counter">
				<c:if test="${counter.count <= 25}">
					<td>${blessed}</td>
				</c:if>
				<c:if test="${counter.count == 25}" >
				    <td><a href="javascript:showAllRows();" id="moreRowsLink">more...</a></td>				    
				</c:if>
				<c:if test="${counter.count > 25}" >
					<td style="visibility: hidden;" class="moreRows">${blessed}</td>				    
				</c:if>
				<c:if test="${counter.count % 5 == 0}">
					</tr><tr>
				</c:if>
			</c:forEach>
		</tr>
		<tr><td colspan="5" style="text-align: center;">All these files will be unblessed. Do you want to continue?</td></tr>
		<tr><td colspan="5" style="text-align: center;">
			<input type="button" name="cancel" value="Cancel" onclick="javascript:cancelDelete();"></input>
			<input type="button" name="unbless" value="Delete & Unbless" onclick="javascript:deleteUnbless();"></input>
		</td></tr>
	</table>
</c:if>
<table style="border: 1px solid black; width: 100%; padding: 10px;" >
    <tr class="benchmarkRow">
     	<td style="vertical-align: center;" class="benchmarkHeader">Detector<br />
    		<select name="detectorId" id="detectorId" onChange="javascript:showAllFiles(this);">
		    	<option value="none">Choose detector</option>
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
     	</td>
	 	<td class="benchmarkHeader" nowrap style="vertical-align: center;">Date Range<br /> 
	 	    <input readonly type="text" name="fromDate" id="fromDate" size="12" value="<%=DATEFORMAT.format(lastMonth.getTime()) %>" class="datepicker" ></input>
	 	    to <input readonly type="text" name="toDate" id="toDate" size="12" value="<%=DATEFORMAT.format(Calendar.getInstance().getTime()) %>" class="datepicker" ></input>	
		</td>
		<td class="benchmarkHeader" style="vertical-align: bottom;">
			<input type="button" name="add" id="add" value="Add Benchmark" onclick='javascript:addBenchmarkFiles("${detector}", "fromDate", "toDate");'/>
		</td>
	</tr>
	<tr>
		<td colspan="3"><div id="messages" class="messages"></div></td>
	</tr>
    <tr>
    	<td class="detectorList">
    		<c:choose>
    			<c:when test="${not empty detectorBenchmark}">
		    	  <div class="detectorTable" id="tableWrapper"><strong>Current benchmark files for ${detector}</strong><br />
					<c:forEach var="detectorBenchmark" items="${detectorBenchmark}">
						<c:choose>
							<c:when test="${detectorBenchmark.value == detector}">
								<c:forEach var="benchmarkTuples" items="${benchmarkTuples}" varStatus="counter">
									<c:choose>
										<c:when test="${benchmarkTuples.key == detectorBenchmark.key}">
			  							  <div id="${detectorBenchmark.key}" onclick='javascript:showCharts("${benchmarkTuples.key}", "benchmark-get-data.jsp?file=");'>
											<table width="198px"  id="table${benchmarkTuples.key}" class="highlight">
												<tr>
													<td width="180px"><a href="#charts" onclick='javascript:showCharts("${benchmarkTuples.key}", "get-data.jsp?file=");'>${benchmarkTuples.value.tupleMap.benchmarklabel}</a></td>
													<td width="8px">
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
													<td width="10px"><input type=button name="removeBenchmarkFile${benchmarkTuples.key}" id="removeBenchmarkFile${benchmarkTuples.key}" value="-" onclick='javascript:deleteBenchmark("${benchmarkTuples.key}", ${benchmarkTuples.value.tupleMap.benchmarkdefault});'></input></td>													
												</tr>
											</table>
										  </div>																							
										</c:when>
									</c:choose>	
 								</c:forEach>															
							</c:when>
						</c:choose>						
					</c:forEach>	
				  </div>						
    			</c:when>
    		</c:choose>
    	</td>
		<td style="vertical-align: top;" colspan="2">
			<%@ include file="benchmark-charts.jspf" %>
		</td>
    </tr>
</table>
<input type="hidden" name="detector" id="detector" value="${detector}"></input>
<input type="hidden" name="selectedBenchmark" id="selectedBenchmark" value="${selectedBenchmark}"></input>
<input type="hidden" name="filename" id="filename" value=""></input>
<input type="hidden" name="detectorId" id="detectorId" value =""></input>
<input type="hidden" name="defaultBenchmark" id="defaultBenchmark" value=""></input>
<input type="hidden" name="removeBenchmark" id="removeBenchmark" value="${removeBenchmark}"></input>
<input type="hidden" name="confirmDelete" id="confirmDelete" value=""></input>
<input type="submit" name="submitButton" id="submitButton" value="Save Changes" style="visibility: hidden;" />
<c:choose>
	<c:when test="${not empty blessedByBenchmark}">
		<c:forEach var="blessedByBenchmark" items="${blessedByBenchmark}">
			<input type="hidden" id="${blessedByBenchmark.key}" name="${blessedByBenchmark.value}" class="${blessedByBenchmark.value}" value="${blessedByBenchmark.key}"></input>
		</c:forEach>
	</c:when>
</c:choose>
</form>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
