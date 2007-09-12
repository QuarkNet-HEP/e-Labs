<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Show Teachers for Test Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="show-teachers">
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
<h1>Teachers whose students took tests</h1>
<table>
	<tr>
		<th>Teacher</th>
		<th></th>
		<th></th>
	</tr>
	<c:forEach items="${elab.userManagementProvider.teachers}" var="teacher">
    	<tr>
    		<td>
    			${teacher.name}
    		</td>
			<td>
				<a href="../test/results-for-teacher.jsp?id=${teacher.id}&type=presurvey">Pre-test Results</a>
			</td>
			<td>
				<a href="../test/results-for-teacher.jsp?id=${teacher.id}&type=postsurvey">Post-test Results</a>
			</td>
		</tr>
	</c:forEach>
</table>

			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>