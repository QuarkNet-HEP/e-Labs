<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
	
	//save changes
	String reqType = request.getParameter("submitButton");
	if ("Save Changes".equals(reqType)){
		//check if we are setting/unsetting default golden file
		String filename = request.getParameter("filename");
		String detectorId = request.getParameter("detectorId");
		Integer detector = Integer.parseInt(detectorId);
		DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
		if (!filename.equals("")) {
			//first make all prior golden files not default
			ResultSet rsDefault = Benchmark.getBenchmarkFileName(elab, detector);
            String[] defaultGolden = rsDefault.getLfnArray();
		    for (int i = 0; i < defaultGolden.length; i++) {
		    	CatalogEntry ce = dcp.getEntry(defaultGolden[i]);
		    	ce.setTupleValue("goldendefault", false);
		    	dcp.insert(ce);
		    }			
			String def = request.getParameter("defaultGolden");
			boolean defaultIt = (def.equals("true") ? true: false);
			CatalogEntry entry = dcp.getEntry(filename);
			entry.setTupleValue("goldendefault", defaultIt);
			dcp.insert(entry);			
		}//end of setting/removing default golden file
		
		//check if detector is being opted in or out
		String optInOut = request.getParameter("optInOut");
		boolean inOut = optInOut.equals("true") ? true : false;
		if (!detectorId.equals("") && !optInOut.equals("")) {
			cp.setDetectorBenchmarkFileUse(user, detectorId, inOut);
		}//end of opting in/out
		
		String removeGolden = request.getParameter("removeGolden");
		//check if we are removing a golden file
		if (!removeGolden.equals("")) {
			//look for all the datafiles that have this file set as their golden
			ResultSet rsBlessed = Benchmark.getBlessedDataFilesByBenchmark(elab, removeGolden);
	  		String[] blessedFiles = rsBlessed.getLfnArray();
		    for (int i = 0; i < blessedFiles.length; i++) {
		    	CatalogEntry ce = dcp.getEntry(blessedFiles[i]);
		    	ce.setTupleValue("goldenreference","");
		    	dcp.insert(ce);
		    }
		    //now let's deal with the golden file
			CatalogEntry entry = dcp.getEntry(removeGolden);					
			entry.setTupleValue("goldenfile", false);
			entry.setTupleValue("goldendefault", false);
			dcp.insert(entry);			
			
		}//end of removing golden file		
	}
	
	//get detectors
	TreeMap<Integer, Boolean> goldenFileUse = (TreeMap<Integer, Boolean>) cp.getDetectorBenchmarkFileUse(user);
    
	//retrieve existing golden files
	ResultSet searchResults = null;
	TreeMap<Integer, String> detectorDF = new TreeMap<Integer, String>();
	TreeMap<String, VDSCatalogEntry> fileGF = new TreeMap<String, VDSCatalogEntry>();
	for(Map.Entry<Integer,Boolean> entry : goldenFileUse.entrySet()) {
		  Integer key = entry.getKey();
		  Boolean value = entry.getValue();
		  if (value) {
	  		//retrieve golden files from database
	  		searchResults = Benchmark.getBenchmarkFileName(elab, key);
	  		String[] filenames = searchResults.getLfnArray();
			for (int i = 0; i < filenames.length; i++){
				VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
				if (entry != null) {
					detectorDF.put(key, filenames[i]);
					fileGF.put(filenames[i], e);
				}				
			}
		  }
		}
	request.setAttribute("goldenFileUse", goldenFileUse);
	request.setAttribute("detectorDF", detectorDF);
	request.setAttribute("fileGF", fileGF);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark File</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
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
			function showAddButton(checkedObject, formName, buttonObject, detector) {
				var detectorId = document.getElementById("detectorId");
				detectorId.value = detector;
				var optInOut = document.getElementById("optInOut");
				var button = document.getElementById(buttonObject);
				var dateInput = document.getElementById("sinceDate"+detector);
				if (checkedObject.checked) {
					optInOut.value = "true";
					button.style.visibility = "visible";
					dateInput.style.visibility = "visible";
					dateInput.className = "datepicker";
				} else {
					optInOut.value = "false";
					button.style.visibility = "hidden";
					dateInput.style.visibility = "hidden";
					dateInput.className = "";
				}
				document.getElementById('submitButton').click();
			}
			function setDefault(checkedObject, detector, fileName) {
				var filename = document.getElementById("filename");
				filename.value = fileName;
				var detectorId = document.getElementById("detectorId");
				detectorId.value = detector;				
				var def = document.getElementById("defaultGolden");
				if (checkedObject.checked) {
					def.value = "true";
				} else {
					def.value = "false";
				}
				document.getElementById('submitButton').click();
			}
			function removeGF(filename, defaultFlag) {
				if (defaultFlag) {
					alert("Cannot remove a default golden file.");
					return false;
				} else {
					var removeGolden = document.getElementById("removeGolden");
					removeGolden.value = filename;
					document.getElementById('submitButton').click();	
				}
			}
			function addBenchmarkFiles(detector, dateObject) {
				var date = document.getElementById(dateObject);
				//location.href="add-benchmark.jsp?detector="+detector+"&sinceDate="+date.value;
				var params = 'width=1000,height=700,top=50,left=150';
				var newwindow = window.open("add-benchmark.jsp?detector="+detector+"&sinceDate="+date.value, "addBenchmark", params);
				if (window.focus) {newwindow.focus()}
			}
			function popUpClosed() {
				window.location.reload();
			}
		</script>
	</head>
	
	<body id="golden-file">
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

