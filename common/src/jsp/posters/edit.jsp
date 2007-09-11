<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page buffer="none" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Edit Posters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="edit-posters" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-posters.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Click on a poster to edit it.</h1>


<%
	And q = new And();
	q.add(new Equals("type", "poster"));
	q.add(new Equals("project", elab.getName()));
	q.add(new Equals("group", user.getGroup().getName()));

	ResultSet rs = elab.getDataCatalogProvider().runQuery(q);
	request.setAttribute("posters", rs);
%>

<c:choose>
	<c:when test="${empty posters}">
		<h2>No posters found</h2>
	</c:when>
	<c:otherwise>
		<table id="poster-list">
			<tr>
				<th>Poster Title to Edit</th>
				<th>Poster File Name</th>
			</tr>
			<c:forEach items="${posters}" var="poster">
				<tr>
					<td>
						<a href="../posters/new.jsp?posterName=${poster.tupleMap.name}">${poster.tupleMap.title}</a>
					</td>
					<td>
						${poster.tupleMap.name}
					</td>
				</tr>
			</c:forEach>
		</table>		
	</c:otherwise>
</c:choose>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>



