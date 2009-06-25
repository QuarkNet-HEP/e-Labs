<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


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
						<c:if test="${user.upload}">
							<th class="upload"><a href="../data/upload.jsp">Upload</a></th>
						</c:if>
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
								<li><a href="../references/showAll.jsp?t=glossary"><b>Glossary</b></a></li>
								<li><a href="../library/resources.jsp"><b>Resources</b></a></li>
								<li>
									<ul>
										<li>
											<b>Contacts</b>
											<ul>
												<li><a href="../library/students.jsp">Students</a></li>
											</ul>
										</li>
										<li>
											<b>Tutorials</b>
											<ul>
												<li>
													<ul>
														<li>
															Performance Study
															<ul><li><a href="../analysis-performance/tutorial.jsp">Tutorial</a> &amp;
																	<a href="../analysis-performance/tryit.html">Step-by-Step Instructions</a></li>
															</ul>
														</li>
														<li>
															Shower
															<ul>
																<li><a href="../analysis-shower/tutorial.jsp">Tutorial</a> &amp;
																<a href="../analysis-shower/tryit.html">Step-by-Step Instructions</a></li>
															</ul>
														</li>
														<li>
															Flux Study
															<ul>
																<li><a href="../analysis-flux/tutorial.jsp">Tutorial</a> &amp;
																<a href="../analysis-flux/tryit.html">Step-by-Step Instructions</a></li>
															</ul>
														</li>
														<li>
															Lifetime Study
															<ul>
																<li><a href="../analysis-lifetime/tutorial.jsp">Tutorial</a> &amp;
																<a href="../analysis-lifetime/tryit.html">Step-by-Step Instructions</a></li>
															</ul>
														</li>
														<li><a href="../jsp/geoInstructions.jsp">Updating Geometry Tutorial</a></li>	
													</ul>
												</li>
												<li>
													<b>Animations</b>
													<ul>
														<li><a href="../flash/daq_only_standalone.html" >Classroom Cosmic Ray Detector</a></li>
														<li><a href="../flash/daq_portal_rays.html" >Sending Data to Grid</a></li>
														<li><a href="../flash/analysis.html" >Analysis</a></li>
														<li><a href="../flash/collaboration.html" >Collaboration</a></li>
														
														<li><a href="../flash/griphyn-animate_sc2003.html" >Exploring Virtual Data</a></li>
														<li><a href="../flash/DAQII.html" >Data Acquisition Card</a></li>
													</ul>
												</li>
											</ul>
										</li>
									</ul>
								</li>
								<li><a href="../library/big-picture.jsp"><b>The Big Picture</b></a></li>
								<li><a href="../library/FAQ.jsp"><b>FAQs</b></a></li>
								<li><a href="../library/site-help.jsp"><b>Site Tips</b></a></li>
								<li>Milestones - <a href="../library/milestones.jsp">text version</a></li>
								<%-- <li><a href="../references/showAll.jsp?t=reference">All References for Project Map</a></li> --%>
							</ul>
						</td>
						<c:if test="${user.upload}">
							<td class="upload">
								<ul>
									<li><a href="../data/upload.jsp"><b>Upload Data</b></a></li>
									<li><a href="../geometry/"><b>Upload Geometry</b></a></li>
									
								</ul>
							</td>
						</c:if>
						<td class="data">
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
									</ul>
								</li>
								<li>
									<strong>Delete</strong>
									<ul>
										<li><a href="../data/delete.jsp">Data Files</a></li>
										<li><a href="../plots/delete.jsp">Plots</a></li>
									</ul>
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
								<li><a href="../jsp/uploadimages.jsp"><b>Upload Images</b></a></li>
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
