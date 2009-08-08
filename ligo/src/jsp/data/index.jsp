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
					<%@ include file="../include/nav-rollover.jsp" %>
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
					<h2>Studies with LIGO Data</h2>

				<ul>
					<li>Earthquake Studies &mdash; LIGO's seismometer data supports many research questions related to earthquakes.  Look for earthquakes in the data in LIGO's low-frequency seismic channels &mdash; 0.03 to 0.1 Hz and 0.1 Hz to 0.3 Hz.

					<li>Environment Correlation Studies &mdash; Can you see relationships between seismic activity at LIGO and other environmental influences such as rainfall, wind patterns or temperature changes?

					<li>Human Activity Studies &mdash; Can you see relationships between seismic activity at LIGO and human activities such as traffic patterns?

					<li>Microseism Studies &mdash; Ocean waves produce seismic signals in the 0.1 - 0.3 Hz band of frequencies.  Can you see relationships between ground vibrations at LIGO and wind and wave activity on the oceans?
</ul>
<p>LIGO's data analysis software, <a href="/ligo/tla/">Bluestone</a>, provides access to LIGO seismometer data plus wind, temperature and rainfall data.  
Use the <a href="../info/related-data.jsp">Related Data</a> to find data from non-LIGO sources.
			<p>
				Bluestone allows you to select and plot data from LIGO data
		        channels, and it will eventually allow you to perform
				more complex analyses using LIGO data.
				<ul>
				<li>FIrst, take the <a href="/ligo/tla/tutorial.php">Bluestone Tutorial</a> to 
						to learn how to use this tool.
				<li>Then fire up 
				<a href="/ligo/tla/">Bluestone</a>
				as you start investigating your research question.
				<li>Once you generate a good plot, save it so you can add it to your poster.
				</ul>
				</ul>
			</p>
			
			<h3>Access your plots.</h3>
			
			<ul>
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
