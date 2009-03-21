<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Resources: Study Guide</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
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
				
<h1>Getting started! Work as a team. Make sure each team member meets these milestones.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<!-- nothing here -->
			</div>
		</td>
		<td>
			<div id="center">
				<p>
					Follow the workflow map below to guide your work. Click on
					the hotspots to get references for accomplishing your
					milestones.
				</p>

				<p>
				
					<img src="../graphics/interaction_point.gif" alt="Interaction
					Point" class="float"/> These dots in your workflow indicate where  your 
					teacher monitors your progress by commenting on the entries
					you make in your logbook related to each milestone.  Be sure
					to read the comments!

				</p>
				
				<%
					if (user.getGroup().isProfDev()) {
						%>
							<%@ include file="milestones-map-profdev.jsp" %>
						<%
					}
					else {
						%>
							<%@ include file="milestones-map-student.jsp" %>
						<%
					}
				%>
			</div>
		</td>
		<td>
			<div id="right">
				<!-- nothing here either -->
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
				<a href="milestones.jsp">Milestones (text version)</a>
				 - 
				<a href="references/showAll.jsp?t=glossary">Glossary</a>
				 - 
				<a href="../references/showAll.jsp?t=reference">All References for Study Guide</a>
				<a href="../references/showAll.jsp?t=reference">
					<img src="../graphics/ref.gif"/>
				</a>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>