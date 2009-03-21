<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Resources: Study Guide</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="milestones-map" class="library">
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
				
<%
	if (user.isProfDev()) {
		%>
			<%@ include file="milestones-profdev.jsp" %>
		<%
	}
	else {
		%>
			<%@ include file="milestones-student.jsp" %>
		<%
	}
%>

			</div>
			<!-- end content -->	
		
			<div id="footer">
				<a href="../references/showAll.jsp?t=glossary">Glossary</a> - 
				<a href="../references/showAll.jsp?t=reference">All References for Study Guide</a>
				<a href="../references/showAll.jsp?t=reference">
					<img src="../graphics/ref.gif">
				</a>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

