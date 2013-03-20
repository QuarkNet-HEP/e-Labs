<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<link rel="stylesheet" type="text/css" href="../css/ltbr.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="delete-data" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Search and delete uploaded data.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="ltbr">
				<div id="top-left">
					<%@ include file="../include/delete.jsp" %>
					<c:if test="${!inhibitPage}">
						<jsp:include page="../data/search-control.jsp"/>
					</c:if>
				</div>
				<c:if test="${!inhibitPage}">
					<form action="delete.jsp" method="get" id="results-form">
						<div id="bottom-left">
							<jsp:useBean scope="request" 
									class="gov.fnal.elab.datacatalog.MultiSelectStructuredResultSetDisplayer" 
									id="searchResultsDisplayer"/>
							<jsp:setProperty name="searchResultsDisplayer" property="controlName" value="file"/>
							<jsp:setProperty name="searchResultsDisplayer" property="actionName" value="delete" />
							
							<div class="search-results">
								<jsp:include page="../data/search-results.jsp"/>
							</div>
						</div>
						<div id="right">
							<%@ include file="delete-help.jsp" %>
							<div id="analyze" class="study-right">
								<h2>Analyze</h2>
								<input type="submit" value="Delete selected data"/>
							</div>
							<%@ include file="../data/legend.jsp" %>
						</div>
					</form>
				</c:if>
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
