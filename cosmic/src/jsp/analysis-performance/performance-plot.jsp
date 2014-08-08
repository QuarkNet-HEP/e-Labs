<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>   

<%
String id = request.getParameter("id");
%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Performance Plot</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>

		<title>Performance</title>
	</head>
	<body class="upload" style="text-align: center;">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<script type="text/javascript" src="../include/jquery/flot/jquery.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.selection.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.navigate.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.crosshair.min.js"></script>
				<script type="text/javascript" src="../include/excanvas.min.js"></script>
				<script type="text/javascript" src="../include/canvas2image.js"></script>
				<script type="text/javascript" src="../include/base64.js"></script>
				<script type="text/javascript" src="performance.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "performance-get-data.jsp?id=<%=id%>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoad
					});
				}); 				
				</script>
				<h2>Performance Plot</h2>
				<div class="demo-container">
					<div id="placeholder" class="demo-placeholder" style="float:left; width:650px; height:650px;"></div>
					<div id="overview" class="demo-placeholder" style="float:right;width:160px; height:125px;"></div>
					<div id="interactive" style="float:right;width:160px; height:325px;">
						<p><label><input id="enableTooltip" type="checkbox" checked="checked"></input>Enable tooltip</label></p>
						<p>
							<label><input id="enablePosition" type="checkbox" checked="checked"></input>Show mouse position:</label>
							<br /><span id="hoverdata" class="hoverdata"></span>
							<br /><span id="clickdata" class="clickdata"></span>
						</p>				
						<p class="message"></p>
					</div>
					<div id="placeholderLegend" style="float:left; width:650px;"></div>
				</div>

		 	</div>
		</div>
	<div id="footer"></div>		
	</body>
</html>