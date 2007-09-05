<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Site Overview</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/site-index.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	<body class="siteindex">
		<!-- entire page container -->
		<div id="container">
<%
// display set to "static" allows showing a site overview without a real menu
String display = request.getParameter("display");
if(display == null || !display.equals("static")) {
	%>
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-site-index.jsp" %>
						</div>
					</div>
				</div>
			</div>

	<%
}
%>
<div id="content">
<h1>Find out what you can do under each tab.</h1>



<table border="0">
	<tr>
		<td valign="top">
			<div id="left">
				<div class="tab">
					<span class="tabtitleHome"><a HREF="../home/">Home</a></span>
					<div class="tabcontentsHome">
					 	<h2>Homepage</h2>
						<ul>
							<li>Research topic.</li>
						</ul>
					</div>
				</div>
					

				<div class="tab">
					<span class="tabtitleUpload"><A HREF="../data/upload.jsp">Upload</a></span>
					<div class="tabcontentsUpload">
						<h2>Upload</h2>
						<ul>
							<li>Data</li>
							<li>Geometry</li>
						</ul>
					</div>
				</div>

				<div class="tab">
					<span class="tabtitlePoster"><A HREF="../posters/">Posters</a></span>
					<div class="tabcontentsPoster">
						<h2>Share Your Research</h2>
						<ul>
							<li>Create a Poster - Post results including graphs, notes, calculations.</li>
							<li>Edit a Poster</li>
							<li>View Posters - Review the work of others.</li>
							<li>Search for Studies - Participate in a scientific dialog.</li>
						</ul>
					</div>
				</div>
         </div>
         </td>
         <td valign="top">
			<div id="right">
				<div class="tab">
					<span class="tabtitleLibrary"><A HREF="../library/">Library</a></span>
					<div class="tabcontentsLibrary" style="background-color: #ccffff;">
						<h2>Use Online Library</h2>
						<ul>
							<li>Review Research Basics</li>
							<li>Use Study Guide with Milestones and References</li>
							<li>Online Resources: Physicists, Research Groups, Tutorials, Animations</LI>
							<li>The Big Picture</LI>
							<li>FAQs</LI>
							<li>Site Help</LI>
						</ul>
					</div>
				</div>
					
				<div class="tab">
					<span class="tabtitleData"><A HREF="../data/">Data</a></span>
					<div class="tabcontentsData" style="background-color: #99CCff;">
						<h2>Analyze and Manage Data</h2>
						<ul>
							<li>Analysis - Physics studies.</li>
							<li> Management - View and delete files.</LI>
						</ul>
					</div>
				</div>
					
				<div class="tab">
					<span class="tabtitleAssess"><A HREF="../assessment/">Assessment</a></span>
					<div class="tabcontentsAssess">
						<h2>Assess your work</h2>
						<ul>
							<li>Rubric</li>
						</ul>
					</div>
				</div>
         </div>
         </td></tr>
 

<% if(display != null && display.equals("static")){
%>
  <tr><td colspan="2" align="center"><A HREF="javascript:window.close();">Close Window and Go Back to Getting Started Page</A></td></tr>
<% 
}
%>

     </table>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
