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
			
			
			
<h1>Use the library as you work.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">					
				<div class="tab">
					<span class="tab-title">Library</span>
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<a HREF="research-basics.jsp">The Basics</a> - 
								Review research skills you need for this project. 
							</li>
							<li>
								<a HREF="milestones-map.jsp">Study Guide</a> - 
								Measure your progress as you work. 
							</li>
							<li>
								<a HREF="resources.jsp">Resources</a> - 
								Explore Tutorials, Online Resources, Animations and Contacts. 
								The tutorials should help you use this website. The contacts 
								will allow you to contact other student research groups. 
								The animations demonstrate your hardware and what happens 
								when you are uploading data and using grid techniques. The 
								Online Resources will broaden your understanding of particle
								physics	and research.
							</li>
							<li>
								<a HREF="../home/first.jsp">Big Picture</a> - 
								Read an overview of this project and view a sample poster. 
							</li>
							<li>
								<a href="http://cmsinfo.cern.ch/Welcome.html">CMS Overview</a> - 
								Educational Outreach  of the Compact Muon Solenoid Collaboration.
							</li>
							<li>
								<a href="http://www.uscms.org/scpac/Detector/HCAL/tb2004/rcr/">CMS Test Beam Overview</a> - 
								Explanation and description of Compact Muon Solenoid Collaboration&rsquo;s 
								Test Beam effort.
							</li>
							<li>
								<a HREF="FAQ.jsp">FAQs</a> - Read the FAQs for answers to 
								your questions. 
							</li>
							<li>
								<a HREF="../home/first-web.jsp">Site Help</a> - Learn how 
								to use the website.
							</li>
						</ul>
					</div>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
				<img src="../graphics/five_pic_collage.jpg">
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
	</body>
</html>


