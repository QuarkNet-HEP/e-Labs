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
		toDate = DATEFORMAT.format(Calendar.getInstance().getTime());
	}
	Date startDate = null;
	Date endDate = null;
	String messages = "";
	int totalFiles = 0, totalBlessed = 0, totalUnblessed = 0;
	TreeMap<String, VDSCatalogEntry> filenameDisplay = new TreeMap<String, VDSCatalogEntry>();
	
	if ("Retrieve Splits".equals(submit)) {
		if (StringUtils.isNotBlank(fromDate)) {
			startDate = DATEFORMAT.parse(fromDate); 
		}
		if (StringUtils.isNotBlank(toDate)) {
			endDate = DATEFORMAT.parse(toDate); 
		}
		ResultSet rs = Benchmark.getSplitBenchmarkInfoByInterval(elab, startDate, endDate);
		if (rs != null) {	
			String[] splits = rs.getLfnArray();
			totalFiles = splits.length;
			for (int i = 0; i < splits.length; i++) {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splits[i]);
				Boolean b = (Boolean) entry.getTupleValue("blessed");
				if (b) {
					totalBlessed++;
				} else {
					totalUnblessed++;
				}
				try {
					String display = Benchmark.getSplitBlessLink(entry);
					filenameDisplay.put(display, entry);
				}
				catch (Exception e) {
					messages = "There was an error with the request: " + e.getMessage();
					continue;
				}
			}
		}
	}//end of submit
	
	request.setAttribute("messages", messages);
	request.setAttribute("fromDate", fromDate);
	request.setAttribute("toDate", toDate);
	request.setAttribute("totalFiles", totalFiles);
	request.setAttribute("totalBlessed", totalBlessed);
	request.setAttribute("totalUnblessed", totalUnblessed);
	request.setAttribute("filenameDisplay", filenameDisplay);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Splits and their blessed/unblessed status details.</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>		
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
						minDate: new Date(2000, 11-1, 30), // Earliest known date of data - probably should progamatically find. 
						maxDate: new Date() // Should not look later than today
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
			}); 
		</script>
	</head>
	
	<body id="benchmark-info" class="teacher">
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
			<form id="benchmarkInfo" method="post">
			    <h2>View splits and their details.</h2>
			    <ul>
			    	<li>Choose a date range.</li>
			    	<li>Click on Retrieve Splits to get the list of uploaded files and their details.</li>
			    </ul>
				<table>
					<tr>
				 		<td nowrap style="vertical-align: center;">Date Range
	 	    				<input type="text" name="fromDateSplit" id="fromDateSplit" size="12" value="<%=fromDate %>" class="datepicker1" ></input>
	 	    				to <input type="text" name="toDateSplit" id="toDateSplit" size="12" value="<%=toDate %>" class="datepicker1" ></input>	
						</td>
					</tr>
					<tr>			
						<td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Retrieve Splits"/></div>
						</td>
					</tr>
					<tr>
						<td><div style="width: 100%; text-align:center;"><i>* This may take a while depending on the date range you choose.</i></div>
						</td>
					</tr>
				</table>
			</form>
			<c:choose>
   				  <c:when test="${not empty filenameDisplay }"> 
   				       <hr></hr>
   				  	   <h2>Query Results</h2>
   				  	   <p><strong>Total Files:</strong> ${totalFiles }, 
   				  	   	  <strong>Total Blessed: </strong>${totalBlessed }, 
   				  	   	  <strong>Total Unblessed: </strong> ${totalUnblessed}</p>
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
								<td>${filename.key}</td>
								<td>${filename.value.tupleMap.blessed}</td>
								<td style="text-align: left;"><strong>Uploaded Date: </strong>${filename.value.tupleMap.creationdate}<br />
									<strong>Location: </strong>${filename.value.tupleMap.school}, ${filename.value.tupleMap.city} - ${filename.value.tupleMap.state}<br />
									<strong>Group: </strong>${filename.value.tupleMap.group}<br />
									<choose>
										<c:when test="${not empty filename.value.tupleMap.benchmarkreference}">
											<strong>Benchmark Reference: </strong>	${filename.value.tupleMap.benchmarkreference }<br />
										</c:when>
										<c:otherwise>
											<strong>Benchmark: </strong> This file does not have a benchmark reference.
										</c:otherwise>
									</choose>
									<choose>
										<c:when test="${not empty filename.value.tupleMap.benchmarklabel}">
											<strong>This file is a benchmark: </strong>	${filename.value.tupleMap.benchmarkreference }<br />
										</c:when>
									</choose>
									<choose>
										<c:when test="${not empty filename.value.tupleMap.benchmarkfail}">
											<strong>Fail Reason: </strong>	${filename.value.tupleMap.benchmarkreference }<br />
										</c:when>
									</choose>
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