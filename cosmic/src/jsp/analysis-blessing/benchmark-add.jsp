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
<%@ page import="java.util.Map.Entry" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<% 
	// EPeronja-05/21/2013: Add a benchmark file from datafile candidates
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	//get parameters from benchmark.jsp
	String detector = request.getParameter("detector");
	String fromDate = request.getParameter("fromDate");
	String toDate = request.getParameter("toDate");	
	boolean success = false;
	Date startDate = null; 
	Date endDate = null; 
	String firstDataFile = "";
	TreeMap<String, String> filenameDisplay = new TreeMap<String, String>();
	
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
				//get all the tuples needed for the blessing
				Long chan1 = (Long) entry.getTupleValue("chan1");
				Long chan2 = (Long) entry.getTupleValue("chan2");
				Long chan3 = (Long) entry.getTupleValue("chan3");
				Long chan4 = (Long) entry.getTupleValue("chan4");
				Long triggers = (Long) entry.getTupleValue("triggers");
				Date startdate = (Date) entry.getTupleValue("startdate");
				Date enddate = (Date) entry.getTupleValue("enddate");
			    Long duration = 0L;
				double chan1Rate, chan2Rate, chan3Rate, chan4Rate, triggerRate;
				try {
					duration = (Long) (enddate.getTime() - startdate.getTime()) / 1000;
					chan1Rate = chan1.doubleValue()/ duration;
					chan2Rate = chan2.doubleValue() / duration;
					chan3Rate = chan3.doubleValue() / duration;
					chan4Rate = chan4.doubleValue() / duration;
					triggerRate = triggers.doubleValue() / duration;	
				} catch (Exception e) {
					chan1Rate = chan2Rate = chan3Rate = chan4Rate = triggerRate = 0;				
				}			    
		    	entry.setTupleValue("blessed", true);
		    	dcp.insert(entry);
				ArrayList meta = new ArrayList();
				meta.add("benchmarkfile boolean true");
				meta.add("benchmarkreference string none");
				meta.add("benchmarkdefault boolean true");
				meta.add("benchmarklabel string "+benchmarkLabel);
				meta.add("duration int " + String.valueOf(duration));
				meta.add("chan1Rate float " + String.valueOf(chan1Rate));
				meta.add("chan2Rate float " + String.valueOf(chan2Rate));
				meta.add("chan3Rate float " + String.valueOf(chan3Rate));
				meta.add("chan4Rate float " + String.valueOf(chan4Rate));
				meta.add("triggerRate float " + String.valueOf(triggerRate));				
				dcp.insert(DataTools.buildCatalogEntry(benchmark, meta));	
				success = true;
			}//end of setting/removing default benchmark file
		}
	} else {
	//or retrieving candidates?
		if (StringUtils.isNotBlank(fromDate)) {
			if (StringUtils.isNotBlank(fromDate)) {
				startDate = DATEFORMAT.parse(fromDate); 
			}
			if (StringUtils.isNotBlank(toDate)) {
				endDate = DATEFORMAT.parse(toDate); 
			}
			//retrieve datafiles from the start date selected
			ResultSet rs = Benchmark.getBenchmarkCandidates(elab, Integer.parseInt(detector), startDate, endDate);
			if (rs != null) {
				String[] results = rs.getLfnArray();	
				ArrayList<String> filenames = new ArrayList<String>();
				//check if these files have a .bless associated with them
				for (int i=0; i < results.length; i++ ) {
					VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(results[i]);
					String display = Benchmark.getIcons(entry);
					if (entry.getTupleValue("blessfile") != null) {
						//check if file has already been selected as benchmark, the only way to add it to
						//this list again is if the benchmarkfile flag has been set to false.
						if (entry.getTupleValue("benchmarkfile") != null) {
							Boolean benchmarkFile = (Boolean) entry.getTupleValue("benchmarkfile");
							if (benchmarkFile == false) {
								filenames.add(results[i]);
								filenameDisplay.put(display, results[i]);
							}
						} else {
							filenameDisplay.put(display, results[i]);
						}
					}
				}
				//set the files we are displaying
				request.setAttribute("filenames", filenames);
				request.setAttribute("filenameDisplay", filenameDisplay);
				if (filenameDisplay.size() > 0) {
					Entry<String,String> firstEntry = filenameDisplay.firstEntry();
					firstDataFile = firstEntry.getValue();
				}
				request.setAttribute("firstDataFile", firstDataFile);
			}
		}
	}
	request.setAttribute("success", success);
	request.setAttribute("detector", detector);
	request.setAttribute("fromDate", fromDate);
	request.setAttribute("toDate", toDate);	
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
		<script type="text/javascript" src="blessing.js"></script>	
		<script type="text/javascript" src="benchmark.js"></script>
		<script>
		$(document).ready(function() {
			if ("<%=firstDataFile%>" != null && "<%=firstDataFile%>" != "") {
				showCharts("<%=firstDataFile%>", "get-data.jsp?file=");
			}
		});		
		</script>
		<script>
			window.onunload = function() {
			    if (window.opener && !window.opener.closed) {
			        window.opener.popUpClosed();
			    }
			};		
		</script>
	</head>
	<body>
		<div id="container">
			<div id="content">
			  <form name="addBenchmarkFileForm" method="post" >
				<h1>Select benchmark files for detector: <%=detector%></h1>
				<ul>
					<li>Navigate through data files to <strong>examine charts</strong> before you choose a benchmark file.</li>
					<li>Select <strong>benchmark</strong> file.</li>
					<li>Add a meaningful <strong>label</strong> to this benchmark file.</li>
				</ul>
				<input type="hidden" name="success" id="success" value="<%=success%>"></input>
				<input type="hidden" name="detector" value="<%=detector%>" ></input>
				<input type="hidden" name="fromDate" value="<%=fromDate%>" ></input>
				<input type="hidden" name="toDate" value="<%=toDate%>" ></input>
				<input type="hidden" name="firstDataFile" id="firstDataFile" value="<%=firstDataFile%>"></input>
				<table style="border: 1px solid black; width: 100%; padding: 5px;">
				  <tr class="benchmarkRow">
				  	<td class="benchmarkHeader">Benchmark Candidates</td>
				  	<td class="benchmarkHeader">
				  		Enter Label <input type="text" name="benchmarkLabel" id="benchmarkLabel" value=""></input>
				  		<input type="submit" name="submitBenchmark" id="submitBenchmark" value="Save" onclick="return checkLabel();"></input>				  	
				  	</td>
				  </tr>
				  <tr>
				  	<td colspan="2"><div name="messages" id="messages" class="messages"></div></td>
				  </tr>
				  <tr>
				    <td nowrap class="detectorList">
        				<c:choose>
        				  <c:when test="${not empty filenames }"> 				  
        				  	<div class="detectorTable" id="tableWrapper">
								<c:forEach items="${filenameDisplay}" var="filename">
									<div id="${filename.value}">
	       							<table id="table${filename.value}" class="highlight">
										<tr>
											<td class="benchmarkSelection"><input type="radio" name="benchmark" id="benchmark${filename.value}" value="${filename.value}" class="selectBenchmark"></input></td>
											<td><a href="#charts" onclick='javascript:showCharts("${filename.value}", "get-data.jsp?file=");'>${filename.value}</a> ${filename.key}</td>
										</tr>
									</table>
									</div>
								</c:forEach>					
							</div>
						  </c:when>
						  <c:otherwise>
								<% if (success) { %>
									<strong>Benchmark file has been successfully added.</strong><br />
			  						<a href="#" onclick="window.close();">Close</a>
			  					<% } else { %>
						     		<strong>There are no .bless files for this detector from ${fromDate} to ${toDate}.</strong> 
								<% } %>
						  </c:otherwise>
						</c:choose>
					</td>
						<td style="vertical-align: top;">
	        				<c:choose>
	        				  <c:when test="${not empty filenames }"> 				  
									<%@ include file="benchmark-charts.jspf" %>
							  </c:when>
							</c:choose>
						</td>
				  </tr>
				</table>
			  </form>
			</div>
		</div>
	</body>
</html>