<form id="goldenFileForm" method="post">
<table border="0">
    <tr style="vertical-align: top; text-align: center;">
    	<td><strong>Detector</strong></td>
    	<td><strong>Opt IN</strong></td>
    	<td><strong>Add Files From Date</strong></td>
    	<td><strong>Benchmark Files</strong></td>
    </tr>
	<c:forEach var="detector" items="${goldenFileUse}">
  	  <c:choose>
	  	  <c:when test="${detector.value}">
		     <tr style="vertical-align: top; text-align: center;">
		        <td><strong>${detector.key}</strong></td>
				<td><input type="checkbox" name="use_golden_file" value="${detector.key}" checked onclick='javascript:showAddButton(this, "addGolden${detector.key}", "addGoldenFiles${detector.key}", "${detector.key}");'></input></td>	 	
			 	<td><input readonly type="text" name="sinceDate${detector.key}" id="sinceDate${detector.key}" size="15" value="<%= DATEFORMAT.format(new Date()) %>" class="datepicker" ></input>
					<input type="button" name="addGoldenFiles${detector.key}" id="addGoldenFiles${detector.key}" value="+" onclick='javascript:addBenchmarkFiles(${detector.key}, "sinceDate${detector.key}");'/>
				</td>
				<td>
				<c:forEach var="datafile" items="${detectorDF}">
					<c:choose>
						<c:when test="${datafile.key == detector.key}">
							<c:forEach var="goldenfile" items="${fileGF}">
									<table>
										<tr>
											<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
											<td style="vertical-align: bottom;">${goldenfile.key}</td>
											<td style="vertical-align: bottom;">
												<c:choose>
													<c:when test="${goldenfile.value.tupleMap.goldendefault}">
														<input type="checkbox" name="default${goldenfile.key}" id="default${goldenfile.key}" 
																	value="${goldenfile.key}" checked onclick='javascript:setDefault(this, "${detector.key}", "${goldenfile.key}")'></input>
													</c:when>
													<c:otherwise>
														<input type="checkbox" name="default${goldenfile.key}" id="default${goldenfile.key}" 
																	value="${goldenfile.key}" onclick='javascript:setDefault(this, "${detector.key}", "${goldenfile.key}")'></input>
													</c:otherwise>																	
												</c:choose>
											</td>
											<td style="vertical-align: center;"><input type=button name="removeGoldenFile${goldenfile.key}" id="removeGoldenFile${goldenfile.key}" value="-" onclick='javascript:removeGF("${goldenfile.key}", ${goldenfile.value.tupleMap.goldendefault});'></input></td>
										</tr>
									</table>
							</c:forEach>															
						</c:when>
					</c:choose>						
				</c:forEach></td>
			  </tr>
			</c:when>
			<c:otherwise>
	            <tr style="vertical-align: top; text-align: center;">
		            <td><strong>${detector.key}</strong></td>
		     		<td><input type="checkbox" name="use_golden_file" value="${detector.key}" onclick='javascript:showAddButton(this, "addGolden${detector.key}", "addGoldenFiles${detector.key}", "${detector.key}");'></input></td>
					<td><input readonly type="text" name="sinceDate${detector.key}" id="sinceDate${detector.key}" size="15" value="<%= DATEFORMAT.format(new Date()) %>" class="" style="visibility: hidden;"></input>
						<input type="button" name="addGoldenFiles${detector.key}" id="addGoldenFiles${detector.key}" value="+" style="visibility: hidden;" onclick='javascript:addBenchmarkFiles(${detector.key}, "sinceDate${detector.key}");'/>
					</td>
					<td></td>
				</tr>
			</c:otherwise>
		</c:choose>
	</c:forEach>
</table>
<input type="hidden" name="filename" id="filename" value=""></input>
<input type="hidden" name="optInOut" id="optInOut" value=""></input>
<input type="hidden" name="detectorId" id="detectorId" value =""></input>
<input type="hidden" name="defaultGolden" id="defaultGolden" value=""></input>
<input type="hidden" name="removeGolden" id="removeGolden" value=""></input>
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
