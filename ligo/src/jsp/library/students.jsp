<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Resources</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
		
	<body id="resources" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Collaborate with other students. Search for studies like yours.</h1>

	<c:choose>
		<c:when test="${user.guest}">
			<font size="3" color="red">To ensure the privacy of our users, guests may not access this page. 
            Please <a href="../login/login.jsp">log in</a> as a non-guest to access this page.</font>
		</c:when>
		<c:otherwise>
			<table cellpadding="10" cellspacing="10" border="1" align="center">
				<tr>
					<td align="center"><font size="-1"><b><u>Teacher</u></b></font></td>
					<td align="center"><font size="-1"><b><u>School</u></b></font></td>
					<td align="center"><font size="-1"><b><u>Town</u></b></font></td>
					<td align="center"><font size="-1"><b><u>State</u></b></font></td>
					<td align="center"><font size="-1"><b><u>Groups</u></b></font></td>
				</tr>
				<c:forEach items="${elab.userManagementProvider.teachers}" var="teacher">
					<%
						ElabGroup teacher = (ElabGroup) pageContext.getAttribute("teacher");
						String email = teacher.getEmail();
						if (email != null) {
							email = email.replaceAll("@", " <-at-> ").replaceAll("\\.", "  d.o.t  ");
						}
						pageContext.setAttribute("email", email);
					%>
					<tr>
						<td>
							<c:choose>
								<c:when test="${email != null}">
									<a href="mailto:${email}">${teacher.name}</a>
								</c:when>
								<c:otherwise>
									${teacher.name}
								</c:otherwise>
							</c:choose>
						</td>
						<td>${teacher.group.school}</td>
						<td>${teacher.group.city}</td>
						<td>${teacher.group.state}</td>
						<td>
							<c:forEach items="${teacher.groups}" var="group">
								${group.name}<br/>
							</c:forEach>
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



