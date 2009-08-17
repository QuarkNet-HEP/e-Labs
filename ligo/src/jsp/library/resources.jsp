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

<!-- begin content body --> 

<div class='body'>
<h1>Resources: Check out the online resources or contact someone.</h1>


<%@ include file="../library/resources.htm" %>
</div>

<!--
<ul>
       <li><a href="../data/tutorial.jsp">Bluestone Tutorial</a></li>

       <li><a href="ligo_elab1.pdf">e-Lab Seismic Study (PDF)</a></li>

       <li><a href="http://www.ligo-wa.caltech.edu"
	      target='_blank'>LIGO Hanford Observatory</a>
	      <img src='/glossary/skins/monobook/external.png'>

       <li><a href="http://ilog.ligo-wa.caltech.edu/ilog"
	      target='_blank'>LHO Electronic Log</a>
	      <img src='/glossary/skins/monobook/external.png'>

       <li><a href="http://earthquake.usgs.gov"
	      target='_blank'>USGS Earthquake Records</a>
	      <img src='/glossary/skins/monobook/external.png'>

       <li><a href="http://www.ess.washington.edu/SEIS/PNSN/"
	      target='_blank'>Pacific Northwest Seismic Network</a>
	      <img src='/glossary/skins/monobook/external.png'>

       <li><a href="http://www.gcse.com/waves/seismometers.htm"
	      target='_blank'>How Does a Seismometer Work?</a>
	      <img src='/glossary/skins/monobook/external.png'>

       <li><a href="http://www.exploratorium.edu/faultline/basics/waves.html"
	      target='_blank'>Types of Earthquake Waves</a>
	      <img src='/glossary/skins/monobook/external.png'>
</ul>
-->

<!-- end content body --> 


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
