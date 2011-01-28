<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>What can you learn? Choose a study.</h1>
<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="tab">
					<span class="tab-title">Analysis</span>
					<div class="tab-contents">
					<p>
						<a href="../analysis-calibration/"><b>Calibration Studies:</b></a> Physicists use mass plots
						to determine the mass of particles. They know their detector is working correctly if the mass they measure agrees with the known mass of the particle.</p>
						<p>Use CMS simulated data, also called Monte Carlo data, to familiarize yourself with mass plots. Once you feel confident you understand these plots, go to the Exploration Studies
						to analyze real data and confirm that the detector is working properly.</p>
						
						
						<p><i>Coming Soon:</i></p>
							<p>Currently Calibration Studies only allows access to simulated data. In the future, you will be
							able to use this tool with real data.</p>
						<%-- <p><a href="../analysis-calibration">Confirmation of the Z and J/Psi masses</a>
							- Confirm that the detector is able to measure the Upsilon and J/Psi masses.</p>  --%>	


					<p>	<a href="../analysis-exploration"><b>Exploration Studies:</b></a> Use CMS data to perform a variety of analyses including confirmation of the Z and J/Psi mass.</p>
							
							
						<div style="margin-left: 10px">
							<p><b>Confirmation of Z mass</b>
							- Confirm that the detector is able to measure the Z mass.</p></div>

						<div style="margin-left: 10px">
							<p><b>Confirmation of J/Psi mass</b>
							- Confirm that the detector is able to measure the J/Psi mass.</p></div>

						<p><i>Coming Soon:</i></p>
						<div style="margin-left: 10px">
							<p><b>Energy - Momentum Equivalence</b>
							- Use CMS data to confirm energy - momentum equivalence (for low-mass particles in high energy physics).
						</p></div>
						
						</div>
				</div>
				</div>		
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab">
					<span class="tab-title">Management</span>
					<div class="tab-contents">
						<h2>VIEW</h2>
						<p> 
							<a href="../plots/?submit=true&key=all&uploaded=true">Plots</a> -
							Look at your and the plots of other research groups...
						</p>
						<h2>DELETE</h2>
						<p>
							<a href="../plots/delete.jsp">Plots</a>
							- Delete plots your group owns.
						</p>
					</div>
				</div>
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
