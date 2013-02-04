<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>   
<%
String file = request.getParameter("file");

if (StringUtils.isBlank(file)) {
    throw new ElabJspException("Missing file name.");
}

VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(file);
if (entry == null) {
    throw new ElabJspException("No information about " + file + " found.");
}
entry.sort(); 
request.setAttribute("e", entry);

//find out if the user has ownership over the detector
ArrayList<String> detectors = (ArrayList<String>) user.getAttribute("cosmic:detectorIds");
boolean owner = false;
for (String s : detectors) {
	if (s.equals(entry.getTupleValue("detectorid"))) {
		owner = true;
	}
}
request.setAttribute("owner", owner);

//format registers
BlessRegister br0 = new BlessRegister((String) entry.getTupleValue("ConReg0"));
BlessRegister br1 = new BlessRegister((String) entry.getTupleValue("ConReg1"));
BlessRegister br2 = new BlessRegister((String) entry.getTupleValue("ConReg2"));
BlessRegister br3 = new BlessRegister((String) entry.getTupleValue("ConReg3"));
request.setAttribute("CR0", br0.getRegisterValue());
request.setAttribute("CR1", br1.getRegisterValue());
request.setAttribute("CR2", br2.getRegisterValue());
request.setAttribute("CR3", br3.getRegisterValue());

%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis List</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>

		<title>Data Blessing</title>
	</head>
	<body class="upload">
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

				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "get-data.jsp?file=<%= file %>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoad1
					});
				}); 
				
				function popUpClosed() {
					window.location.reload();
				}
				</script>
	
				<h1>Data Blessing Test -
				<%= entry.getTupleValue("school") %>, <%= entry.getTupleValue("city") %> - <%= entry.getTupleValue("state") %>
				</h1>
				<h2>Control Registers</h2>
				CR0: <strong><%= entry.getTupleValue("ConReg0") != null? entry.getTupleValue("ConReg0") : "Unknown" %></strong>,
				CR1: <strong><%= entry.getTupleValue("ConReg1") != null? entry.getTupleValue("ConReg1") : "Unknown" %></strong>,
				CR2: <strong><%= entry.getTupleValue("ConReg2") != null? entry.getTupleValue("ConReg2") : "Unknown" %></strong>,
				CR3: <strong><%= entry.getTupleValue("ConReg3") != null? entry.getTupleValue("ConReg3") : "Unknown" %></strong><br />
				CR0: <strong>${CR0}</strong><br />
				CR1: <strong>${CR1}</strong><br />
				CR2: <strong>${CR2}</strong><br />
				CR3: <strong>${CR3}</strong><br />	
				<div id="xAxesControl">
					<table id="xAxesControlTable">
						<tr>
							<td>Custom X-axes scale: </td>
							<td style="background-color: lightGray">Max X: <input type="text" id="maxX" /><input type="button" value="Set" id="maxXButton" onclick='javascript:redrawPlotX(maxX.value);' /></td>
							<!-- Need to check if user is related to this detector in order to be able to bless/unbless -->
							<% if (owner) { %>							
							<td style="background-color: lightGray">
							 	<form name="blessForm" action="blessdata.jsp" method="post" target="blessWindow" onsubmit="window.open('',this.target,'width=500,height=200,resizable=1');" align="center"> 
									<input type="hidden" name="blessed" value="${e.tupleMap.blessed}"/>
									<input type="hidden" name="filename" value="${e.tupleMap.source}"></input>
									<c:choose>
									  	<c:when test="${e.tupleMap.blessed == true}">
											<input type="submit" name="submitbless" id="submitbless" value="Unbless" />
										</c:when>
										<c:otherwise>
											<input type="submit" name="submitbless" id="submitbless" value="Bless" />
										</c:otherwise>
									</c:choose>	
								</form>
							</td>
							<% } %>
						</tr>
					</table>
				</div>
				<h2>Rates</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="channel" />
				</jsp:include>				
				<div id="channels" style="background-color:#FFFFFF">
					<div id="channelChart" style="width:750px; height:250px; text-align: left;"></div>
					<div id="channelChartLegend" style="width: 750px"></div>        
				</div>
				
				<h2>Trigger Rate</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="trigger" />
				</jsp:include>				
				<div id ="triggerChart" style="width:750px; height:250px; text-align: left;"></div>
	
				<h2>Visible GPS Satellites</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="satellite" />
				</jsp:include>				
				<div id="satChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Voltage</h2>
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="voltage" />
				</jsp:include>			
				<div id="voltChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Temperature</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="temperature" />
				</jsp:include>					
				<div id="tempChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Barometric Pressure</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="pressure" />
				</jsp:include>				
				<div id="pressureChart" style="width:750px; height:250px; text-align: left;"></div>
	
		 	</div>
		</div>
	</body>
</html>