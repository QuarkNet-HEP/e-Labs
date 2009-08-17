<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Big Picture</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
		
	<body id="big-picture" class="library">
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
			<h1>Big Picture: LIGO &mdash; A New Way to Explore the Universe.</h1>
			
			<p>
				<img class="float-right" src="../graphics/colliding_blackholes.jpg" 
					width="204" height="120" alt="[black_holes]" />
				You can diagnose seismic noise at LIGO Hanford Observatory and join scientists in their efforts to understand how ground vibrations influence LIGO's detectors. 
			</p>
			<p>
				<img class="float-right" src="../graphics/3Dinspiral.gif" 
					width="185" height="150" alt="[inspiral]" />
				LIGO scientists seek to measure faint ripples of space called gravitational waves. This is a new way to explore the Universe! Einstein predicted gravitational waves in 1916 as part of the theory of general relativity. However, he had little confidence that scientists would ever detect these waves&mdash;their effects on scientific instruments would be too small.
			</p>
			<p>
				Using huge interferometers in Washington State and Louisiana, LIGO, the Laser Interferometer Gravitational Wave Observatory, measures movements that are smaller that a thousandth of the size of an atomic nucleus. This radical level of sensitivity creates the possibility that gravitational waves now can be directly detected.
			</p>
			<p>
				LIGO is built on the ground, and the ground constantly vibrates at levels much greater than the effects of gravitational waves.  This background of seismic noise must be filtered to prevent it from contaminating LIGO's ultra-sensitive detectors. To better understand the noise, LIGO operates and monitors a network of seismometers and other instruments related to ground vibrations such as tiltmeters and weather stations. Using the LIGO e-Lab, you can play a role in LIGO's "noise diagnosis" process by studying seismic data from the LIGO Hanford facility.
			</p>
			
			<blockquote>
				Colliding Black Holes courtesy of Werner Benger, Zuse Institute 
				Berlin, Max-Planck Institutue fuer Gravitational Physics (Albert 
				Einstein Institute) and   the Center for Computation &amp; 
				Technology at Louisiana State   Universityr. 3D inspiral courtesy 
				of Patrick Brady
			</blockquote>
			<center>
				<img src="../graphics/lho_aerial_photo.jpg" 
					width="574" height="418" alt="[lho]" />
			</center>
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
