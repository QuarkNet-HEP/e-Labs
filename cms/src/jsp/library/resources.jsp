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
	</head>
		
	<body id="resources" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<% if (hideMenu.equals("no")) { %>
						<div id="nav">
							<%@ include file="../include/nav-rollover.jspf" %>
						</div>					
					<% } %>					
				</div>
			</div>
			
			<div id="content">
				
<h1>Looking for information? Check out the online resources or contact someone.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
					

				<div class="tab" id="tab-online">
					<span class="tab-title">e-Lab Resources</span>
					<div class="tab-contents-sublevel">
					<h2>Animations</h2>
						<ul class="simple">
							<li>
								<e:popup href="../home/cool-science.jsp" target="tryit" width="800" height="600">Cool Science</e:popup> - Introduction to the Physics Questions CMS addresses.
							</li>
						</ul>
						<h2>Screencast Demos</h2>
						<ul class="simple">
							<li>
								<e:popup href="../video/CMSe-LabNavigation.html" target="tryit" width="655" height="500">Getting Around the e-Lab</e:popup> - a good introduction to navigating the e-Lab including the Project Map and logbook.
							</li>
							<li>
								<e:popup href="http://screencast.com/t/NTA2ODBiZTI" target="tryit" width="625" height="675">Introduction: Single Event Display</e:popup> - how Z Boson decays are displayed in data.
							</li>
							<li>
								<e:popup href="../video/demos-calibration.html?video=data-selection" target="tryit" width="800" height="800">Data Selection: Calibration Studies</e:popup>
 - how to select data.
							</li>
							<li>
								<e:popup href="../video/demos-calibration.html?video=plot-selection" target="tryit" width="800" height="800">Plot Selection: Calibration Studies</e:popup>
 - how to select plots.
							</li>
							<li>
								<e:popup href="../video/demos-calibration.html?video=plot" target="tryit" width="800" height="800">Plotting Tool: Calibration Studies and Exploration</e:popup> - how to plot.
							</li>
							<li>
								<e:popup href="../video/demos-exploration.html?video=dataset-selection" target="tryit" width="800" height="800">Dataset Selection: Exploration Studies</e:popup>
 - how to select datasets.
							</li>
							<li>
								<e:popup href="../video/demos-exploration.html?video=data-selection" target="tryit" width="800" height="800">Data Selection: Exploration Studies</e:popup>
 - how to select data.
							</li>
							<li>
								<e:popup href="../video/demos-exploration.html?video=plot-selection" target="tryit" width="800" height="800">Plot Selection: Exploration Studies</e:popup>
 - how to select plots.
							</li>
							<li>
								3-D Event Display: <e:popup href="http://screencast.com/t/X2WGL5ru8wMX" target="tryit" width="775" height="625">Intro</e:popup> -
								<e:popup href="http://screencast.com/t/7wFGMWXVpdOM" target="tryit" width="775" height="625">More Features</e:popup>
								- how to use the tool.

							</li>
						</ul>
					<h2>Single Events</h2>
						<ul class="simple">
							<li>
								<e:popup href="../event-display/" target="tryit" width="900" height="900">3-D Event Display</e:popup> - Manipulate CMS events. See screencast demo above.
							</li>
							<li>
								<e:popup href="http://ed.fnal.gov/work/i2u2/particle-id/cms_game.html" target="tryit" width="865" height="675">Identify CMS events</a></e:popup>- Test your skill.
							</li>
						</ul>
					</div>
				</div>
				

				<div class="tab" id="tab-online">
					<span class="tab-title">Websites</span>
					<div class="tab-contents-sublevel">
						<h2>Student-Friendly Sites</h2>
						<ul class="simple">
							<li>
								<e:popup href="http://cms.web.cern.ch/" target="website" width="850" height="600">Welcome to CMS</e:popup> - From CMS at CERN
							</li>
							<li>
								<e:popup href="http://public.web.cern.ch/public/en/LHC/CMS-en.html" target="website" width="850" height="600">CMS: Compact Muon Solenoid</e:popup>
								- From the CERN public website.
							</li>

							<li>
								<e:popup href="http://particleadventure.org/modern_detect.html" target="website" width="875" height="600">The Particle Adventure</e:popup>
								- Modern Detectors.
							</li>

							<li>
								<e:popup href="http://www.fnal.gov/pub/inquiring/matter/madeof/index.html" target="website" width="850" height="600">What is the world made of?</e:popup>
								- From Inquiring Minds - Fermilab.
							</li>

    						<li>
								<e:popup href="http://physicsmasterclasses.org/exercises/hands-on-cern/hoc_v21en/index.html" target="website" width="850" height="600">Hands-on-CERN</e:popup>
							</li>
							<li>
								<e:popup href="http://www.lhc.ac.uk/" target="website" width="925" height="610">The Large Hadron Collider</e:popup> and the <e:popup href="http://www.particledetectives.net/LHC/LHC_project.html" target="website" width="875" height="610">LHC Project Simulator</e:popup> - from the Science and Technology Facilities Council, Great Britain							
							</li>
							<li>
								<e:popup href="http://cern50.web.cern.ch/cern50/multimedia/LHCGame/StartGame.html" target="website" width="875" height="610">LHC Game (CERN)</e:popup> 
							</li>
							<li>
								<e:popup href="http://atlas.ch/" target="website" width="900" height="600">The Atlas Detector</e:popup> - Atlas website at CERN
							</li>
							<li>
								<e:popup href="http://press.web.cern.ch/press/" target="website" width="900" height="600">CERN Press Office</e:popup> - Announcements from CERN
							</li>
							<li>
								Research Citation (Purdue University):  <a target="_blank" href="https://owl.english.purdue.edu/owl/resource/560/01/">APA Formatting and Style Guide</a> & 
								<a target="_blank" href="https://owl.english.purdue.edu/owl/resource/747/01/">MLA Formatting and Style Guide</a>
							</li>
								
						</ul>

					</div>
				</div>
				
				
			</div>
		</td>
		<td>
			<div id="right">
