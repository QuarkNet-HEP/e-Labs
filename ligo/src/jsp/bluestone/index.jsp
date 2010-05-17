<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
    
<%	String channels = request.getParameter("channels");
	String startTime = request.getParameter("startTime");
	String endTime = request.getParameter("startTime"); 



%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<title>Charting Test Page</title>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	    <!--[if IE]><script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script><![endif]--> 
	    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
	    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js" type="text/javascript"></script>
	    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
	    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
	    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.selection.min.js"></script>
	    
	    <script src="general.js" type="text/javascript"></script> <%-- General common stuff --%>
	    <script src="advanced.js" type="text/javascript"></script> <%-- Advanced Mode --%>
	</head>
	<body>
		<h1>Engineering Prototype for Super-Bluestone</h1>
		
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
						<div id="slider"></div>
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
		
		<div id="channel-list-advanced">
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
				
	</body>
	
</html>