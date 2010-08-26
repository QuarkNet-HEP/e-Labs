<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>LIGO data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	
	<body id="data" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
		<h1>Data: What can you learn? Choose data and conduct a study.</h1> 
					<h3>Studies with LIGO Data</h3>
				<ul style="margin-left:30px">
					<li>Earthquake Studies &mdash; LIGO's seismometer data supports many research questions related to earthquakes.  Look for earthquakes in the data in LIGO's low-frequency seismic channels &mdash; 0.03 to 0.1 Hz and 0.1 Hz to 0.3 Hz.

					<li>Environment Correlation Studies &mdash; Can you see relationships between seismic activity at LIGO and other environmental influences such as rainfall, wind patterns or temperature changes?

					<li>Human Activity Studies &mdash; Can you see relationships between seismic activity at LIGO and human activities such as traffic patterns?

					<li>Microseism Studies &mdash; Ocean waves produce seismic signals in the 0.1 - 0.3 Hz band of frequencies.  Can you see relationships between ground vibrations at LIGO and wind and wave activity on the oceans?
				</ul>
			
<h3>Access to Data (from the Navigation Bar)</h3>
<p>Use <b>Bluestone</b> for access to LIGO seismometer data plus wind, temperature and rainfall data. Use <b>Related Data</b> to find data from non-LIGO sources.
<h3>Access to Plots</h3>
				<ul style="margin-left:30px">
					<li><a href="../plots">View Plots</a>
					- Look at what you and other groups have found!
					<li><a href="../plots/delete.jsp">Delete Plots</a>
					- Delete plots your group owns.
				</ul>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	

			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>

		</div>
		<!-- end container -->
	</body>
</html>
