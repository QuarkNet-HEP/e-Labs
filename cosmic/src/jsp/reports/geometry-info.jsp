<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="jxl.*" %>
<%@ page import="jxl.write.*" %>
<%@ page import="java.io.File" %>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<title>Geometry Report.</title>
			<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
			<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
			<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
			<script type="text/javascript" src="../include/elab.js"></script>
			<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.12.1.custom.css" rel="Stylesheet" />	
			<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
			<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.12.1.custom.min.js"></script>
			<script type="text/javascript" src="../include/jquery/js/jquery.event.hover-1.0.js"></script>
			</head>
		
		<body id="geometry-report" class="teacher">
			<!-- entire page container -->
			<div id="container">
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
						<div id="nav">
							<%@ include file="../include/nav-teacher.jsp" %>
						</div>
					</div>
				</div>
				
				<div id="content">
				<form id="geometryReport" method="post">
				    <h2>View splits and their geometries.</h2>
				    <ul>
				    	<li>Click on Retrieve Report to get the list of uploaded files with a geometry mismatch.</li>
				    </ul>
					<table>
						<tr>	
							<td><div style="text-align: center;">				
									<jsp:include page="search-control-geometry.jsp"/>
								</div>
							</td>		
							</td>
						</tr>
					</table>
				</form>
				<table>
					<c:choose>
						<c:when test="${not empty results }">
							<c:forEach items="${results }" var="result">
								<tr><td>${result.key }: ${result.value} </td></tr>
							</c:forEach>
						</c:when>
						<c:otherwise>
							<c:choose>
								<c:when test="${not empty searchResults }">
									<tr><td>Geometries match for this result set.</td></tr>
								</c:when>
							</c:choose>
						</c:otherwise>
					</c:choose>
				</table>
				</div>
				<!-- end content -->	
			
				<div id="footer">
				</div>
			</div>
			<!-- end container -->
		</body>
	</html>	