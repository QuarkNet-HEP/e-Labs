<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Tiltmeters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/info.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
		
	<body id="tiltmeters" class="info">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-sensors.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<%@ include file="../include/left-alt.jsp" %>
			</div>
		</td>
		<td width="100%">
			<div id="center">
				<h2>LIGO Environmental Sensors: Tiltmeters</h2>
				
				<p align="center">
					<img src="../graphics/tilt.jpg" width="432" height="386" />
				</p>
				<p>
					Tiltmeters measure small changes in the tilt of the ground 
					or of a structure. Tiltmeters are analogous to a highly 
					sensitive carpenter's level with an electronic output.
				</p>
			</div>
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
