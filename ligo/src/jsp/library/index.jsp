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
			<h1>Library: Use the e-Lab library of reference material as you work</h1>
			<ul>
				<li>
					<a href="/library/kiwi.php/Category:LIGO">The Glossary</a> - Look up terms you don't know.
				</li>
				<li>
					<a href="resources.jsp">Resources</a> - Explore online resources 
					that will help you conduct your e-Lab investigation. A 
					<a href="/ligo/tla/tutorial.php">tutorial</a> will help you learn to use 
					<a href="/ligo/tla/">Bluestone</a>, 
					LIGO's e-Lab data analysis software
				</li>
				<li>
					<a href="big-picture.jsp">Big Picture</a> - Read an overview of 
					this project.
				</li>					
				<li>
					<a href="FAQ.jsp">FAQs</a> - Read the FAQs for answers to your questions.
				</li>
				<li>
					<a href="site-tips.jsp">Site Tips</a> - Check out tips on how to use the website.
				</li>
				<li>
				<a HREF="milestones.jsp">Project Milestones (text)</a> - An alternate version.
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


