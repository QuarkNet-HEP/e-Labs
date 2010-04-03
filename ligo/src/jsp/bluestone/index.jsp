<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		    <!--[if IE]><script language="javascript" type="text/javascript" src="../include/excanvas.min.js"></script><![endif]--> 
		    <script language="javascript" type="text/javascript" src="../include/jquery/js/jquery-1.4.min.js"></script> 
		    <script language="javascript" type="text/javascript" src="../include/jquery/flot/jquery.flot.min.js"></script>
		<title>Charting Test Page</title>
	</head>
	<body>
		<div id="chart" style="width:600px; height:300px;"></div>
		
		<strong><span id="errorMessage" style="color:red"></span></strong>
		
		<input class="commandLine" type="text" size="100" style="width:300px;"></input>
		<input class="parseCommandLine" type="button" value="Execute Command"></input>
		<input class="fetchData" type="button" value="Get Test Data!"></input>
		
		<script language="javascript" type="text/javascript"> 
			$(function () {
			   var options = {
					   lines: { show: true },
					   points: { show: false },
					   xaxis: { tickDecimals: 0, tickSize: 100 },
			   };
			   var data = []; 
			   var placeholder = $("#chart");

			   $.plot(placeholder, data, options); 

			   // fetch one series, adding to what we got
			   var alreadyFetched = {};

			   $("input.parseCommandLine").click(function() {
				   var button = $(this); 
				   var command = $(".commandLine").val();
				   var dataURL = "../data/data-server.jsp?q=" + command;  
				   function onDataReceived(series) { 
			            // extract the first coordinate pair so you can see that
			            // data is now an ordinary Javascript object
			            var firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
			 
			            button.siblings('span').text('Fetched ' + series.label + ', first point: ' + firstcoordinate);

			            series.label = command; 

			            // let's add it to our current data
			            if (!alreadyFetched[command]) {
			                alreadyFetched[command] = true;
			                data.push(series);
			            }
			            
			            // and plot all we got
			            $.plot(placeholder, data, options);
				   }

				   function onErrorReceived(XMLHttpRequest, textStatus) {
					    if (textStatus == "timeout") {
						    $("#errorMessage").text("Sorry, the request timed out, please try again in a moment.").after("<br />"); 
					    }
					    else if (textStatus == "error") {
						    $("#errorMessage").text("It looks like you mistyped something; please check your expression.").after("<br />"); 
					    }
					    else {
						    $("#error").text() = "Oops"; 
					    }
				   }

				   $.ajax({
					   url: dataURL,
					   method: 'GET', 
					   dataType: 'json',
					   timeout: 500,
					   cache: false, 
					   success: onDataReceived,
					   error: onErrorReceived
				   });
			   })

			   $("input.fetchData").click(function() {
				   var button = $(this); 
				   var dataURL = "../data/data-server.jsp?q=data(\"dumy\",0,600,600)";
				   function onDataReceived(series) { 
			            // extract the first coordinate pair so you can see that
			            // data is now an ordinary Javascript object
			            var firstcoordinate = '(' + series.data[0][0] + ', ' + series.data[0][1] + ')';
			 
			            button.siblings('span').text('Fetched ' + series.label + ', first point: ' + firstcoordinate);
			            series.label = "Test Data"; 
						 
			            // let's add it to our current data
			            if (!alreadyFetched["test"]) {
			                alreadyFetched["test"] = true;
			                data.push(series);
			            }
			            
			            // and plot all we got
			            $.plot(placeholder, data, options);
				   }
				   
				   $.ajax({
					   url: dataURL,
					   method: 'GET', 
					   dataType: 'json',
					   success: onDataReceived
				   });
				});
			});
		</script> 
	</body>
</html>