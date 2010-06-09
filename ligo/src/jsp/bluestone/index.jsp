<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Super-Bluestone</title>
		<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script><![endif]-->
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<style type="text/css">
			span.dataName {
				font-size: x-small;
			}
		</style>
	</head>
    
    <body id="super-bluestone" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<noscript><b>This page requires Javascript</b><br /><br /></noscript>
				<%-- Scripts need to be loaded after nav-rollover since that is where the js pages live --%>
				<script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
			    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.selection.min.js"></script>
			    <script src="general.js" type="text/javascript"></script> <%-- General common stuff --%>
			    <script src="advanced.js" type="text/javascript"></script> <%-- Advanced Mode --%>
				<table border="0" id="main">
					<tr>
						<td id="left">
							<%@ include file="../include/left-alt.jsp" %>
						</td>
						<td id="center">
							<h1>Super Bluestone <span style="color: red">Public Beta 1</span></h1>
							<br /><br />
							Time<sub>start</sub>: <input readonly type="text" name="xmin" id="xmin" size="15" class="datepicker"></input>
							Time<sub>end</sub>: <input readonly type="text" name="xmax" id="xmax" size="15" class="datapicker"></input>
							<button title="Zoom to selection" id="buttonZoom">Zoom to selection</button>
							<button title="Zoom all the way out" id="buttonZoomOut">Zoom all the way out</button>
							<table>
								<tr>
									<td valign="top">
										<img src="../graphics/busy2.gif" id="busySpinner" style="visibility: hidden"></img>
									</td>
									 
									<td>
										<div id="resizablecontainer" style="margin-bottom: 10px; margin-right: 10px;" >
											<div id="chart" style="width:550px; height:250px; text-align: left;"></div>
											<%-- Temporarily disabled while I figure out how to properly resize the bar - pxn
											<div id="slider"></div>
											--%>
										</div>
									</td>
									
								</tr>
							</table>
							
							
							<strong><span id="errorMessage" style="color:red"></span></strong>
							
							<br />
							
							<%-- <input class="commandLine" type="text" size="100" style="width:300px;"></input> 
							<input class="parseCommandLine" type="button" value="Execute Command"></input>
							<input class="fetchData" type="button" value="Get Test Data!"></input>  --%>
							
							<%-- Super basic demo mode stuff for testing / showing-off
							
							<div id="channel_list">
								<select name="channel" id="channelSelector"> 
									<option value="placeholder">Select a channel: </option>
									<option value="L0:PEM-LVEA_SEISX.mean">Livingston X-Axis Vault Seismometer</option>
									<option value="L0:PEM-LVEA_SEISY.mean">Livingston Y-Axis Vault Seismometer</option>
									<option value="L0:PEM-LVEA_SEISZ.mean">Livingston Z-Axis Vault Seismometer</option>
									<option value="H0:PEM-LVEA_SEISX.mean">Hanford X-Axis Vault Seismometer</option>
									<option value="H0:PEM-LVEA_SEISY.mean">Hanford Y-Axis Vault Seismometer</option>
									<option value="H0:PEM-LVEA_SEISZ.mean">Hanford Z-Axis Vault Seismometer</option>
								</select>
								<input id="parseDropDown" type="button" value="Plot"></input>
							</div>
							
							--%>
							
							<%-- Advanced Mode --%>
							
							<h2>Data Selection</h2>
							
							<div id="channel-list-advanced">
								<input type="button" value="-" id="removeRow_0" class="removeRow"></input>
								<select name="site" id="site_0" class="site">
									<option value="H0">H0</option>
									<option value="L0">L0</option>
								</select>
								<select name="subsystem" id="subsystem_0" class="subsystem">
									<option value="DMT-BRMS_PEM_">DMT</option>
									<option value="PEM-">PEM</option>
									<option value="GDS-">GDS</option>
								</select>
								<select name="station" id="station_0" class="station"></select>
								<select name="sensor" id="sensor_0" class="sensor"></select>
								<select name="sampling" id="sampling_0" class="sampling"></select>
								<span id="dataName_0" class="dataName"></span>
								<br />
							</div>
							
							<input id="addNewRow" type="button" value="+"></input>
							<input id="parseDropDownAdvanced" type="button" value="Plot"></input>
							
							<h2>Save This Plot</h2>
							
							Title: <input id="userPlotTitle" name="title" type="text" maxlength="200" size="30"></input>
							<input id="savePlotToDisk" type="button" value="Save" disabled></input>
							<a href="#" target="_new" id="savedPlotLink" style="display: none;">View saved plot (popup)</a> 
						</td>
					</tr>
				</table>
			</div>
			
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
	</body>

</html>