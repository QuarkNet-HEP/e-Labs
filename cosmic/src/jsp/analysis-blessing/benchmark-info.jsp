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
<%@ page import="jxl.*" %>
<%@ page import="jxl.write.*" %>
<%@ page import="java.io.File" %>

<%
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	String submit = request.getParameter("submit");
	String fromDate = request.getParameter("fromDateSplit");
	String reportType = request.getParameter("reportType");
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
	int totalFiles = 0, totalBlessed = 0, totalUnblessed = 0, totalUnbenchmarked = 0;
	TreeMap<String, VDSCatalogEntry> filenameDisplay = new TreeMap<String, VDSCatalogEntry>();
	ArrayList<String> qualityParameter = new ArrayList<String>();
	TreeMap<Integer, Integer> qualityData = new TreeMap<Integer, Integer>();
	String xAxisCategories ="";
	String yAxisValues = "";
	String workbookName ="quality_parameter.xls";
	String outliers = "";
	
	if ("Retrieve Report".equals(submit)) {
		if (StringUtils.isNotBlank(fromDate)) {
			startDate = DATEFORMAT.parse(fromDate); 
		}
		if (StringUtils.isNotBlank(toDate)) {
			endDate = DATEFORMAT.parse(toDate); 
		}
		//this query will bring all splits in the date range and we can also get the summary from it
		ResultSet rsTotal = Benchmark.getSplitBenchmarkInfoByInterval(elab, startDate, endDate);
		String workbookPath = elab.getProperties().getDataDir() + File.separator+ workbookName;
		WritableWorkbook workbook = Workbook.createWorkbook(new File(workbookPath));
		WritableSheet sheet = workbook.createSheet("First Sheet", 0);

		if (rsTotal != null) {	
			String[] splits = rsTotal.getLfnArray();
			totalFiles = splits.length;
			for (int i = 0; i < splits.length; i++) {
				VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splits[i]);
				java.lang.Boolean b = (java.lang.Boolean) entry.getTupleValue("blessed");
				if (b) {
					totalBlessed++;
				} else {
					totalUnblessed++;
					String benchmarkreference = (String) entry.getTupleValue("benchmarkreference");
					if (benchmarkreference == null || benchmarkreference.equals("")) {
						totalUnbenchmarked++;
					}
				}
				if (reportType.equals("blessingStatus")) {
					try {
						String display = entry.getLFN();
						filenameDisplay.put(display, entry);
					}
					catch (Exception e) {
						messages = "There was an error with the request: " + e.getMessage();
						continue;
					}
				}
				sheet.addCell(new Label(0,i,(String) entry.getLFN()));
				sheet.addCell(new Label(1,i,String.valueOf(entry.getTupleValue("blessed"))));
				sheet.addCell(new Label(2,i,String.valueOf(entry.getTupleValue("creationdate"))));
				sheet.addCell(new Label(3,i,String.valueOf(entry.getTupleValue("startdate"))));
				sheet.addCell(new Label(4,i,(String) entry.getTupleValue("group")));
				sheet.addCell(new Label(5,i,(String) entry.getTupleValue("city")));
				sheet.addCell(new Label(6,i,(String) entry.getTupleValue("state")));
				sheet.addCell(new Label(7,i,(String) entry.getTupleValue("teacher")));
				sheet.addCell(new Label(8,i,(String) entry.getTupleValue("email")));
				sheet.addCell(new Label(9,i,(String) entry.getTupleValue("benchmarkfailuretime")));
				sheet.addCell(new Label(10,i,(String) entry.getTupleValue("benchmarkfailurechannel")));
				sheet.addCell(new Label(11,i,(String) entry.getTupleValue("benchmarkreference")));
				sheet.addCell(new Label(12,i,(String) entry.getTupleValue("benchmarkrate")));
				sheet.addCell(new Label(13,i,(String) entry.getTupleValue("benchmarksplitrate")));
				sheet.addCell(new Label(14,i,(String) entry.getTupleValue("benchmarkspliterror")));
				sheet.addCell(new Label(15,i,(String) entry.getTupleValue("benchmarkquality")));
				sheet.addCell(new Label(16,i,(String) entry.getTupleValue("benchmarkfail")));
			}		
		}
		workbook.write();
		workbook.close();

		if (reportType.equals("dataQuality")) {
			ResultSet rs = Benchmark.getUnblessedSplitDetails(elab, startDate, endDate);
			if (rs != null) {
				String[] splits = rs.getLfnArray();
				for (int i = 0; i < splits.length; i++) {
					VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(splits[i]);
					try {
						String display = entry.getLFN();
						filenameDisplay.put(display, entry);
						qualityParameter.add((String) entry.getTupleValue("benchmarkquality"));
					}
					catch (Exception e) {
						messages = "There was an error with the request: " + e.getMessage();
						continue;
					}
				}				
			}
			for (Iterator it = qualityParameter.iterator(); it.hasNext();) {
				String nextValue = (String) it.next();
				if (nextValue != null && !nextValue.equals("")) {
					Double quality = Double.valueOf(nextValue);
					Double fraction = quality % 1;
					Double interval = quality - fraction;
					if (interval < 1000) {
						if (!qualityData.containsKey(interval.intValue())) {
							qualityData.put(interval.intValue(), new Integer(1));
						} else {
							qualityData.put(interval.intValue(), qualityData.get(interval.intValue()) + 1);		
						}
					} else {
						outliers += " - " + String.valueOf(interval); 
					}
				}
			}
			Integer i = 0;
			if (!qualityData.isEmpty()) {
				while(i <= qualityData.lastKey()) {
					if (qualityData.containsKey(i)) {
						xAxisCategories += "'"+i+"',";
						yAxisValues += qualityData.get(i)+ ",";
					} else {
						xAxisCategories += "'"+i+"',";
						yAxisValues += "0,";
					}
					i++;
				}
			}
		}
	}//end of submit
	
	request.setAttribute("xAxisCategories", xAxisCategories);
	request.setAttribute("yAxisValues", yAxisValues);
	request.setAttribute("messages", messages);
	request.setAttribute("outliers", outliers);
	request.setAttribute("fromDate", fromDate);
	request.setAttribute("toDate", toDate);
	request.setAttribute("reportType", reportType);
	request.setAttribute("totalFiles", totalFiles);
	request.setAttribute("totalBlessed", totalBlessed);
	request.setAttribute("totalUnbenchmarked", totalUnbenchmarked);
	request.setAttribute("totalUnblessed", totalUnblessed);
	request.setAttribute("filenameDisplay", filenameDisplay);
	request.setAttribute("workbookName", workbookName);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Splits and their blessed/unblessed status details.</title>
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
		<script src="https://code.highcharts.com/highcharts.js"></script>
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
			$(function () { 
			    $('#qualityParameter').highcharts({
			        chart: {
			            type: 'column'
			        },
		            title: {
		                text: 'Quality Parameter Chart'
		            },			        
			        yAxis: {
			            title: {
			                text: 'Count'
			            }
			        },
			        xAxis: {
				        labels: {
				        	enabled: false
				        },
			        	categories: [<%=xAxisCategories%>]
			        },
			        colors: ['#0000ff'],
			        series: [{
			            name: 'Quality Parameter Values',
			            data: [<%=yAxisValues%>]
			        }]
			    });
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
			    	<li>Choose report type.</li>
			    	<li>Click on Retrieve Report to get the list of uploaded files and their details.</li>
			    </ul>
				<table>
					<tr>
				 		<td nowrap style="vertical-align: center;">Date Range
	 	    				<input type="text" name="fromDateSplit" id="fromDateSplit" size="12" value="<%=fromDate %>" class="datepicker1" ></input>
	 	    				to <input type="text" name="toDateSplit" id="toDateSplit" size="12" value="<%=toDate %>" class="datepicker1" ></input>	
						</td>
					</tr>
					<tr>
						<td>Report Type
							<select name="reportType">
								<c:choose>
									<c:when test='${reportType == "blessingStatus" }'>
										<option value="blessingStatus" selected="selected">Splits and their blessing status</option>
									</c:when>
									<c:otherwise>
										<option value="blessingStatus">Splits and their blessing status</option>							
									</c:otherwise>
								</c:choose>
								<c:choose>
									<c:when test='${reportType == "dataQuality" }'>
										<option value="dataQuality" selected="selected">Quality data of unblessed files</option>
									</c:when>
									<c:otherwise>
										<option value="dataQuality">Quality data of unblessed files</option>
									</c:otherwise>
								</c:choose>
									
							</select>
						</td>
					</tr>
					<tr>			
						<td><div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Retrieve Report"/></div>
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
   				  	   	  <strong>Total Unblessed: </strong> ${totalUnblessed}, 
   				  	   	  <strong>Total Unbenchmarked: </strong> ${totalUnbenchmarked }	  
   				  	   </p>	
 						  <c:choose>
						  	<c:when test='${reportType == "blessingStatus" }'>
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
						<c:otherwise>
							<c:choose>
								<c:when test='${reportType == "dataQuality" }'>
								   <div id="chart" style="background-color:#FFFFFF">
									  <div id="qualityParameter" style="width:750px; height:250px; text-align: left;"></div>
								   </div>
								   <c:if test="${not empty outliers }">
								   		<div><i>* Outliers not graphed: ${outliers }</i></div>
								   </c:if>
								   <a href="../data/download?filename=${workbookName}&elab=${elab.name}&type=file">Download Excel file with data</a>
							       <table style="text-align: center; width: 100%;" id="quality-data-results" class="tablesorter">
										<thead>
											<tr>
												<th>File Name</th>
												<th>Uploaded Date</th>
												<th>Start Time</th>
												<th>Group-Location</th>
												<th>Teacher-Email</th>
												<th>Failure Time</th>
												<th>Channel</th>
												<th>Benchmark</th>
												<th>Benchmark Rate</th>
												<th>Split Rate</th>
												<th>Split Error</th>
												<th>Quality Parameter</th>
											</tr>
										</thead>
										<tbody>
											<c:forEach items="${filenameDisplay}" var="filename">
												<c:if test="${not empty filename.value.tupleMap.benchmarkquality}">
													<tr>
														<td><a href="../analysis-blessing/compare1.jsp?file=${filename.key}" target="_blank" width="700" height="900" now="true">${filename.key}</a></td>
														<td nowrap><fmt:formatDate value="${filename.value.tupleMap.creationdate}" pattern="yyyy MM dd"></fmt:formatDate></td>
														<td nowrap><fmt:formatDate value="${filename.value.tupleMap.startdate}" pattern="yyyy MM dd"></fmt:formatDate></td>
														<td style="text-align: left;">${filename.value.tupleMap.group}<br />
																					  ${filename.value.tupleMap.school}<br />	
																					  ${filename.value.tupleMap.city}, ${filename.value.tupleMap.state }
														</td>
														<td style="text-align: left;">${filename.value.tupleMap.teacher}<br />
																					  ${filename.value.tupleMap.email}
														</td>
														<td>${filename.value.tupleMap.benchmarkfailuretime }</td>
														<td>${filename.value.tupleMap.benchmarkfailurechannel }</td>
														<td><a href="../analysis-blessing/compare1.jsp?file=${filename.value.tupleMap.benchmarkreference }" target="_blank" width="700" height="900" now="true">${filename.value.tupleMap.benchmarkreference }</a></td>
														<td><fmt:formatNumber value="${filename.value.tupleMap.benchmarkrate }" maxFractionDigits="3"></fmt:formatNumber></td>
														<td><fmt:formatNumber value="${filename.value.tupleMap.benchmarksplitrate }" maxFractionDigits="3"></fmt:formatNumber></td>
														<td><fmt:formatNumber value="${filename.value.tupleMap.benchmarkspliterror }" maxFractionDigits="3"></fmt:formatNumber></td>
														<td><fmt:formatNumber value="${filename.value.tupleMap.benchmarkquality }" maxFractionDigits="3"></fmt:formatNumber></td>
													</tr>
												</c:if>
											</c:forEach>
										</tbody>
									</table>								
								</c:when>
							</c:choose>
						</c:otherwise>
					</c:choose>
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
