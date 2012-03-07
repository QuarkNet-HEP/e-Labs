<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
<%@ page import="org.apache.commons.lang.StringUtils" %>

    
<%
String file = request.getParameter("file");
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
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
		<script type="text/javascript" src="../include/excanvas.min.js"></script>
		<script type="text/javascript">

		var channel1data, channel2data, channel3data, channel4data;
		
		var options = { 
			series: {
				lines: {
					show: false 
				},
				points: {
					show: true,
					radius: 0.5
				}
			},
			xaxis: {
				min: 0,
				max: 86400,
				tickSize: 7200 // 2 hours 
			},
			yaxis: {
				labelWidth: 50,
				reserveSpace: true,
			},
			xaxes: [ 
				{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
			],
			yaxes: [
				{ position: 'left', axisLabel: 'foo', axisLabelPadding: 10 }
			],
			colors: ["#000000"]
		};

		var chanOptions = $.extend({}, options, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });

		function seriesLabelFormatter(label, series) {
			var thisLabel = label.replace(" ", ""); 
			return "<input id=\"" + thisLabel + "checkbox\" type=\"checkbox\" checked></input>" + label + "&nbsp;&nbsp;&nbsp;";
		}
		
		function onDataLoad1(json) {	
			// we need channel data to be selectable, so do not discard it 
			channel1data = json.channel1;
			channel2data = json.channel2;
			channel3data = json.channel3;
			channel4data = json.channel4;

			$.plot($("#channelChart"), [channel1data, channel2data, json.channel3, json.channel4 ], chanOptions );
			$.plot($("#triggerChart"), [json.trigger], options);
			$.plot($("#satChart"), [ json.satellites ], options);
			$.plot($("#voltChart"), [ json.voltage ], options);
			$.plot($("#tempChart"), [ json.temperature ], options);
			$.plot($("#pressureChart"), [ json.pressure ], options);

			// attach listener callbacks to checkboxes to hide/unhide
		}
		
		$(document).ready(function() {
			$.ajax({
				url: "get-data.jsp?file=<%= file %>",
				processData: false,
				dataType: "json",
				type: "GET",
				success: onDataLoad1
			});
			
		}); 
		
		</script>
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
	
	<h1>Data Blessing Test</h1>
	
	<h2>Rates</h2>
	<div id="channelChart" style="width:750px; height:250px; text-align: left;"></div>

	<div id="channelChartLegend" style="width: 750px"></div>

	<h2>Trigger Rate</h2>
	<div id ="triggerChart" style="width:750px; height:250px; text-align: left;"></div>
	
	<h2>Visible GPS Satellites</h2>
	<div id="satChart" style="width:750px; height:250px; text-align: left;"></div>

	<h2>Voltage</h2>
	<div id="voltChart" style="width:750px; height:250px; text-align: left;"></div>

	<h2>Temperature</h2>
	<div id="tempChart" style="width:750px; height:250px; text-align: left;"></div>

	<h2>Barometric Pressure</h2>
	<div id="pressureChart" style="width:750px; height:250px; text-align: left;"></div>
	
		 	</div>
		</div>
	</body>
</html>