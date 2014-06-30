<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Ligo Resources: Study Guide</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/elab-custom.js"></script>
	</head>
	
	<body id="milestones-map" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h1>Getting started! Make sure you meet each of these milestones below.</h1>
			<p>
				 Now you're ready to begin.  Follow the workflow list below to guide your work. Go through the e-Lab tasks one at a time. Use the <a href="../home/index.jsp">Project Map</a> if you prefer.
			</p>
			<p><b>Click on <img border="0" src="../graphics/ref.gif" /> for
	  	references to help you meet each <a href="#" onclick="javascript:glossary('Milestone',250);return false;"><b>milestone</b></a>.</p>
<!--
			<center>
-->
				<c:choose>
					<c:when test="${user.group.profDev}">
						<%@ include file="milestones-profdev.jsp" %>
					</c:when>
					<c:otherwise>
						<%@ include file="milestones-student.jsp" %>
					</c:otherwise>
				</c:choose>
<!--
				<div class="link-list">
					<a href="../home/index.jsp">Project Map: Milestones (map version)</a>
				</div>
			</center>
-->
			
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>	
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

