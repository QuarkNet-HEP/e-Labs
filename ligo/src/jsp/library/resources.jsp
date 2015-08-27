<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%

	String viewOnly = request.getParameter("options");
	String hideMenu = "no";
	if (viewOnly != null && viewOnly.equals("project")) {
		hideMenu ="yes";
	} else {
		%>
		<%@ include file="../login/login-required.jsp" %>
		<%
	}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Resources</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<STYLE type='text/css'>		
			h3 { /* Begin paragraphs with leading words, (sort of like :first-word ) */
			  display: inline;        /* suppresses line breaks both before and after!  */
			  margin-right: 0.3em;    /* space before text... */
			  font-family: verdana, arial, sans-serif; 
			  font-style: italic;
			  font-size: 85%;
			  color: #0000AA; 
			}
			dl {
			  margin-left: 1em;
			}
			dd
			{
			font-size: 80%;
			}
		</STYLE>		
	</head>
		
	<body id="resources" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<% if (hideMenu.equals("no")) { %>
						<%@ include file="../include/nav-rollover.jspf" %>
					<% } %>							
				</div>
			</div>
			
			<div id="content">
				
				<table border="0" id="main">
					<tr>
						<td id="left">
							<%@ include file="../include/left-alt.jsp" %>
						</td>
						<td id="center">
							<div class='body'>
								<h1>Resources: Check out the online resources or contact someone.</h1>
								<h2>LIGO e-Lab Resources</h2>
								<DL>
								<DT><h3><a href="../home/cool-science.jsp">Cool Science</a> </h3> 
								<DD>Video about LIGO science
								<DT>
									<h3>e-Lab Intro Tutorials: <e:popup href="../video/intro-interface.html" target="tryit" width="800" height="659">Screencast (with Sound)</e:popup> or <e:popup href="intro-tutorial.jsp?slide=-1" target="tryit" width="900" height="659">Screenshots</e:popup></h3>
								<DD> Learn how to get around in the e-Lab, use the project map, milestone references, logbook and more.
								
								<DT><h3>e-Lab Tutorials: <e:popup href="../video/intro-bluestone.html" target="tryit" width="800" height="659">Screencast (with Sound)</e:popup> or <e:popup href="../bluestone/tutorial.jsp" target="tryit" width="900" height="700">Screenshots</e:popup></h3>
								<DD> Learn how to use the e-Lab to plot LIGO seismic data.						
								<DT><h3> <A href="/elab/ligo/maps">LIGO Maps </a></h3> 
								<DD>      Maps that show LIGO Observatories and the location of LIGO seismometers
								<DT><h3> <A href="/elab/ligo/sensors">LIGO Sensors </a>
								      </h3> 
								<DD>      Descriptions of the sensors that produce data for the LIGO e-Lab
								<DT><h3> <A target="_blank" href="http://www.ligo-wa.caltech.edu/">LIGO Hanford</a> and <A target="_blank" href="http://www.ligo-la.caltech.edu/">Livingston</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD>      Use the LIGO Web sites to learn more about LIGO's search for
								      gravitational waves.
								<DT><h3> <A target="_blank" href="http://ilog.ligo-wa.caltech.edu/ilog/">LHO Electronic Log </a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD>      LIGO's E-Log (Hanford and Livingston) can help you connect what you see in the e-Lab data to
								      what's happening at the Observatory. 
								      To view the detector log, use the user name "<i>reader</i>"
									and password "<i>readonly</i>".
								    
								<DT><h3> <A target="_blank" href="http://www.daftlogic.com/projects-advanced-google-maps-distance-calculator.htm">Distance Calculator</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD>      Use this Google tool to calculate distances between locations you are studying.
								
								<DT><h3> <A target="_blank" href="https://owl.english.purdue.edu/owl/resource/747/01/">MLA Formatting and Style Guide</a> 
											& <A target="_blank" href="https://owl.english.purdue.edu/owl/resource/560/01/">APA Formatting and Style Guide</a>
								      </h3> 
								<DD>      Research Citations (Purdue University)  
								</DL>
								<h2>Related Data</h2>
								<DL>
								  
								<DT><h3> <A target="_blank" href="http://earthquake.usgs.gov/">
								      U.S. Geological Survey Earthquakes Site </a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>      Start here to find earthquake lists, maps and other resources
								    
								  
								<DT><h3> <A target="_blank" href="http://earthquake.usgs.gov/earthquakes/search/">Search the USGS Earthquake Archive</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3>
								<DD> Use this search form in case you are looking for an earthquake that is
								      more than 30 days old
								<DT><h3> <A target="_blank" href="http://www.ess.washington.edu/SEIS/PNSN/">Pacific Northwest Seismic Network</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD> Earthquake information that is specific to the pacific Northwest.  Click the
								      "Webicorders" link to see real-time seismographs
								    
								<DT><h3> <A target="_blank" href="http://www.iris.edu/hq/">IRIS Seismology Web Site </a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD> Be sure to look at the Seismic Monitor!
									Check other seismic resources also
									<DT><h3> <A target="_blank"
									    HREF="http://www.wunderground.com/US/WA/Richland.html">
									Weather Underground - Richland, WA</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD> Southeastern Washington weather data
								
								  
								<DT><h3> <A target="_blank"
									    HREF="http://www.ndbc.noaa.gov/">
									 NOAA Buoy Network</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>      Ocean weather, wave heights, wave periods and other data.
									An extensive archive.
								   </DL>
								<h2>Seismic Resources</h2>
								<DL>
								
								<DT><h3> <A target="_blank" href="http://www.pbskids.org/zoom/activities/sci/seismometer.html">Build your own Seismometer</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD> Try PBS's ZOOM activity.
								
								<DT><h3> <A target="_blank" href="http://www.gcse.com/waves/seismometers.htm">How Does a Seismometer Work?</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD> Learn the basics of how a seismometer measures ground vibrations
								
								<DT><h3><A target="_blank" href="http://earthquake.usgs.gov/learn/topics/seismology/keeping_track.php">Seismometers,
								      Seismic Waves and Earthquakes</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD>  Click on the links to find helpful one-page articles
								    
								  
								<DT><h3> <A target="_blank" href="http://www.exploratorium.edu/faultline/basics/waves.html">Earthquake Wave Tutorial</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </h3> 
								<DD>      Learn the basics about earthquake waves
								</DL>
		
								<h2>Contacts</h2>
								<dl>
									<dt>
										<a href="mailto:ingram_d@ligo-wa.caltech.edu">Dale Ingram</a> - Education and Outreach Coordinator, LIGO Hanford Observatory
									<dd> Ask Dale questions about using the e-Lab in your classroom.
									<dt>
										<% if (hideMenu.equals("no")) { %>

											<a href="students.jsp">Student Research Groups</a> - in the LIGO e-Lab
											<dd> Find other research groups working in the e-Lab.
										<% } %>
								   
								 </DL>
								<h2>IT Careers</h2>
								<DL>
								<DT><h3> <A target="_blank" href="http://nde.ne.gov/NCE/careerclusters/ITCC%20BRO.pdf">Career Cluster Pamphlet</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD> Read a pamphlet from Vocational Information Center's <A href="http://www.khake.com/page17.html">Computer Science Career Guide</a>
								<DT><h3> <A target="_blank" href="http://www.microsoft.com/learning/training/careers/prepare.mspx">Prepare for an Information Technology (IT) Career</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD> Read Microsoft Learning's suggestions for preparing for an IT Career.
								
								</DL>
								<h2>Grid Computing</h2>
								<p style="font-size: 80%">LIGO has its own computing grid called LDG, which consists of all the
								LSC computer clusters used for storing data and performing analyses. LDG stands for "LSC Data Grid" or "LIGO Data Grid". View the
								LDG home page and learn more about grids - a form of distributed computing.</p>
								<DL>
								<DT><h3> <A target="_blank" href="https://www.lsc-group.phys.uwm.edu/lscdatagrid/">LDG home page</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>View the home page for LIGO's grid.
								
								<DT><h3> <A target="_blank" href="http://www.gridcafe.org">The Grid Cafe</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>Enjoy CERN's multimedia introduction to grid computing.
								
								<DT><h3> <A target="_blank" href="http://www.gridtalk.org/">Grid Talk</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>Read <a href="http://www.gridtalk.org/briefings.htm">Grid Briefings</a> and explore the <a href="http://www.gridguide.org/">Grid Guide</a>, from CERN.
								
								<DT><h3> <A target="_blank" href="http://www.tryscience.org/grid/home.html" target="activity">Grids for Kids at TryScience</a>
									<img src='/glossary/skins/monobook/external.png'>
								      </H3> 
								<DD>Use grid computing to model Mt. Vesuvius' volcanic activity and discover whether residents need warning, from New York Museum of Science.
								
								
								<DT><h3> <a href="http://www.wikipedia.org/wiki/Grid_computing"> 
														Grid computing </a><img src='/glossary/skins/monobook/external.png'></h3>
								<DD>Read the article from Wikipedia.
								</DL>
								<font size='-1'>
								Links with the 
								<img src='/glossary/skins/monobook/external.png'>
								symbol take you to another web site, and will open up in another browser 
								window.
								</font>
							</div>
						</td>
					</tr>
				</table>
			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
