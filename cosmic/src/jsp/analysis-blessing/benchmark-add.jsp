<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>  
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<% 
// EPeronja-05/21/2013: Add a benchmark file from datafile candidates
//	TODO: create a css file for benchmark

	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	//get parameters from benchmark.jsp
	String detector = request.getParameter("detector");
	String sinceDate = request.getParameter("sinceDate");
	request.setAttribute("sinceDate", sinceDate);
	boolean success = false;
	Date startDate = null; 
	String firstDataFile = "";
	
	//saving a selected benchmark?
	String reqType = request.getParameter("submitBenchmark");
	if ("Save".equals(reqType)){
		String benchmark = request.getParameter("benchmark");
		String benchmarkLabel = request.getParameter("benchmarkLabel");
		if (benchmarkLabel.equals("")) {
			benchmarkLabel = detector + " " + DATEFORMAT.format(new Date()); 
		}
		DataCatalogProvider dcp = ElabFactory.getDataCatalogProvider(elab);
		if (benchmark != null) {
			if (!benchmark.equals("")) {
				//first make all prior benchmark files not default
				ResultSet rsDefault = Benchmark.getBenchmarkFileName(elab, Integer.parseInt(detector));
	            String[] defaultBenchmark = rsDefault.getLfnArray();
			    for (int i = 0; i < defaultBenchmark.length; i++) {
			    	CatalogEntry ce = dcp.getEntry(defaultBenchmark[i]);
			    	ce.setTupleValue("benchmarkdefault", false);
			    	dcp.insert(ce);
			    }
			    //set new benchmark and make it default
				CatalogEntry entry = dcp.getEntry(benchmark);
		    	entry.setTupleValue("blessed", true);
		    	dcp.insert(entry);
				ArrayList meta = new ArrayList();
				meta.add("benchmarkfile boolean true");
				meta.add("benchmarkreference string none");
				meta.add("benchmarkdefault boolean true");
				meta.add("benchmarklabel string "+benchmarkLabel);
				dcp.insert(DataTools.buildCatalogEntry(benchmark, meta));	
				success = true;
			}//end of setting/removing default benchmark file
		}
	} else {
	//or retrieving candidates?
		if (StringUtils.isNotBlank(sinceDate)) {
			if (StringUtils.isNotBlank(sinceDate)) {
				startDate = DATEFORMAT.parse(sinceDate); 
			}
			//retrieve datafiles from the start date selected
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, Integer.parseInt(detector), startDate);
			if (rs != null) {
				String[] results = rs.getLfnArray();	
				ArrayList<String> filenames = new ArrayList<String>();
				//check if these files have a .bless associated with them
				for (int i=0; i < results.length; i++ ) {
					VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(results[i]);
					if (entry.getTupleValue("blessfile") != null) {
						filenames.add(results[i]);
					}
				}
				//set the files we are displaying
				request.setAttribute("filenames", filenames);
				if (filenames.size() > 0) {
					firstDataFile = filenames.get(0);
				}
				request.setAttribute("firstDataFile", firstDataFile);
			}
		}
	}
	request.setAttribute("success", success);
	request.setAttribute("detector", detector);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Add Benchmark File</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>		
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
		<script type="text/javascript" src="../include/excanvas.min.js"></script>
		<script type="text/javascript" src="../analysis-blessing/blessing.js"></script>				
		<script>
		$(document).ready(function() {
			if ("<%=firstDataFile%>" != null && "<%=firstDataFile%>" != "") {
				showCharts("<%=firstDataFile%>");
			}
		});		
		</script>
		<script>
			window.onunload = function() {
			    if (window.opener && !window.opener.closed) {
			        window.opener.popUpClosed();
			    }
			};		
			function showCharts(filename){
				var chartDiv = document.getElementById("chartsDiv");
				chartDiv.style.visibility = 'visible';
				var datafile = document.getElementById("datafile");
				var arrows = document.getElementsByTagName("label");
				if (arrows) {
					for (var i = 0; i < arrows.length; i++) {
						arrows[i].style.visibility = "hidden";
					}
				}
				var arrow = document.getElementById("arrow"+filename);
				if (arrow) {
					arrow.style.visibility = "visible";
				}
				datafile.innerHTML = "<strong>"+filename+"</strong>";
				$.ajax({
					url: "../analysis-blessing/get-data.jsp?file="+filename,
					processData: false,
					dataType: "json",
					type: "GET",
					success: onDataLoad1
				});				
			}
			function checkLabel(){
				var benchmarkLabel = document.getElementById("benchmarkLabel");
				var radios = document.getElementsByName("benchmark");
				var message = document.getElementById("labelMsg");
				var keepGoing = false;
				for (i = 0; i < radios.length; i++) {
					if (radios[i].checked) {
						keepGoing = true;
					}
				}
				if (keepGoing) {
					if (benchmarkLabel.value == "" || benchmarkLabel.value == null) {
						message.style.visibility = "visible";
						message.innerHTML = "<i>* Please enter a label for this file.</i>";
						benchmarkLabel.focus();
						return false;
					} else {
						return true;
					}
				} else {
					message.style.visibility = "visible";
					message.innerHTML = "<i>* Please select a benchmark file.</i>";
					return false;
				}
			}
		</script>
	</head>
	<body>
		<div id="container">
			<div id="content">
			  <form name="addBenchmarkFileForm" method="post" >
				<h1>Select benchmark files for detector: <%=detector%></h1>
				<ul>
					<li>Select data file to <strong>view rates</strong> before you choose a benchmark file.</li>
					<li>Select <strong>benchmark</strong> file.</li>
					<li>Add a meaningful <strong>label</strong> to this benchmark file.</li>
				</ul>
				<input type="hidden" name="success" id="success" value="<%=success%>"></input>
				<input type="hidden" name="detector" value="<%=detector%>" ></input>
				<input type="hidden" name="firstDataFile" id="firstDataFile" value="<%=firstDataFile%>"></input>
				<table style="border: 1px solid black; width: 100%; padding: 20px;">
				  <tr>
				  	<td class="benchmarkHeader">Benchmark Candidates</td>
				  	<td class="benchmarkHeader">Bless Charts</td>
				  </tr>
				  <tr style="cellpadding: 4px;">
				    <td style="vertical-align: top;">
        				<c:choose>
        				  <c:when test="${not empty filenames }">
							<table>
								<c:forEach items="${filenames}" var="filename">
									<tr>
										<td class="benchmarkSelection"><input type="radio" name="benchmark" id="benchmark" value="${filename}"></input></td>
										<td><a href="#charts" onclick='javascript:showCharts("${filename}");'>${filename}</a><label name="arrow" id="arrow${filename}" style="visibility: hidden;"><strong> >>> </strong></label></td>
									</tr>
								</c:forEach>					
							</table>
						  </c:when>
						  <c:otherwise>
								<% if (success) { %>
									<strong>Benchmark file has been successfully added.</strong><br />
			  						<a href="#" onclick="window.close();">Close</a>
			  					<% } else { %>
						     		<strong>There are no .bless files for this detector from ${sinceDate}.</strong> 
								<% } %>
						  </c:otherwise>
						</c:choose>
					</td>
					<td style="vertical-align: top;">
						<div id="chartsDiv" style="visibility: hidden;">
							<h2 id="datafile"></h2>
							<h2>Rates</h2>
							<div id="channels" style="text-align: center; background-color:#FFFFFF;">
								<div id="channelChart" style="height:200px; width:550px"></div>
								<div id="channelChartLegend" style="margin:auto; width:300px"></div>        
							</div>
							<h2>Trigger Rate</h2>
							<div id ="triggerChart" style="width:550px; height:200px;"></div>
						</div>
					</td>
				  </tr>
				  <tr>
				  	<td class="benchmarkFooter" colspan="2">
				  		Enter Label <input type="text" name="benchmarkLabel" id="benchmarkLabel" value=""></input>
				  		<input type="submit" name="submitBenchmark" id="submitBenchmark" value="Save" onclick="return checkLabel();"></input>
				  		<div name="labelMsg" id="labelMsg" style="visibility: hidden;"></div>
				  	</td>
				  </tr>
				</table>
			  </form>
			</div>
		</div>
	</body>
</html>