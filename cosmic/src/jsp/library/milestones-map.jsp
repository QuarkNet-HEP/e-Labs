<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Resources: Project Milestones</title>
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
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Work as a team. Make sure each team member contributes.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<!-- nothing here -->
			</div>
		</td>
		<td>
			<div id="center">
				<div style="text-align:center; font-size: 16px; font-weight:bold">Study Guide</div>
				<p>Your team may use this study guide, or your teacher may have other plans. Make sure you know how to record your progress, keep your teacher appraised of your work and publish your results. 
				</p>
				<%@ include file="milestones-map-student.jsp" %>
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
				<a href="milestones.jsp">Study Guide (text version)</a>
				 - 
				<a href="../references/showAll.jsp?t=glossary">Glossary</a>
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