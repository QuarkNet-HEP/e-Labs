<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Site Index</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/site-index.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
		
	<body id="site-index" class="siteindex">
		<!-- entire page container -->
		<div id="container">
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

			<div id="content">

<h1>Lost? You can go to any of the pages on this site from this list.</h1>


<table border="0" id="main">
	<tr>
		<th><a href="../home">Home</a></th>
		<th><a href="../library">Library</a></th>
		<th><a href="../data/upload.jsp">Upload</a></th>
		<th><a href="../data">Data</a></th>
		<th><a href="../posters">Posters</a></th>
		<th><a href="../assessment">Assessment</a></th>
	</tr>
	<tr>
		<td>
			<ul>
				<li><a href="../home/first.jsp">The Big Picture</a></li>
				<li><a href="../home/first-web.jsp">The Website</a></li>
			</ul>
		</td>
		<td>
			<ul>
				<li>
					<a href="../library/milestones_map.jsp">Study Guide</a> and 
					<a href="../library/milestones.jsp"><strong>text version</strong></a>
					<ul>
						<li><a href="../jsp/showReferences.jsp?t=reference&amp;f=peruse">View Resources for Study Guide</a></li>
						<li><a href="../jsp/showReferences.jsp?t=glossary&amp;f=peruse">View Glossary</a></li>
					</ul>
				</li>
				<li><a href="resources.jsp" >Resources</a></li>
				<li>
					Online Links
					<ul>
						<li>
							Contacts
							<ul>
								<li><a href="../library/students.jsp">Students</a></li>
							</ul>
						</li>
						<li>
							Tutorials
							<ul>
								<li><a href="../analysis-performance/tutorial.jsp">Performance Study Background</a></li>
								<li><a href="../analysis-performance/tryit.html">Step-by-Step Instructions: Performance</a></li>
								<li><a href="../analysis-lifetime/tutorial.jsp">Lifetime Study Background</a></li>
								<li><a href="../analysis-lifetime/tryit.html">Step-by-Step Instructions: Lifetime</a></li>
								<li><a href="../analysis-flux/tutorial.jsp">Flux Study Background</a></li>
								<li><a href="../analysis-flux/tryit.html">Step-by-Step Instructions: Flux</a></li>
								<li><a href="../analysis-shower/tutorial.jsp">Shower Study Tutorial</a></li>
								<li><a href="../analysis-shower/tryit.html">Step-by-Step Instructions: Shower</a></li>
								<li><a href="../library/geoInstructions.jsp">Updating Geometry Tutorial</a></li>
							</ul>
						</li>
						<li>
							Animations
							<ul>
								<li><a href="../flash/daq_only_standalone.html" >Classroom Cosmic Ray Detector</a></li>
								<li><a href="../flash/daq_portal_rays.html" >Sending Data to Grid Portal</a></li>
								<li><a href="../flash/analysis.html" >Analysis</a></li>
								<li><a href="../flash/collaboration.html" >Collaboration</a></li>
								<li><a href="../flash/SC2003.html" >Loop</a></li>
								<li><a href="../flash/griphyn-animate_sc2003.html" >CMS vs. QuarkNet</a></li>
								<li><a href="../flash/DAQII.html" >DAQII</a></li>
							</ul>
						</li>
					</ul>
				</li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="../data/upload.jsp">Upload Data</a></li>
				<li><a href="../jsp/geo.jsp">Upload Geometry</a></li>
			</ul>
		</td>
		<td>
			<ul>
				<li>
					<strong>Analysis</strong>
					<ul>
						<li><a href="../analysis-performance">Performance Study</a></li>
						<li><a href="../analysis-lifetime">Lifetime Study</a></li>
						<li><a href="../analysis-flux">Flux Study</a></li>
						<li><a href="../analysis-shower">Shower  Study</a></li>
					</ul>
				</li>
				<li>
					<strong>View</strong>
					<ul>
						<li><a href="../data/search.jsp">Data Files</a></li>
						<li><a href="../plots/search.jsp">Plots</a></li>
						<li><a href="../posters/search.jsp">Posters</a></li>
					</ul>
				</li>
				<li>
					<strong>Delete</strong>
					<ul>
						<li><a href="../data/delete.jsp">Data Files</a></li>
						<li><a href="../plots/delete.jsp">Plots</a></li>
						<li><a href="../posters/delete.jsp">Posters</a></li>
					</ul>
				</li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="..posters/new.jsp">New Poster</a></li>
				<li><a href="../posters/edit.jsp">Edit Posters</a></li>
				<li><a href="../posters/search.jsp">View Posters</a></li>
				<li><a href="../posters/delete.jsp">Delete Posters</a></li>
				<li><a href="../plots/my-plots.jsp">View My Plots</a>
			</ul>
		</td>
		<td>
		</td>
	</tr>
</table>


			</div>
<!-- end content -->	

			<div id="footer"> </div>
		</div>
		<!-- end container -->
</body>
</html>
