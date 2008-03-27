<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Resources</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
		
	<body id="resources" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
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
			<h2>LIGO E-Lab Resources</h2>
			<ul>
				<li><a href="../data/tutorial.jsp">Bluestone Tutorial</a></li>
				<li><a href="http://tekoa.ligo-wa.caltech.edu">LIGO E-Lab Discussion Site</a></li>
				<li><a href="http://www.ligo-wa.caltech.edu">LIGO Hanford Observatory</a></li>
				<li><a href="http://ilog.ligo-wa.caltech.edu/ilog">LHO Electronic Log</a></li>
				<li><a href="http://earthquake.usgs.gov">USGS Earthquake Records</a></li>
				<li><a href="http://www.ess.washington.edu/SEIS/PNSN/">Pacific Northwest Seismic Network</a></li>
				<li><a href="http://www.gcse.com/waves/seismometers.htm">How Does a Seismometer Work?</a></li>
				<li><a href="http://www.darylscience.com/Demos/PSWaves.html">Types of Earthquake Waves</a></li>
				<li><a href="ligo_elab1.pdf">E-Lab Seismic Study (PDF)</a></li>
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
