<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Library</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>

	<body id="library" class="library">
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
			

<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h2>Use the E-Lab library of resources as you work</h2>
			<ul>
				<li>
					<a href="research-basics.jsp">The Basics</a> - Review research skills that 
					you will need for this project.
				</li>
				<li>
					<a href="milestones-map.jsp">Study Guide</a> - Measure your progress
					as you work.
				</li>
				<li>
					<a href="resources.jsp">Resources</a> - Explore online resources 
					that will help you conduct your E-Lab investigation. A 
					<a href="tutorial.jsp">tutorial</a> will help you learn to use 
					<a href="http://tekoa.ligo-wa.caltech.edu/tla">Bluestone</a>, 
					LIGO's E-Lab data analysis software
				</li>
				<li>
					<a href="big-picture.jsp">Big Picture</a> - Read an overview of 
					this project.
				</li>					
				<li>
					<a href="FAQ.jsp">FAQs</a> - Read the FAQs for answers to your questions.
				</li>
				<li>
					<a href="../site-index">Site Help</a> - Learn how to use the website.
				</li>
			</ul>
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


