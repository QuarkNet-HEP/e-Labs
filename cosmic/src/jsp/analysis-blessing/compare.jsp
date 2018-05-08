<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
<%@ page import="org.apache.commons.lang.StringUtils" %>

    
<%
String file1 = request.getParameter("file1");
String file2 = request.getParameter("file2");

// Debug override
if (StringUtils.isBlank(file1)) {
	file1 = "6148.2011.0309.0"; 
}
if (StringUtils.isBlank(file2)) {
	file2 = "6148.2011.0310.0";
}
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
		<script type="text/javascript" src="../include/jquery/js/jquery-1.7.2.min.js"></script>
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
			$.plot($("#channelChart1"), [json.channel1, json.channel2, json.channel3, json.channel4, json.trigger ], options );
			$.plot($("#satChart1"), [ json.satellites ], options);
			$.plot($("#voltChart1"), [ json.voltage ], options);
			$.plot($("#tempChart1"), [ json.temperature ], options);
			$.plot($("#pressureChart1"), [ json.pressure ], options);
		}
		
		function onDataLoad2(json) {	
			$.plot($("#channelChart2"), [json.channel1, json.channel2, json.channel3, json.channel4, json.trigger ], options );
			$.plot($("#satChart2"), [ json.satellites ], options);
			$.plot($("#voltChart2"), [ json.voltage ], options);
			$.plot($("#tempChart2"), [ json.temperature ], options);
			$.plot($("#pressureChart2"), [ json.pressure ], options);
		}
		
		
		$(document).ready(function() {
			$.ajax({
				//url: "get-data.jsp?file=6148.2011.0309.0.bless",
				url: "get-data.jsp?file=<%= file1 %>",
				processData: false,
				dataType: "json",
				type: "GET",
				success: onDataLoad1
			});
			
			$.ajax({
				//url: "get-data.jsp?file=6148.2011.0310.0.bless",
				url: "get-data.jsp?file=<%= file2 %>",
				processData: false,
				dataType: "json",
				type: "GET",
				success: onDataLoad2
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
			<th>Golden File for range $DATE1-($DATE2)</th>
			<th>Your uploaded file</th>
		</tr>
		<tr>
			<div id="channelChart1" style="width:750px; height:250px; text-align: left;"></div>
			<div id="channelChart2" style="width:750px; height:250px; text-align: left;"></div>
		</tr>
		<tr>
			<td><div id="satChart1" style="width:400px; height:125px; text-align: left;"></div></td>
			<td><div id="satChart2" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="voltChart1" style="width:400px; height:125px; text-align: left;"></div></td>
			<td><div id="voltChart2" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="tempChart1" style="width:400px; height:125px; text-align: left;"></div></td>
			<td><div id="tempChart2" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		<tr>
			<td><div id="pressureChart1" style="width:400px; height:125px; text-align: left;"></div></td>
			<td><div id="pressureChart2" style="width:400px; height:125px; text-align: left;"></div></td>
		</tr>
		
		<tr>
			<td>&nbsp;</td>
			<td>
				<form method="post" action="golden-async.jsp" >
					<input type="button" value="Bless This File" />
					<input type="hidden" value="${file2}" />
				</form>
			</td>
		</tr>
	</table>
	
		 	</div>
		</div>
	</body>
</html>