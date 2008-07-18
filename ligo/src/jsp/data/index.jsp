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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h2>Access LIGO data using Bluestone</h2>
			
			<p>
				Bluestone software allows you to select and plot data from 
				LIGO data channels. 
				<ul>
				<li>Check out the <a href="tutorial.jsp">Bluestone Tutorial</a> to 
				improve your skills at using this tool.</li>
				<li>Then fire up 
				<a href="http://tekoa.ligo-wa.caltech.edu/tla">Bluestone</a>
				as you start investigating your research question.</li>
				</ul>
			</p>
			
			<h2>Access your plots, uploaded images and posters</h2>
			
			<p>
				<table>
					<tr>
						<th>View</th>
						<th>Delete</th>
					</tr>
					<tr>
						<td>
							<p> 
								<a href="../plots">Plots</a>
								- Look at what you and other groups have found!
							</p>
							<p>
								<a href="../posters">Posters</a>
								- View and create posters of your plots.
							</p>
						</td>
						<td>
							<p>
								<a href="../plots/delete.jsp">Plots</a>
								- Delete plots your group owns.
							</p>
							<p>
								<a href="../posters/delete.jsp">Posters</a>
								- Delete posters your group has made.
							</p>
						</td>
					</tr>
				</table>
			</p>
			
			<h2>
				<a href="http://gridcafe.web.cern.ch/gridcafe/">Grids</a> - 
				These investigations are brought to you by grid computing.
			</h2>
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
