<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Resources: Study Guide</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/library.css") %>
		<%= elab.css(request, "css/two-column.css") %>
	</head>
		
	<body id="milestones_map" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="include/header.jsp" %>
					<div id="nav">
						<%@ include file="include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="include/nav_library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Review research skills you need for this project.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="center">
				<h2>Click on <img border="0" src="graphics/ref.gif"/> for resources to help you meet each milestone below.</h2>
					
				<div class="tab">
					<span class="tabtitle">Research Basics</span>
					<div class="tabcontents">
						<h2>Use these milestones if you need background on:</h2>
						<ul>
							<li>Simple Measurements. <%= elab.reference("simple measurement") %></li>
							<li>Simple Calculations. <%= elab.reference("simple calculations") %></li>
							<li>Simple Graphs. <%= elab.reference("simple graphs") %></li>
							<li>Research Questions. <%= elab.reference("research question") %></li>
							<li>Research Plans.. <%= elab.reference("research plan") %></li>
						</ul>
					</div>
				</div>
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
				<a href="showReferences.jsp?t=glossary&f=peruse">Glossary</a>
				 - 
				<a href="showReferences.jsp?t=reference&f=peruse">All Resources for Study Guide</a>
				<a href="showReferences.jsp?t=reference&f=peruse">
					<img src="graphics/ref.gif"/>
				</a>
				 - 
				<a href="showLogbook.jsp">Student Logbook</a>
				<a href="showLogbook.jsp">
					<img src="graphics/logbook_small.gif"/>
				</a>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
