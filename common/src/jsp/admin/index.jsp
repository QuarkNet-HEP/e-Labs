<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Administration Tasks</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="administration" class="teacher">
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
				<table id="main" cellpadding="10" cellspacing="10">
					<tr><th colspan="2" >Admin Links</th><th></th></tr>
					<tr>
						<td>&#8226; <a href="../statistics">e-Lab Statistics</a></td>
						<td>View ${elab.name} e-Lab statistics.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../posters/poster-tags.jsp">Poster Tags</a></td>
						<td>Add, delete, update poster tags per e-Lab.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../references/control.jsp">References</a></td>
						<td></td>					
					</tr>
					<c:if test='${elab.name == "cosmic" }'>
						<tr>
							<td>&#8226; <a href="../analysis/list-all.jsp">All Analyses</a></td>
							<td>List of analyses by all users.</td>
						</tr>
						<tr>
							<td>&#8226; <a href="data-access-permission.jsp">Allow users to view all data</a></td>
							<td>Give rights to teachers to be able to access all cosmic data (blessed and unblessed).</td>						
						</tr>
					</c:if>				
				</table>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>