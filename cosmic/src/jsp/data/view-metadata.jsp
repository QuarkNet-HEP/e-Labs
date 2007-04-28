<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Metadata for ${param.filename}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"/>
	</head>
	
	<body id="search-plots" class="data">
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

<table border="0" id="main">
	<tr>
		<td id="center">
			<% 
				String filename = request.getParameter("filename");
				if (filename == null) {
				    throw new ElabJspException("Missing file name.");
				}
				CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
				if (entry == null) {
				    throw new ElabJspException("No metadata about " + filename + " found.");
				}
				request.setAttribute("e", entry);
			%>
			
			<h2>Metadata for ${param.filename}</h2>
			<table border="0">
				<c:forEach items="${e.tupleIterator}" var="tuple">
					<tr>
						<td align="right">${tuple.key}:&nbsp;</td>
						<td align="left">${tuple.value}</td>
					</tr>
				</c:forEach>
			</dl>
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
