<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>

<% response.setHeader("Expires", (new java.util.Date()).toGMTString());
   response.setHeader("Cache-Control", "no-cache, no-store"); 
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose data for flux study</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<link rel="stylesheet" type="text/css" href="../css/ltbr.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="flux" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Choose data for flux study.</h1>
<div id="rationale">Things in nature change over time. Populations grow, stars explode, galaxies spin, and the universe expands. Measuring some attribute over time, observing it change and then looking for what caused the change is central to all of the physical sciences. The rate at which cosmic rays arrive is called "flux." You can look to see if the flux at a certain place changes over time or compare rates at different places. Can you find out why?</div>
<div id="rationale">Gain confidence by running a practice search.</div>
<table border="0" id="main">
	<tr>
		<td>
			<div id="ltbr">
				<div id="top-left">
					<jsp:include page="../data/multiselect-search-control.jsp">
						<jsp:param name="type" value="split"/>
					</jsp:include>
				</div>
				<form action="controller.jsp" method="post" id="results-form">
					<div id="bottom-left">
						<jsp:useBean scope="request" 
							class="gov.fnal.elab.datacatalog.MultiSelectStructuredResultSetDisplayer" 
							id="searchResultsDisplayer"/>
						<div class="search-results">
							<jsp:include page="../data/multiselect-search-results.jsp"/>
						</div>
					</div>
					<!-- this kind of nesting is an interesting problem -->
					<div id="right">
						<div id="analyze" class="study-right">
							<h2>Analyze</h2>
							<input type="submit" name="action" value="Run flux study"/>
						</div>
						<%@ include file="help.jsp" %>
						<%@ include file="../data/legend.jsp" %>
					</div>
				</form>
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
