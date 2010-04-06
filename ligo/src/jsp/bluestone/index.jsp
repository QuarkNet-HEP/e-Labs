<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<title>Charting Test Page</title>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	    <!--[if IE]><script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script><![endif]--> 
	    <script language="javascript" type="text/javascript" src="../include/jquery/js/jquery-1.4.min.js"></script> 
	    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
	    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.selection.min.js"></script>
		<script language="javascript" type="text/javascript"> 
			$(document).ready(function() {
				var options = { 
						lines: {show: true, lineWidth: 1 },
						points: {show: false},
						legend: {show: false},
						xaxis: { mode: 'time'},
						selection: { mode: "x" },
						shadowSize: 0,
				};
				
				var data = []; 
				var placeholder = $("#chart");
				var timeout = 10000;
				var dataServerUrl = '/elab/ligo/data/data-server.jsp';

				var xminGPSTime;
				var xmaxGPSTime; 

				var ligoMinTime; 
				var ligoMaxTime; 
				
				// Get maximum timespan to start
				$.ajax({
					url: dataServerUrl + '?fn=getTimeRange', 
					method: 'GET',
					dataType: 'text', 
					timeout: 10000,
					success: onTimeRangeReceived,
					beforeSend: spinnerOn,
					complete: onTimeRangeCompleted
				});

				function onTimeRangeReceived(series) {
					var s = $.trim(series).split(" ");
					xminGPSTime = s[0];
					ligoMinTime = s[0];
					xmaxGPSTime = s[1];
					ligoMaxTime = s[1];
					$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
					$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
				}

				function onTimeRangeCompleted() {
					spinnerOff();
				}

				function spinnerOn() {
					$("#busySpinner").css('visibility', 'visible');
				}

				function spinnerOff() {
					$("#busySpinner").css('visibility', 'hidden');
				}

				$("#buttonZoom").click(function() {
					$("#parseDropDown").trigger('click');
				});

				$("#buttonZoomOut").click(function() {
					xminGPSTime = ligoMinTime;
					xmaxGPSTime = ligoMaxTime;
					$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
					$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
					$("#parseDropDown").trigger('click');
				});

				placeholder.bind("plotselected", function(event, ranges) {
					xminGPSTime = convertTimeUNIXtoGPS(ranges.xaxis.from / 1000.0); 
					xmaxGPSTime = convertTimeUNIXtoGPS(ranges.xaxis.to / 1000.0); 
					$("#xmin").val((new Date(ranges.xaxis.from)).toDateString()); 
					$("#xmax").val((new Date(ranges.xaxis.to)).toDateString());
				});

				$("#parseDropDown").click(function() {
					var c = $("#channelSelector :selected").val();
					if (c == "placeholder") {
						return;
					}

					var url = dataServerUrl + '?fn=getData&params=' + c + ',0,' + xminGPSTime + ',' + xmaxGPSTime;

					// Get the data via AJAT call
					$.ajax({ 
						url: url,
						method: 'GET', 
						dataType: 'text',
						timeout: timeout,
						success: onChannelDataReceived,
						beforeSend: spinnerOn,
						complete: spinnerOff
					});

					function onChannelDataReceived(series) { 
						var s = series.split(" ");
						var a = new Array();
						var num = s[0];
						for (var i = 0; i < s.length / 2 - 1; i++) {
							a.push([convertTimeGPSToUNIX(parseFloat(s[i * 2 + 1])) * 1000.0, s[i * 2 + 2]]);
						}
						data = [{data: a}];

						$.plot(placeholder, data, options); 
					}
				});

				function convertTimeGPSToUNIX(x) { 
					// TODO: Make a proper offset, this is off depending on leap seconds
					return x + 315964787.0;
				}

				function convertTimeUNIXtoGPS(x) {
					return x - 315964787.0;
				}
			});
		</script> 
	</head>
	<body>
		<h1>Engineering Prototype for Super-Bluestone</h1>
		
		<table>
			<tr>
				<td>
					<div id="chart" style="width:550px; height:250px;"></div></td>
				<td valign="top">
					X<sub>min</sub>: <input readonly type="text" name="xmin" id="xmin" size="15" class="datepicker"></input>
					<br />
					X<sub>max</sub>: <input readonly type="text" name="xmax" id="xmax" size="15" class="datapicker"></input>
					<br />
					<button title="Zoom to selection" id="buttonZoom">Zoom to selection</button>
					<br />
					<button title="Zoom all the way out" id="buttonZoomOut">Zoom all the way out</button>
					<br />
					<img src="../graphics/busy2.gif" id="busySpinner" style="visibility: hidden"></img>
				</td>
			</tr>
		</table>
		
		
		<strong><span id="errorMessage" style="color:red"></span></strong>
		
		<br />
		
		<%-- <input class="commandLine" type="text" size="100" style="width:300px;"></input> 
		<input class="parseCommandLine" type="button" value="Execute Command"></input>
		<input class="fetchData" type="button" value="Get Test Data!"></input>  --%>
		
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
		
	</body>
</html>