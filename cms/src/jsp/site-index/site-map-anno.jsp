<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
			<c:if test="${param.display != 'static'}">
			<!-- display set to "static" allows showing a site overview without a real menu -->
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
			</c:if>
			
			<div id="content">
			
<h1>Find out what you can do under each tab.</h1>



<table border="0">
	<tr>
		<td valign="top">
			<div id="left">
				<div class="tab tabHome">
					<span class="tabtitleHome"><a HREF="../home/">Home</a></span>
					<div class="tabcontentsHome">
					 	<h2>Homepage</h2>
						<ul>
							<li>Research topic.</li>
						</ul>
					</div>
				</div>
				
				<div class="tab tabLibrary">
					<span class="tabtitleLibrary"><A HREF="../library/">Library</a></span>
					<div class="tabcontentsLibrary">
						<h2>Look for links</h2>
						<ul>
							<li>Online Resources - If you find a really good resource not listed, let us know</li>
							<li>Physicists - Contacts at CMS</li>
							<li>Student Research Groups - Other studies in the field</li>
							<li>Tutorials - Practice new skills</li>
							<li>Animations - How the CMS project works</li>
						</ul>
					</div>
				</div>
				
				<div class="tab tabAssess">
					<span class="tabtitleAssess"><A HREF="../assessment/">Assessment</a></span>
					<div class="tabcontentsAssess">
						<h2>Assess your work</h2>
						<ul>
							<li>Rubric</li>
						</ul>
					</div>
				</div>

         </div>
         </td>
         <td valign="top">
			<div id="right">
					
				<div class="tab tabData">
					<span class="tabtitleData"><A HREF="../data/">Data</a></span>
					<div class="tabcontentsData" style="background-color: #99CCff;">
						<h2>Analyze and Manage Data</h2>
						<ul>
							<li>Physics studies</li>
							<li>View and delete files</li>
							<li>Get data to analyze</li>
							<li>Practice skills</li>
						</ul>
					</div>
				</div>

				<div class="tab tabPoster">
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
         </td></tr>
 

		<c:if test="${param.display == 'static'}">
  			<tr>
  				<td colspan="2" align="center">
  					<A HREF="javascript:window.close();">Close Window and Go Back to Getting Started Page</A>
  				</td>
  			</tr>
		</c:if>
		
     </table>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
