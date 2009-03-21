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
					<a href="../library/milestones-map.jsp">Study Guide</a>
					<ul>
						<li><a href="../jsp/showReferences.jsp?t=reference&amp;f=peruse">View Resources for Study Guide</a></li>
						<li><a href="../jsp/showReferences.jsp?t=glossary&amp;f=peruse">View Glossary</a></li>
					</ul>
				</li>
				<li><a href="../library/resources.jsp">Resources</a></li>
				<li>
					Online Links
					<ul>
						<li>
							Tutorials
							<ul>
								<li><a href="ogre_tutorial_index.htm">Ogre Tutorial</a></li>
								<li><a href="http://www-root.fnal.gov/root/">Root Tutoria</a></li>
							</ul>
						</li>
						<li>
							Notes
						</li>
						<li>
							Contacts
						</li>
						<li>
							Slide Shows
						</li>
					</ul>
				</li>
				<li>
					<a href="first.jsp">Big Picture</a>
				</li>
				<li>
					<a href="site-map-anno.jsp">CMS Overview</a>
				</li>
				<li>
					<a href="http://cmsinfo.cern.ch/Welcome.html">CMS Test Beam</a>
				</li>
				<li>
					<a href="first_web.jsp">Site Help</a>
				</li>
				<li>
					<a href="FAQ.jsp">FAQ</a>
				</li>
			</ul>
		</td>
		<td>
			<ul>
				<li>
					<a href="search.jsp">Test Beam Analysis</a>
					<ul>
         				<li><a href="ogre-base.jsp?analysis=shower_depth">Shower Depth</a></li>
						<li><a href="ogre-base.jsp?analysis=shower_depth?analysis=lateral_size">Lateral Size</a></li>         
						<li><a href="ogre-base.jsp?analysis=beam_purity">Beam Purity</a></li>
						<li><a href="ogre-base.jsp?analysis=resolution">Resolution</a></li>
					</ul>
				</li>
				<li>
					<a href="search.jsp">Management</a>
					<ul>
            			<li>View Files and Posters</li>
						<li>Delete Files and Posters</li>
					</ul>
				</li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="../posters/new.jsp">New Poster</a></li>
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
