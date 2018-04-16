<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
	    // errorpage.jsp sanitizes this for XSS
			throw new ElabJspException("No information about " + file + " found.");
	}
	String blessfilecomment = (String) entry.getTupleValue("blessfilecomment");
	if (blessfilecomment != null && !blessfilecomment.startsWith("blessfile NOT REPLACED")) {
		blessfilecomment = "We have improved the precision on this blessfile";
	}
	if (blessfilecomment != null && blessfilecomment.startsWith("blessfile NOT REPLACED")) {
		blessfilecomment = "We were unable to improve the precision of this blessfile";
	}
	String benchmarkfail = (String) entry.getTupleValue("benchmarkfail");
	if (benchmarkfail == null) {
		benchmarkfail = "";
	}
	entry.sort(); 
	request.setAttribute("e", entry);
	request.setAttribute("blessfilecomment", blessfilecomment);
	request.setAttribute("benchmarkfail", benchmarkfail);
	
	//EPeronja-02/18/2015: 641&645-Benchmark failure message and other icons
	BlessPlotDisplay bpd = new BlessPlotDisplay();
	String iconLinks = bpd.getIcons(elab, file);
	request.setAttribute("iconLinks",iconLinks);
	
	//EPeronja-01/24/2013: Bug472- find out if the user has ownership over the data
	boolean owner = false;
	String groupOwner = (String) entry.getTupleValue("group");
	if (groupOwner != null) {
		if (groupOwner.equals(user.getName())) {
			owner = true;
		}
	}
	request.setAttribute("owner", owner);
	String benchmark = (String) entry.getTupleValue("benchmarkreference");
	
	//EPeronja-02/04/2013: Bug472- format registers
	BlessRegister br0 = new BlessRegister((String) entry.getTupleValue("ConReg0"));
	request.setAttribute("CR0", br0.getRegisterValue());
	
	//EPeronja-09/24/2015: populated saved plots dropdowns
	ArrayList<String> plotNames = DataTools.getPlotNamesByGroup(elab, user.getName(), elab.getName());
	request.setAttribute("plotNames",plotNames); 
