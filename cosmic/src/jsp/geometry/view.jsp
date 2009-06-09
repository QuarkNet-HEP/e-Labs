<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ page import="java.util.*" %>

<%@ include file="init.jspf" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Geometry</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/geo.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-geometry" class="data geo">
		<!-- entire page container -->
		<div id="container">
			<c:if test="${param.menu != 'no'}">
				<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			</c:if>
			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="center">
			<c:if test="${geometryNotFound}">
				<e:error message="No geometry found for detector ${param.detectorID} on date ${param.jd}"/>
			</c:if>
			
			<c:if test="${param.filename != null}">
				<center>
					<a href="../data/view.jsp?filename=${param.filename}">Show Data</a> |
					<a href="../data/view-metadata.jsp?filename=${param.filename}">Show Metadata</a>
				</center>
			</c:if>
			
			<div id="viewer">
				<div class="title">
					<a href="javascript:glossary('geometry')">Geometry</a> for ${param.filename == null ? param.id : param.filename}
					<c:if test="${param.filename == null}">
						<fmt:formatDate pattern="MMM/dd/yy @ HH:mm" value="${g.date}"/> 
						<a href="javascript:glossary('UTC')">UTC</a>
					</c:if>
				</div>
				<c:set var="ro" value="true"/>
				<%@ include file="editor.jspf" %>
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
