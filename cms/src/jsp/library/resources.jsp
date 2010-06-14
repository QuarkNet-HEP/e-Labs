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

						<h2>Professional Sites</h2>
						<ul class="simple">
						</ul>
					</div>
				</div>
				
				
							<div class="tab" id="tab-video">
					<span class="tab-title">Video</span>
					<div class="tab-contents-sublevel">
						<ul  class="simple">

<li>
								<a href="http://news.bbc.co.uk/2/hi/science/nature/7543089.stm">Guide to the LHC</a> - from the BBC
							</li>
							<li>
								<a href="http://www.youtube.com/watch?v=EaDRu9sV_zs">The LHC - how it works</a> 
							</li>
							<li>
								<a href="http://www.youtube.com/user/SciTechUK">In Search of Giants</a>
								- from SciTechUK 
							</li>
							<li>
								<a href="http://www.youtube.com/watch?v=Kf3T4ZHnuvc&feature=related">First Images after Proton Beam Passes through LHC</a>
								- from New Scientist
							</li>							

							<li>
								<a href="http://www.youtube.com/watch?v=rgLdIly2Xtw&feature=related">LHC Accelerator at CERN</a>
								- from CERN Multimedia Productions
							</li>							
							<li>
								<a href="http://www.youtube.com/user/CERNTV">CERN-TV</a>
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
