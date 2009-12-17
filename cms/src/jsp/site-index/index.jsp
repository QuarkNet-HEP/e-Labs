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
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>

			<div id="content">

				<h1>Site Index: Lost? You can go to any of the pages <i>on this site</i> from this list.</h1>
				<table border="0" id="main">
					<tr>
						<th class="home"><a href="../home">Home</a></th>
						<th class="library"><a href="../library">Library</a></th>
						<th class="data"><a href="../data">Data</a></th>
						<th class="posters"><a href="../posters">Posters</a></th>
						<th class="assessments"><a href="../assessment">Assessment</a></th>
					</tr>
					<tr>
						<td class="home">
							<ul>
								<li><a href="../home/cool-science.jsp"><b>Cool Science</b></a></li>
								<li><a href="../site-index/site-map-anno.jsp"><b>Explore!</b></a></li>
								<li><a href="../home/about-us.jsp"><b>About Us</b></a></li>
								
							</ul>
						</td>
			<td class="library">
			<ul>
								<li><a href="/library/kiwi.php/CMS_Glossary" target="glossary"><b>Glossary</b></a></li>
								<li><a href="../library/resources.jsp"><b>Resources</b></a></li>
								<li>
									<ul>
					<li><b>Online Links</b>
					<ul>
									<li><a href="http://cmsinfo.cern.ch/">CMS Experiment</a></li></ul>
						<li><b>Tutorials/Background</b>
							<ul>
<!-- 
								<li><a href="../analysis-shower-depth/background.jsp">Shower Depth</a></li>
								<li><a href="../analysis-lateral-size/background.jsp">Lateral Size</a></li>         
								<li><a href="../analysis-beam-purity/background.jsp">Beam Purity</a></li>
								<li><a href="../analysis-resolution/background.jsp">Resolution</a></li>
-->									
                <li><b>Advanced:</b> <a href="http://www-root.fnal.gov/root/">Root Tutorial</a></li>
					</ul>
	
						</li>
						<li>
							Notes
						</li>
						<li>
							Slide Shows
						</li>
															<li>
											<b>Contacts</b>
											<ul>
												<li><a href="../library/students.jsp">Students</a></li>
											</ul>
										</li>

					</ul>
				</li>
				<li>
					<a href="../library/big-picture.jsp">Big Picture</a>
				</li>
				<li>
					<a href="../library/FAQ.jsp">FAQ</a>
				</li>
				<li>
					<a href="../library/site-tips.jsp">Site Tips</a>
				</li>
				<li>Milestones - <a href="../library/milestones.jsp">text version</a></li>

			</ul>
		</td>
		<td class="data" >
			<ul>
				<li>
					<a href="../data/">Data Analysis</a>
					<ul>
	         <li><a href="${elab.properties['ogre']}" target="ogre">OGRE</a></li>
<!-- 
					<li><a href="../analysis-lateral-size/">Lateral Size</a></li>         
						<li><a href="../analysis-beam-purity/">Beam Purity</a></li>
						<li><a href="../analysis-resolution/">Resolution</a></li>
-->
					</ul>
 				</li>
				<li><b><a href="../plots/search.jsp">View Plots</a></b></li>
					<li><b><a href="../plots/delete.jsp">Delete Plots</a></b>
					</li>
			</ul>
		</td>
						<td class="posters">
							<ul>
								<li><a href="../posters/new.jsp"><b>New Poster</b></a></li>
								<li><a href="../posters/edit.jsp"><b>Edit Posters</b></a></li>
								<li><a href="../posters/search.jsp"><b>View Posters</b></a></li>
								<li><a href="../posters/delete.jsp"><b>Delete Posters</b></a></li>
								<li><a href="../plots/my-plots.jsp"><b>View My Plots</b></a></li>
								<li><a href="../jsp/uploadImage.jsp"><b>Upload Images</b></a></li>
							</ul>
						</td>
						<td class="assessments">
							&nbsp; 
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
