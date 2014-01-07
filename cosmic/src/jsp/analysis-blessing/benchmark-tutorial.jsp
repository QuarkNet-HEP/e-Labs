<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content" style="margin-left:auto; margin-right:auto; width:70%;">
			<table width="100%" cellpadding ="8">
				<tr>
					<td style="text-align: center;"><font color="#0a5ca6" size="+3">Benchmark Tutorial</font></td>
				</tr>
				<tr>
					<td style="text-align: left;">This is where a detector owner will select a <strong>best standard</strong> data file for 
						comparison to other files in order to bless the other. <br />
						The file owner needs to review the blessing plots and use judgement to select this one standard file.<br />
						Later, if the detector configuration changes (coincidence, geometry) then a new benchmark file
	 					need to be selected. <br /><br />
	 					(Examples go here)	 <br /><br />
						When selecting files for analysis, review the blessing plots by clicking on the "star". 
						See if you agree with the owner assessment for quality data.
					</td>
	 			</tr>
			</table>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

