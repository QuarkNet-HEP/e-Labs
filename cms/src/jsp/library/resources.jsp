<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


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
					<div id="nav">
						<%@ include file="../include/nav-rollover.jspf" %>
					</div>
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
								<e:popup href="../video/demos-exploration.html?video=data-selection" target="tryit" width="800" height="800">Data Selection: Exploration Studies</e:popup>
 - how to select data.
							</li>
							<li>
								<e:popup href="../video/demos-exploration.html?video=plot-selection" target="tryit" width="800" height="800">Plot Selection: Exploration Studies</e:popup>
 - how to select plots.
							</li>
							<li>
								<e:popup href="http://screencast.com/t/X2WGL5ru8wMX" target="tryit" width="775" height="625">3-D Event Display</e:popup> - how to use the 3d Event Display tool.
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
								<a href=" http://cms.web.cern.ch/cms/index.html">Welcome to CMS</a>
								- From CMS at CERN.
							</li>
							<li>
<a href="http://public.web.cern.ch/public/en/LHC/CMS-en.html">CMS: Compact Muon Solenoid</a>
								- From the CERN public website.
							</li>

							<li>
								<a href="http://particleadventure.org/modern_detect.html">The Particle Adventure</a>
								- Modern Detectors.
							</li>

							<li>
								<a href="http://www.fnal.gov/pub/inquiring/matter/madeof/index.html">What is the world made of?</a>
								- From Inquiring Minds - Fermilab.
							</li>

							<li>
								<a href="http://hands-on-cern.physto.se/hoc_v21en/index.html">Hands-on-CERN</a>
							</li>
							<li>
								<a href="http://www.lhc.ac.uk/">The Large Hadron Collider</a> - from the Science and Technology Facilities Council, Great Britain
							</li>
							<li>
								<a href="http://atlas.ch/">The Atlas Detector</a> - Atlas website at CERN
							</li>
						</ul>

					</div>
				</div>
				
				
							<div class="tab" id="tab-video">
					<span class="tab-title">Video</span>
					<div class="tab-contents-sublevel">
						<ul  class="simple">

<li>
								<e:popup href="http://news.bbc.co.uk/2/hi/science/nature/7543089.stm" target="video" width="800" height="600">Guide to the LHC</e:popup></a> - from the BBC
							</li>
							<li>
								<e:popup href="../video/lhc-how-it-works.html" target="video" width="515" height="415">The LHC - how it works</e:popup> - YouTube
							</li>
							<li>
								<e:popup href="http://www.youtube.com/user/SciTechUK" target="youtube" width="675" height="550">In Search of Giants</e:popup>- The Science and Technology Facilities Council Channel, SciTechUK's Channel
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
				
				<div class="tab" id="tab-contacts">
					<span class="tab-title">Contacts</span>	
					<div class="tab-contents-sublevel">
						<h2>Physicists</h2>
						<ul class="simple">
							<li>
								<a href="mailto:karmgard.1@nd.edu">Dan Karmgard</a> - University of Notre Dame
							</li>
							<li>
								<a href="mailto:pmooney@nd.edu">Patrick Mooney</a> - University of Notre Dame
							</li>
							<li>
								<a href="mailto:rruchti@nsf.gov">Randy Ruchti</a> - NSF and University of Notre Dame
							</li>
						</ul>
						<h2><a href="../library/students.jsp">Student Research Groups</a></h2>
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
								<a href="http://www2.edc.org/ewit/materials/ITCCBRO.pdf">Career Cluster Pamphlet</a>,
								(pdf) from Vocational information Center's <A href="http://www.khake.com/page17.html">Computer Science Career Guide</a>
							</li>
							<li>
								<a href="http://www.microsoft.com/learning/training/careers/prepare.mspx">Prepare for an Information Technology (IT) Career</a>,
								from Microsoft Learning
							</li>
							</ul>
					</div>			
				
	             </div>			

							<div class="tab" id="tab-grid-computing">
					<span class="tab-title">Grid Computing</span>
					<div class="tab-contents-sublevel">
						<ul  class="simple">
							<li>
								<a href="http://gridcafe.web.cern.ch/gridcafe/">The Grid Cafe</a>
								- An introduction. From there, go to <a href="http://www.gridtalk.org/">Grid Talk</a> where you can read <a href="http://www.gridtalk.org/briefings.htm">Grid Briefings</a> and explore the <a href="http://www.gridguide.org/">Grid Guide</a>, from CERN.
							</li>
							<li>
								<a href="http://www.tryscience.org/grid/home.html" target="activity">Grids for Kids at TryScience</a>
								- Use grid computing to model Mt. Vesuvius' volcanic activity and discover whether residents need warning, from New York Museum of Science. 
							</li>
							<li>
								<a href="http://www.wikipedia.org/wiki/Grid_computing">Grid Computing</a>
								- Read the Wikipedia article on the grid computing. 
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
