<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<HTML>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Library</title>
		<%= elab.css(request, "css/style2.css") %>
		<%= elab.css(request, "css/library.css") %>
		<%= elab.css(request, "css/two-column.css") %>
	</head>

	<body id="resources" class="library">
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
			
			
			
<h1>Use the library as you work.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
					
				<div class="tab">
					<span class="tabtitle">Library</span>
					<div class="tabcontents">
						<ul class="simple">
							<li>
							<A HREF="research_basics.jsp">The Basics</A> - Review research skills you need for this project. 
							</li>
							<li>
							<A HREF="milestones_map.jsp">Study Guide</A> - Measure your progress as you work. 
							</li>
							<li>
							<A HREF="resources.jsp">Resources</A> - Explore Tutorials, Online Resources, Animations and Contacts.  The tutorials should help you use this website. The contacts will allow you to contact other student research groups.  The animations demonstrate your hardware and what happens when you are uploading data and using grid techniques. The Online Resources will broaden your understanding of cosmic rays and research. 
							</li>
							<li>
							<A HREF="first.jsp">Big Picture</A> - Read an overview of this project and view a sample poster. 
							</li>
							<li>
							<A HREF="FAQ.jsp">FAQs</A> - Read the FAQs for answers to your questions. 
							</li>
							<li>
							<A HREF="first_web.jsp">Site Help</A> - Learn how to use the website.
							</li>
						</ul>
					</div>
				</div>

			</div>
		</td>
		<td>
			<div id="right">

<IMG SRC="graphics/reference_montage.gif">

			</div>
		</td>
	</tr>
</table>
</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->


</BODY>
</HTML>