%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF8" />
		<title>Blessing Charts</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>

		<title>Data Blessing</title>
	</head>
	<body class="upload" style="text-align: center;">
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
				<script type="text/javascript" src="../include/canvas2image.js"></script>
				<script type="text/javascript" src="../include/base64.js"></script>
				<script type="text/javascript" src="blessing.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "get-data.jsp?file=<%= {fn:escapeXml(file)} %>&benchmark=<%=benchmark %>",
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
				<h1>Data Blessing: Want to use this data?  Look at these charts to determine data quality.</h1>
				<div style="text-align: center; font-size: small;"><strong>Data Blessing Test for ${param.file} -
				<%= entry.getTupleValue("school") %>, <%= entry.getTupleValue("city") %>, <%= entry.getTupleValue("state") %> -
				<fmt:formatDate value="${e.tupleMap.startdate}" pattern="dd MMM yyyy"/>				
				<c:if test="${not empty e.tupleMap.benchmarkreference }">
					- Benchmark: 
					<c:choose>
						<c:when test='${ e.tupleMap.benchmarkreference == "none" }'>
							This is a benchmark
						</c:when>
						<c:otherwise>
							${e.tupleMap.benchmarkreference }		
						</c:otherwise>
				</c:choose>
				</c:if>	
				</strong></div>
				<div style="text-align: center;font-size: small;"><i>${blessfilecomment}</i></font></div><br />
				<div style="text-align: center;">
					<a href="../data/view.jsp?filename=${param.file}">Show Data</a> |
					<a href="../data/view-metadata.jsp?filename=${param.file}">Show metadata</a> |
					<c:if test="${e.tupleMap.detectorid != null}">
						<a href="../geometry/view.jsp?filename=${param.file}">Show Geometry</a> |
					</c:if>
					<a href="../data/download?filename=${param.file}.bless&elab=${elab.name}&type=split">Download Bless File</a> |
					<e:popup href="../references/Reference_bless_data.html" target="DataBlessing" width="900" height="800">Interpreting the blessing plots</e:popup>
				</div>
				<h2>Control Register</h2>
				<table width="100%">
				    <tr><td width="20px">CR0: </td><td width="120px"><strong><%= entry.getTupleValue("ConReg0") != null? entry.getTupleValue("ConReg0") : "Unknown" %></strong></td>
				    	<td rowspan="2" style="width: 100px; text-align: left;">${iconLinks }</td><td rowspan="2" style="text-align: left; width:700px;">
						<c:if test="${not empty benchmarkfail }">
							<e:vswitch> 
								<e:visible image="../graphics/Tright.gif">
									Blessing Details
								</e:visible>
								<e:hidden image="../graphics/Tdown.gif">
									Blessing Details
									<table>
										<tr>
											<td> ${benchmarkfail }</td>
										</tr>
									</table>
								</e:hidden>
							</e:vswitch>
						</c:if> 				    	
						</td></tr>				    	
				    	
				    <tr><td width="20px"> </td><td width="100px"><strong>${CR0}</strong></td></tr>
				</table>								
				<div id="xAxesControl">
					<table id="xAxesControlTable">
						<tr>
							<td>Custom X-axes scale: </td>
							<td style="background-color: lightGray">Min X: <input type="text" id="minX" /><input type="button" value="Set" id="minXButton" onclick='javascript:redrawPlotX(minX.value, "min");' /></td>
							<td style="background-color: lightGray">Max X: <input type="text" id="maxX" /><input type="button" value="Set" id="maxXButton" onclick='javascript:redrawPlotX(maxX.value, "max");' /></td>
							<td style="background-color: lightGray"><input type="button" value="Reset" id="resetXButton" onclick='javascript:resetPlotX("minX","maxX");' /></td>
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
					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesChannel","channelChartName", onOffPlot, "channelMsg");' value="Save Channel Chart"></input>     
					<div id="channelMsg"></div>   
				</div>
									
				<h2>Trigger Rate</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="trigger" />
				</jsp:include>				
				<div id ="triggerChart" style="width:750px; height:250px; text-align: left;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="triggerChartName" id="triggerChartName" value="">
          <select id="existingPlotNamesTrigger" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />          
					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesTrigger","triggerChartName", trigPlot, "triggerMsg");' value="Save Trigger Chart"></input>     
					<div id="triggerMsg"></div>   
				</div>
	
				<h2>Visible GPS Satellites</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="satellite" />
				</jsp:include>				
				<div id="satChart" style="width:750px; height:250px; text-align: left;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="satChartName" id="satChartName" value="">
          <select id="existingPlotNamesSatellite" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />          					
					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesSatellite","satChartName", satPlot, "satMsg");' value="Save Satellite Chart"></input>     
					<div id="satMsg"></div>   
				</div>

				<h2>Voltage</h2>
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="voltage" />
				</jsp:include>			
				<div id="voltChart" style="width:750px; height:250px; text-align: left;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="voltChartName" id="voltChartName" value="">
          <select id="existingPlotNamesVoltage" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    
  					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesVoltage","voltChartName", voltPlot, "voltMsg");' value="Save Voltage Chart"></input>     
					<div id="voltMsg"></div>   
				</div>

				<h2>Temperature</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="temperature" />
				</jsp:include>					
				<div id="tempChart" style="width:750px; height:250px; text-align: left;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="tempChartName" id="tempChartName" value="">
          <select id="existingPlotNamesTemperature" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    
					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesTemperature","tempChartName", tempPlot, "tempMsg");' value="Save Temperature Chart"></input>     
					<div id="tempMsg"></div>   
				</div>
				
				<h2>Barometric Pressure</h2>
				<!-- control added to change axes values -->
				<jsp:include page="chartcontrols.jsp">
					<jsp:param name="chartName" value="pressure" />
				</jsp:include>				
				<div id="pressureChart" style="width:750px; height:250px; text-align: left;"></div>
				<div style="text-align:center; width: 100%;">
					Filename <input type="text" name="pressChartName" id="pressChartName" value="">
          <select id="existingPlotNamesPressure" style="max-width: 150px; min-width: 150px; width: 150px !important;" onchange="this.previousElementSibling.value=this.value; this.previousElementSibling.focus()">
            <option></option>
            <c:forEach items="${ plotNames}" var="plotName">
              <option>${plotName }</option>
            </c:forEach>
          </select>
          (View your saved plot names)<br />                    					
					</input><input type="button" name="save" onclick='validateMultiplePlotName("existingPlotNamesPressure","pressChartName", pressPlot, "pressMsg");' value="Save Pressure Chart"></input>     
					<div id="pressMsg"></div>   
				</div>				
		 	</div>
		</div>
	</body>
</html>
