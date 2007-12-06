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
			<h2>The Big Picture: LIGO and the Search for Gravitational Waves</h2>
			
			<p>
				<img class="float-right" src="../graphics/colliding_blackholes.jpg" 
					width="204" height="120" alt="[black_holes]" />
				<em>LIGO.</em> the Laser Interferometer Gravitational Wave Observatory, 
				searches for gravitational waves from exotic events in the universe 
				such as  black hole collisions, supernovae and the spinning of neutron 
				star pulsars. Direct detections of gravitational waves have never 
				occurred. LIGO and several sister projects around the world are 
				striving to make the first historic detections that will open the 
				exctiting new field of gravitational wave astronomny.
			</p>
			<p>
				<img class="float-right" src="../graphics/3Dinspiral.gif" 
					width="185" height="150" alt="[inspiral]" />
				<em>Gravitational waves</em> are ripples in the fabric of space (or 
				space-time). LIGO searches for the passage of these ripples using 
				huge interferometers in Washington State and Louisiana. These 
				interferometers are incredibly sensitive, capable of measuring 
				movements that are smaller that a thousandth of the size of an 
				atomic nucleus.  Only by operating at such radical sensitivities 
				will the detectors register the faint whispers of gravitational 
				waves.
			</p>
			<p>
				<em>The Earth</em> constantly vibrates at levels far above the 
				effects of gravitational waves.  LIGO relies on several subsystems to 
				filter these sources of "noise" out of the detectors' data streams. 
				Scientists can't devise filters unless the noise is well understood. 
				For this reason, LIGO constantly monitors the environments of the 
				Observatories with a large set of sensors -- seismometers, weather 
				stations, magnetometers, tilt meters and others.  In the LIGO E-Lab 
				you will analyze data from seismometers at the Hanford Observatory. 
				You will join LIGO scientists in their efforts to understand how the 
				ground vibrates and how these vibrations influence LIGO's 
				gravitational wave detectors.
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
