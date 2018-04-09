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
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>

<%
	String id = request.getParameter("id");
	//this code is for admin to be able to see the graph
	String userParam = (String) request.getParameter("user");
	if (userParam == null) {
		userParam = (String) session.getAttribute("userParam");
	}
	session.setAttribute("userParam", userParam);
	ElabGroup auser = user;
	if (userParam != null) {
	    if (!user.isAdmin()) {
	    	throw new ElabJspException("You must be logged in as an administrator" 
	        	+ "to see the status of other users' analyses");
	    }
	    else {
	        auser = elab.getUserManagementProvider().getGroup(userParam);
	    }
	}
	AnalysisRun results = AnalysisManager.getAnalysisRun(elab, auser, id);

	//create the file for the bless range chart
	String message = "";
	String fluxJsonFile = results.getOutputDir() + "/FluxBlessRange";
	File[] pfns = null;
	String[] filenames = null;
	try {
		//this code is for admin to be able to see the graph
		File f = new File(fluxJsonFile);
		if (!f.exists()) {
			ArrayList fileArray = (ArrayList) results.getAttribute("inputfiles");
			Collections.sort(fileArray);
		
			if (fileArray != null) {
				pfns = new File[fileArray.size()];
				filenames = new String[fileArray.size()];
				for (int i = 0; i < fileArray.size(); i++) {
					if (!fileArray.get(i).equals("[]") && !fileArray.get(i).equals("")) {
						String temp = (String) fileArray.get(i);				
						String cleanname = temp.replace(" ","");
						String pfn = RawDataFileResolver.getDefault().resolve(elab, cleanname) + ".bless";
						pfns[i] = new File(pfn);
						filenames[i] = cleanname;
					}
				}			
				if (pfns.length > 0) {
					BlessDataRange bdr = new BlessDataRange(elab,pfns,filenames,results.getOutputDir());
				}
			}
		}
	} catch (Exception e) {
			message = e.getMessage();
	}

	ArrayList<String> fileArray = (ArrayList<String>) results.getAttribute("inputfiles");
	Collections.sort(fileArray);
	BlessPlotDisplay bpd = new BlessPlotDisplay();
	ArrayList<String> fileIcons = new ArrayList<String>();
	for (int i = 0; i < fileArray.size(); i++) {
		    String filename = fileArray.get(i);
		  	String iconLinks = bpd.getIcons(elab, filename);
		  	fileIcons.add(filename+" "+iconLinks);
	}
	  
	request.setAttribute("fileArray", fileArray);
	request.setAttribute("fileIcons", fileIcons);
	request.setAttribute("id", id);
	request.setAttribute("outputDir", results.getOutputDirURL());
	request.setAttribute("message", message);

	 //EPeronja-09/24/2015: populated saved plots dropdowns
	  ArrayList<String> plotNames = DataTools.getPlotNamesByGroup(elab, user.getName(), elab.getName());
	  request.setAttribute("plotNames",plotNames); 

	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Blessing Plots From Flux Study</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>
		<!-- <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>	-->
		<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark"  >
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
		<script type="text/javascript" src="../include/json/json.worker.js"></script>
		<script type="text/javascript" src="../include/json/json.async.js"></script>
		<script type="text/javascript" src="blessing.js"></script>
		<script type="text/javascript" src="blessing-range.js"></script>
		<script>
			$(document).ready(function() {
				$.ajax({
					type: "GET",
					success: onDataLoad1
				});
			});
		</script>	
<h1>View blessing plots by date range.</h1>
<div style="text-align: center;">
	<a href="../analysis-flux/output.jsp?id=${id}">Go back to Flux Study</a> <br><br>
	Dates on the x-axis are converted from ms after midnight UTC.  
</div>
	<c:choose>
		<c:when test="${empty message }">
			<h2>Rates</h2>
			<!-- control added to change axes values -->
			<jsp:include page="chartcontrols-range.jsp">
				<jsp:param name="chartName" value="channel" />
			</jsp:include>				
			<div id="channels" style="background-color:#FFFFFF";">
				<div id="channelChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
				<div id="channelChartLegend" style="width: 750px;"></div>
			</div>
			<!-- EPeronja-07/31/2013 570-Bless Charts: add option to save them as plots -->
			<div style="text-align:center; width: 100%;">
				Filename <input type="text" name="channelChartName" id="channelChartName" value="">
          <select id="existingPlotNamesChannel" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />          				
				</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesChannel","channelChartName", onOffPlot, "channelMsg");' value="Save Channel Chart"></input>     
				<div id="channelMsg"></div>   
			</div>
								
			<h2>Trigger Rate</h2>
			<!-- control added to change axes values -->
			<jsp:include page="chartcontrols-range.jsp">
				<jsp:param name="chartName" value="trigger" />
			</jsp:include>					
			<div id ="triggerChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
			<div style="text-align:center; width: 100%;">
				Filename <input type="text" name="triggerChartName" id="triggerChartName" value="">
          <select id="existingPlotNamesTrigger" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />          
				</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesTrigger","triggerChartName", trigPlot, "triggerMsg");' value="Save Trigger Chart"></input>     
				<div id="triggerMsg"></div>   
			</div>

				<h2>Visible GPS Satellites</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols-range.jsp">
					<jsp:param name="chartName" value="satellite" />
				</jsp:include>				
				<div id="satChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="satChartName" id="satChartName" value="">
          <select id="existingPlotNamesSatellite" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    
					</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesSatellite","satChartName", satPlot, "satMsg");' value="Save Satellite Chart"></input>     
					<div id="satMsg"></div>   
				</div>

				<h2>Voltage</h2>
				<jsp:include page="chartcontrols-range.jsp">
					<jsp:param name="chartName" value="voltage" />
				</jsp:include>			
				<div id="voltChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="voltChartName" id="voltChartName" value="">
          <select id="existingPlotNamesVoltage" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    
 					</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesVoltage","voltChartName", voltPlot, "voltMsg");' value="Save Voltage Chart"></input>     
					<div id="voltMsg"></div>   
				</div>

				<h2>Temperature</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols-range.jsp">
					<jsp:param name="chartName" value="temperature" />
				</jsp:include>					
				<div id="tempChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="tempChartName" id="tempChartName" value="">
         <select id="existingPlotNamesTemperature" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    
					</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesTemperature","tempChartName", tempPlot, "tempMsg");' value="Save Temperature Chart"></input>     
					<div id="tempMsg"></div>   
				</div>
				
				<h2>Barometric Pressure</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols-range.jsp">
					<jsp:param name="chartName" value="pressure" />
				</jsp:include>				
				<div id="pressureChart" style="width:750px; height:250px; text-align: left; margin: auto auto 5px auto;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="pressChartName" id="pressChartName" value="">
          <select id="existingPlotNamesPressure" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                              
					</input><input type="button" name="save" onclick='return validateMultiplePlotName("existingPlotNamesPressure","pressChartName", pressPlot, "pressMg");' value="Save Pressure Chart"></input>     
					<div id="pressMsg"></div>   
				</div>				

		</c:when>
		<c:otherwise>
			<div>${message }</div>
		</c:otherwise>
	</c:choose>
	<c:if test="${not empty fileIcons}">
		<table>
			<tr><th>Files in charts</th></tr>
		<c:forEach items="${fileIcons }" var="file">
			<tr><td>${file }</td></tr>
		</c:forEach>
		</table>
	</c:if>
		<input type="hidden" name="outputDir" id="outputDir" value="${outputDir}"/>	
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
