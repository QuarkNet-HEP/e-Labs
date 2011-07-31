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
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
		<script type="text/javascript">
		
		function cross(ctx, x, y, radius, shadow) {
		    var size = radius * Math.sqrt(Math.PI) / 2;
		    ctx.moveTo(x - size, y - size);
		    ctx.lineTo(x + size, y + size);
		    ctx.moveTo(x - size, y + size);
		    ctx.lineTo(x + size, y - size);
		}
		
		var options = { 
				series: {
					lines: {
						show: false 
					},
					points: {
						show: true,
						lineWidth: 1,
						radius: 0.5,
						symbol: "circle"
					}
				},
				xaxis: {
					min: 0,
					max: 86400
				}
		};
		
		function onDataLoad1(json) {	
			$.plot($("#channelChart"), [json.channel1, json.channel2, json.channel3, json.channel4, json.trigger ], options );
			$.plot($("#satChart"), [ json.satellites ], options);
			$.plot($("#voltChart"), [ json.voltage ], options);
			$.plot($("#tempChart"), [ json.temperature ], options);
			$.plot($("#pressureChart"), [ json.pressure ], options);
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
	
	<table>
		<tr>
			<th>Your uploaded file</th>
		</tr>
		<tr>
			<td><div id="channelChart" style="width:750px; height:250px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="satChart" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="voltChart" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="tempChart" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="pressureChart" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
	</table>
	
		 	</div>
		</div>
	</body>
</html>