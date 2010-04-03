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
			$(function () {
			   var options = {
					   lines: { show: true, lineWidth: 1 },
					   points: { show: false },
					   xaxis: { tickDecimals: 0, tickSize: 100 },
					   legend: { show: false },
					   selection: { mode: "x" }
			   };
			   var data = []; 
			   var placeholder = $("#chart");
			   var timeout = 500; 
			   var index = 0; 

			   $.plot(placeholder, data, options); 

			   // fetch one series, adding to what we got
			   var alreadyFetched = {};

			   $("#parseDropDown").click(function() {
				   var f = $("#channelSelector").val(); 
				   var n = $("#channelSelector :selected").text(); 
				   var xmin = $("#xmin").val(); // TODO: Validate
				   var xmax = $("#xmax").val(); // TODO: Validate
				   var command = "data(\"" + f + "\", " + xmin + "," + xmax + "," + "100)"; 
				   var dataURL = "../../cosmic/data/data-server.jsp?q=" + command;
				   
				   // Get the data via AJAJ call
				   if (!alreadyFetched[command]) {
					   $.ajax({
						   url: dataURL,
						   method: 'GET', 
						   dataType: 'json',
						   success: onDataReceived,
						   error: onErrorReceived
					   });
				   }

				   // Do something with the data (i.e. plot it)
				   function onDataReceived(series) { 
			            series.label = f; 
			            series.shadowSize = 0;  
			            series.color = index; 
			            

			            // let's add it to our current data
		                data.push(series);
		                alreadyFetched[command] = true; 
			            
			            // and plot all we got
			            //var plot = $.plot(placeholder, data, options);
			            addTableEntry();
			            plotChart(); 

			            index++;  
				   }

				   // Timeout/corrupt data/other badness? Do something!

				   // Add to the table of things below (checked)
				   function addTableEntry() {
					   $("#entryList tr:last").after("<tr id=\"" + f + "\"><td><input type=\"checkbox\" id=\"checkIndex" + index + "\" checked></input></td><td id=\"colorIndex" + index + "\">" + index  + "</td><td>" + n + "</td></tr>");
				   } 

				   // Setup handler so we can hide/unhide chart elements 
			   });

			   // Function to (1) regenerate the table and (2) put a color marker on it. 
			   // table has CHECKBOX	COLOR	LABEL

			   function plotChart() {
				   // set colors
				   
				   // regen table
				   
				   // plot chart
				   var plot = $.plot(placeholder, data, options);
				   var allSeries = plot.getData(); 

				   for (var i = 0; i < allSeries.length ; ++i) {
					   $("td#colorIndex" + i).css("background-color", allSeries[i].color); 
				   } 

				   
			   }
			   
			   function onErrorReceived(XMLHttpRequest, textStatus) {
				    if (textStatus == "timeout") {
					    $("#errorMessage").text("Sorry, the request timed out, please try again in a moment."); 
				    }
				    else if (textStatus == "error") {
					    $("#errorMessage").text("It looks like you mistyped something; please check your expression."); 
				    }
				    else {
					    $("#error").text() = "Oops"; 
				    }
			   }

			   $("#chart").bind("plotselected", function (event, ranges) {
				   // first plot low-res data
				   // then grab new data 
				   // plot new data
				   // probably should show some sort of 'WORKING' spinny icon
				   var plot = $.plot(placeholder, data,
						   $.extend(true, {}, options, {
							   xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
						   }));
				   var allSeries = plot.getData(); 

				   var thisCommand; 
				   var thisDataUrl; 
				   var newData = []; 
				   alreadyFetched = {}; 
				   for (var i = 0; i < allSeries.length ; ++i) {
					   thisCommand = "data(\"" + allSeries[i].label   + "\", " + ranges.xaxis.from.toFixed() + "," + ranges.xaxis.to.toFixed() + "," + "100)";
					   thisDataUrl = "../../cosmic/data/data-server.jsp?q=" + thisCommand;

					   $.ajax({
						   url: thisDataUrl,
						   method: 'GET', 
						   dataType: 'json',
						   success: onDataReceived,
						   error: onErrorReceived,
						   async: false
					   });
				   } 
				   
				   $.plot(placeholder, newData, options); 

				   function onDataReceived(series) {
					   series.shadowSize = 0;  
			           series.color = index;

			           newData.push(series); 
				   }
 
			   });
			   
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
					X<sub>min</sub>: <input type="text" name="xmin" id="xmin" value="0" size="4"></input>
					<br />
					X<sub>max</sub>: <input type="text" name="xmax" id="xmax" value="10" size="4"></input>
					<br />
					<button title="Zoom to selection" id="buttonZoom" >Zoom to selection</button>
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
				<option value="sin">Sine</option>
				<option value="cos">Cosine</option>
			</select>
			<input id="parseDropDown" type="button" value="Add to chart"></input>
		</div>
		
		<table border="1" id="entryList">
			<tr>
				<th>&nbsp;</th>
				<th>Color</th>
				<th>Channel</th>
			</tr>
		</table>		
	</body>
</html>