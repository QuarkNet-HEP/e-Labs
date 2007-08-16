<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Lifetime study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="lifetime-tutorial" class="data, tutorial">
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
		<h1>Lifetime Study</h1>
<p>
			<center>
			
			<table width="650" cellpadding ="8">
				<tr>
					<td width="321" valign="top">
		 				Cosmic ray <a href="javascript:glossary('muon',100)">muons</a> reach the detector with 
		 				varying amounts of energy each depositing energy in the 
		 				<a href="javascript:glossary('counter',350)">counter</a>. Some are trapped in the 
		 				counter and eventually <a href="javascript:glossary('decay',350)">decay</a> into 
		 				an electron, a neutrino and an anti-neutrino.
					</td>
					
					<td width = "321" valign="top">
						These three particles zoom away (to conserve the momentum of the stopped muon). 
						The moving electron creates <a href="javascript:glossary('scintillation_light',100)">
						scintillation light</a> in the counter. Our 
						<a href="javascript:glossary('photomultiplier_tube',100)">photomultiplier</a>
						 (PMT) can see this light.
					</td>
				</tr>
				
				<tr>
					<td colspan="2" valign="top" align = "center">
						<img src="../graphics/decay.gif" alt="" width="508" height="220" align="middle"/>
					</td>
				</tr>
				
				<tr>
					<td colspan ="2">
							
					</td>
				</tr>
				
				<tr>
					<td width = "321" valign="top">
						Once the PMT "sees" the electron, we know the amount of time between the muon 
						stopping and decaying. The node that asks "Any Decays" looks for a light 
						signal from one counter (the incoming muon) and then waits. 
					</td>
					
					<td width = "321" valign = "top">
						If we see more light within the same counter before the gate closes, we may 
						have a decay! There is one unresolvable problem with this method. . .
					</td>
				</tr>
							
				<tr>
					<td colspan="2" align="right">
						Want to <a href="tutorial3.jsp">know more?</a>
					</td>
				</tr>
			</table>
			<p>
		</center>
		
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