<%-- 
				<div class="tab" id="tab-tutorials">
					<span class="tab-title">Tutorials - Coming Soon</span>
					<div class="tab-contents-sublevel">
						<ul class="simple">
								<li>
								<b>Advanced:</b> <a href="http://www-root.fnal.gov/root/">ROOT Tutorial</a>
								- Learn how to use ROOT (the underpinnings of OGRE)  to analyze any aspect of the data directly.
							</li>
							</ul>
					</div>
--%>
				</div>

				
							<div class="tab" id="tab-video">
					<span class="tab-title">Video</span>
					<div class="tab-contents-sublevel">
						<ul  class="simple">

							<li>
								<e:popup href="http://news.bbc.co.uk/2/hi/science/nature/7543089.stm" target="video" width="800" height="600">Guide to the LHC</e:popup> - from the BBC
							</li>
							<li>
								<e:popup href="../video/lhc-how-it-works.html" target="video" width="515" height="415">The LHC - how it works</e:popup> - YouTube
							</li>
							<li>
								In Search of Giants <e:popup href="http://www.youtube.com/watch?v=HVxBdMxgVX0" target="youtube" width="675" height="550">(1)</e:popup> <e:popup href="http://www.youtube.com/watch?v=WGWlT8SqXLM" target="youtube" width="675" height="550">(2)</e:popup> - A Crash Course in Particle Physics Featuring Brian Cox from The Science and Technology Facilities Council Channel, SciTechUK's Channel
							</li>
						<li>
								<e:popup href="http://www.phdcomics.com/comics/archive.php?comicid=1489" target="video" width="800" height="800">The Higgs Boson Explained</e:popup> - Animated Comic from PhDComics.
							</li>




							<li>
								<e:popup href="../video/lhc-first-images.html" target="video" width="515" height="415">First Images after Proton Beam Passes through LHC</e:popup> - from the New Scientist
							</li>
							<li>
								<e:popup href="../video/lhc-accelerator-CERN.html" target="video" width="515" height="415">LHC Accelerator at CERN</e:popup> - from CERN Multimedia Productions
							</li>
							<li>
								<e:popup href="http://www.youtube.com/user/CERNTV" target="video" width="700" height="750">CERN TV</e:popup> - YouTube
							</li>
							</ul>
							</div>
							</div>
							

				
				<div class="tab" id="tab-contacts">
					<span class="tab-title">Contacts</span>	
					<div class="tab-contents-sublevel">
						<h2>Physicists</h2>
						<ul class="simple">
							<li>
								<a href="mailto:karmgard.1@nd.edu">Dan Karmgard</a> - University of Notre Dame
							</li>
							<li>
								<a href="mailto:lantonel@nd.edu">Jamie Antonelli</a> - Ohio State
							</li>
							<li>
								<a href="mailto:rruchti@nsf.gov">Randy Ruchti</a> - NSF and University of Notre Dame
							</li>
						</ul>
						<h2>Staff</h2>
						<ul class="simple">
							<li>
								<a href="mailto:kcecire@nd.edu>">Kenneth Cecire</a> - University of Notre Dame
							</li>
						</ul>
						<% if (hideMenu.equals("no")) { %>
							<h2><a href="../library/students.jsp">Student Research Groups</a></h2>
						<% } %>
					</div>
				</div>
				

				
				<div class="tab" id="tab-slideshows">
					<span class="tab-title">Slideshows</span>
					<div class="tab-contents-sublevel">
						<ul class="simple">
							<li>
								<a href="http://outreach.phys.uh.edu/index_files/PPT/Notre%20Dame/CMS_Coll.ppt">The 
                  				Compact Muon Solenoid at the Large  Collider</a> - Presentation on the Compact Muon 
                  				Solenoid, written by Dan Green.
							</li>
						</ul>
					</div>
				</div>



					<div class="tab" id="tab-it-careers">
					<span class="tab-title">IT Careers</span>
					<div class="tab-contents-sublevel">
						<ul class="simple">
							<li>
								<e:popup href="http://www2.edc.org/ewit/materials/ITCCBRO.pdf" target="website" width="850" height="600">Career Cluster Pamphlet</e:popup>,
								(pdf) from Vocational information Center's <A href="http://www.khake.com/page17.html">Computer Science Career Guide</a>
							</li>
							<li>
								<e:popup href="http://www.microsoft.com/learning/training/careers/prepare.mspx" target="website" width="850" height="600">Prepare for an Information Technology (IT) Career</e:popup>,
								from Microsoft Learning
							</li>
							</ul>
					</div>			
				
	             </div>			



							<div class="tab" id="tab-grid-computing">
					<span class="tab-title">Grid Computing</span>
					<div class="tab-contents-sublevel">
					<p>The grid is critical for providing the data to all the CMS researchers.</p>
						<ul  class="simple">
							<li>
							<li>
								Go to <a href="http://www.gridtalk.org/">Grid Talk</a> where you can read <a href="http://www.gridtalk.org/briefings.htm">Grid Briefings</a> and explore the <a href="http://www.gridguide.org/">Grid Guide</a>, from CERN.
							</li>							
							</li>
							<li>
								<e:popup href="http://www.tryscience.org/grid/home.html" target="website" width="850" height="600">Grids for Kids at TryScience</e:popup>
								- Use grid computing to model Mt. Vesuvius' volcanic activity and discover whether residents need warning, from New York Museum of Science. 
							</li>
							<li>
								<e:popup href="http://www.wikipedia.org/wiki/Grid_computing" target="website" width="850" height="600">Grid Computing</e:popup> - 
								Read the Wikipedia article on the grid computing. 
							</li>			
							</ul>
							</div>
							</div>




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
