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
					<%@ include file="../include/nav-rollover.jspf" %>
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
							<a HREF=/library/kiwi.php/Category:CMS">Glossary</a> - Look up terms you don't know. 
							</li>
							<li>
							<a HREF="resources.jsp">Resources</a> - Explore <i>Online Resources, Tutorials, Contacts</i> and <i>Slide Shows</i>.  
							Tutorials help you analyze the data. Contacts connect you to experts and other student research groups.  Slideshows give more background. <i>Online Resources</i> broaden your understanding of particle physics, the detector and the collider. 
							</li>
							<li>
							<a HREF="big-picture.jsp">Big Picture</a> - Read a project overview and view a sample poster. 
							</li>
							<li>
							<a HREF="FAQ.jsp">FAQs</a> - Find answers for frequently asked questions. 
							</li>
							<li>
							<a HREF="site-help.jsp">Site Tips</a> - Check out tips for using the website.
							</li>
							<li>
							<a HREF="milestones.jsp">Project Milestones (text)</a> - An alternate version.
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


