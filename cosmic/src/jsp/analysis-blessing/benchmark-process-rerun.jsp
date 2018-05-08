<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>

<%
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	String submit = request.getParameter("submit");
	String fromDate = request.getParameter("fromDateSplit");
	if (fromDate == null) {
		fromDate = DATEFORMAT.format(Calendar.getInstance().getTime());
	}
	String toDate = request.getParameter("toDateSplit");
	if (toDate == null) {
		Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, 1);		
		toDate = DATEFORMAT.format(cal.getTime());
	}
	Date startDate = null;
	Date endDate = null;
	String messages = "";
	TreeMap<String, VDSCatalogEntry> filenameTotal = new TreeMap<String, VDSCatalogEntry>();
	TreeMap<String, VDSCatalogEntry> filenameDisplay = new TreeMap<String, VDSCatalogEntry>();
	
	int totalUnblessed = 0;
	int newTotalUnblessed = 0;
	if ("Rerun Blessing".equals(submit)) {
		if (StringUtils.isNotBlank(fromDate)) {
			startDate = DATEFORMAT.parse(fromDate); 
		}
		if (StringUtils.isNotBlank(toDate)) {
			endDate = DATEFORMAT.parse(toDate); 
		}
		//this query will bring all unblessed splits with a benchmark in the date range and we can also get the summary from it
		ResultSet rsTotal = Benchmark.getUnblessedWithBenchmark(elab, startDate, endDate);
		BlessProcess bp = new BlessProcess();

		if (rsTotal != null) {	
			String[] splits = rsTotal.getLfnArray();
			totalUnblessed = splits.length;
			for (int i = 0; i < splits.length; i++) {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splits[i]);
				String detectorid = (String) entry.getTupleValue("detectorid");
				String benchmark = (String) entry.getTupleValue("benchmarkreference");
				try {
					filenameTotal.put(splits[i], entry);
					bp.BlessDatafile(elab, detectorid, splits[i], benchmark);
				} catch (Exception e) {
					messages += e.getMessage();
				}
			}		
		}
		ResultSet rsNewTotal = Benchmark.getUnblessedWithBenchmark(elab, startDate, endDate);
		if (rsNewTotal != null) {
			String[] newSplits = rsNewTotal.getLfnArray();
			newTotalUnblessed = newSplits.length;
			for (int i = 0; i < newSplits.length; i++) {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(newSplits[i]);
				try {
					String display = entry.getLFN();
					filenameDisplay.put(display, entry);
				} catch (Exception e) {
					messages += e.getMessage();
				}
			}
		}
		for (Map.Entry<String, VDSCatalogEntry> e: filenameTotal.entrySet()) {
			if (!filenameDisplay.containsKey(e.getKey())) {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(e.getKey());
				filenameDisplay.put(e.getKey(), entry);
			}
		}
	}//end of submit
	
	request.setAttribute("messages", messages);
	request.setAttribute("fromDate", fromDate);
	request.setAttribute("toDate", toDate);
	request.setAttribute("totalUnblessed", totalUnblessed);
	request.setAttribute("newTotalUnblessed", newTotalUnblessed);
	request.setAttribute("filenameDisplay", filenameDisplay);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Rerun blessing process for unblessed files by using the same benchmark.</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
		<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
		<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script>	
		<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>	
		<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />		
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
						minDate: new Date(2000, 11-1, 30)//, // Earliest known date of data - probably should progamatically find. 
						//maxDate: new Date() // Should not look later than today
				}
			$('.datepicker1').datepicker(calendarParam);
			$("#fromDateSplit").datepicker('option', 'buttonText', 'Choose start date for data files.');
			$("#toDateSplit").datepicker('option', 'buttonText', 'Choose start date for data files.');
			$('img.ui-datepicker-trigger').css('vertical-align', 'text-bottom'); 			
			});	
			$(document).ready(function() { 
				if ($("#splits-results").find("tbody").find("tr").size() > 0) {
				    // call the tablesorter plugin 
				    $("#splits-results").tablesorter({ 
				        // sort on the second column and first column, order asc 
				        sortList: [[1,0],[0,0]] 
				    }); 
				}
				if ($("#quality-data-results").find("tbody").find("tr").size() > 0) {
				    // call the tablesorter plugin 
				    $("#quality-data-results").tablesorter({ 
				        // sort on the second column and first column, order asc 
				        sortList: [[0,0],[0,0]] 
				    }); 
				}
			}); 
		</script>
	</head>
	
	<body id="benchmark-process-rerun" class="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">
			<form id="benchmarkProcessRerun" method="post">
			    <h2>Rerun blessing precess for unblessed files using the same selected</h2>
			    <ul>
			    	<li>Choose a date range.</li>
			    	<li>Click on Rerun Blessing.</li>
			    </ul>
				<table>
					<tr>
				 		<td nowrap style="vertical-align: center;">Date Range
	 	    				<input type="text" name="fromDateSplit" id="fromDateSplit" size="12" value="<%=fromDate %>" class="datepicker1" ></input>
	 	    				to <input type="text" name="toDateSplit" id="toDateSplit" size="12" value="<%=toDate %>" class="datepicker1" ></input>	
						</td>
					</tr>
					<tr>			
						<td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Rerun Blessing"/></div>
						</td>
					</tr>
					<tr>
						<td><div style="width: 100%; text-align:center;"><i>* This may take a while depending on the date range you choose.</i></div>
						</td>
					</tr>
				</table>
			</form>
			<h2>Results</h2>
			<c:choose>
				<c:when test="${not empty totalUnblessed }">
					<div>Unblessed files found for the chosen date range: ${totalUnblessed }</div>
					<div>Files unblessed after trying to rebless them: ${newTotalUnblessed }</div>
				</c:when>
			</c:choose>
			<c:choose>
				<c:when test="${not empty filenameDisplay }">
				       <table style="text-align: center; width: 100%;" id="splits-results" class="tablesorter">
							<thead>
								<tr>
									<th>File Name</th>
									<th>Blessed Status</th>
									<th>Details</th>
								</tr>
							</thead>
							<tbody>
						<c:forEach items="${filenameDisplay}" var="filename">
							<tr>
								<td><a href="../analysis-blessing/compare1.jsp?file=${filename.key}" target="_blank" width="700" height="900" now="true">${filename.key}</a></td>
								<td>${filename.value.tupleMap.blessed}</td>
								<td style="text-align: left;"><strong>Uploaded Date: </strong>${filename.value.tupleMap.creationdate}<br />
									<strong>Location: </strong>${filename.value.tupleMap.school}, ${filename.value.tupleMap.city} - ${filename.value.tupleMap.state}<br />
									<strong>Group: </strong>${filename.value.tupleMap.group}<br />
									<c:choose>
										<c:when test="${filename.value.tupleMap.benchmarkreference > ''}">
											<strong>Benchmark Reference: </strong><a href="../analysis-blessing/compare1.jsp?file=${filename.value.tupleMap.benchmarkreference }" target="_blank" width="700" height="900" now="true">${filename.value.tupleMap.benchmarkreference }</a>	<br />
										</c:when>
										<c:otherwise>
											<strong>This file was uploaded without a benchmark reference.</strong><br />
										</c:otherwise>
									</c:choose>
									<c:choose>
										<c:when test="${filename.value.tupleMap.benchmarklabel > ''}">
											<strong>This file is a benchmark: </strong>	${filename.value.tupleMap.benchmarklabel }<br />
										</c:when>
									</c:choose>
									<c:choose>
										<c:when test="${filename.value.tupleMap.benchmarkfail > ''}">
											<strong>Fail Reason: </strong>	${filename.value.tupleMap.benchmarkfail }<br />
										</c:when>
									</c:choose>
									<strong>Source: </strong>	${filename.value.tupleMap.source }<br />
								</td>
							</tr>
						</c:forEach>					
					</table>				
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
