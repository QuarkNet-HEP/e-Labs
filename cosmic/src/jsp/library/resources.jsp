<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>

<?xml version="1.0" encoding="UTF-8"?>
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
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Looking for information? Check out the online resources or contact someone.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
					
				<div class="tab" id="tab-tutorials">
					<span class="tab-title">Tutorials</span>
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<e:popup href="../analysis-performance/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and <a href="../analysis-performance/tutorial.jsp">Performance Study Background</a>
								 - Understand how to do and interpret the output of the Performance Study.
							</li>
							<li>
           						<e:popup href="../analysis-lifetime/tryit.html" 
           							target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and  <a href="../analysis-lifetime/tutorial.jsp">Lifetime Study Background</a>
								- Discover how to read a Lifetime Study graph.
							</li>
							<li>
								<e:popup href="../analysis-flux/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and <a href="../analysis-flux/tutorial.jsp">Flux Study Background</a>
								- Learn how to understand the results of a Flux Study.
							</li>
							<li>
								<e:popup href="../analysis-shower/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and  <a href="../analysis-shower/tutorial.jsp">Shower Study Tutorial</a>
								- Discover how to tell if you have seen a shower.
							</li>
							<c:if test="${user.upload}">
					            <li>
									<a href="geoInstructions.jsp">Updating Geometry Tutorial</a>
									 - Learn how to properly input the layout of your detector.
								</li>
							</c:if>
						</ul>
					</div>
				</div>
				
				<div class="tab" id="tab-online">
					<span class="tab-title">Online</span>
					<div class="tab-contents">
						<h2>Student-Friendly Sites</h2>
						<ul class="simple">
							<li>
								<a href="http://hires.phys.columbia.edu/papers/CosmicExtremes.pdf">Cosmic Extremes</a>
								- Excellent cosmic ray overview available to print (pdf file)
							</li>
							<li>
								<a href="http://www2.slac.stanford.edu/vvc/cosmic_rays.html">Cosmic Rays</a>
								- SLAC's cosmic ray site
							</li>
							<li>
								<a href="http://www.auger.org/">Pierre Auger Observatory</a>
								- Background and Q&A about cosmic rays
							</li>
							<li>
								<a href="http://gridcafe.web.cern.ch/gridcafe/">The Grid Cafe</a>
								- An introduction to the grid.
							</li>
							<li>
								<a href="http://www.tryscience.org/grid/home.html" target="activity">Grids for Kids at TryScience</a>
								- from New York Museum of Science. Use grid computing to model Mt. Vesuvius' volcanic activity to discover whether residents need warning.
							</li>
						</ul>
						
						<h2>Online Labs</h2>
						<ul class="simple">
							<li>
								<a href="http://outreach.physics.utah.edu/javalabs/java102/hess/index.htm">ASPIRE</a>
								- Investigations into the origin of cosmic rays
							</li>
						</ul>

						<h2>Professional Sites (Very Advanced)</h2>
						<ul class="simple">
							<li>
								<a href="http://ik1au1.fzk.de/~heck/corsika/">CORSIKA</a>
								- An air shower simulation program
							</li>
							<li>
								<a href="http://wwwasd.web.cern.ch/wwwasd/geant4/geant4.html">GEANT4</a>
								- A toolkit for simulating the passage of particles through matter
							</li>
							<li>
								<a href="http://scipp.ucsc.edu/milagro/Animations/AnimationIntro.html">Milagro Animations</a>
								- QuickTime movies of simulated HEP events. Most movies run under 5 megabytes and 
								are about 15 seconds long.
							</li>
							<li>
								<a href="http://www.wired.com/wired/archive/12.04/grid.html?tw=wn_tophead_6">The God Particle
								 and the Grid.</a>
								 - Wired Magazine discusses the grid and particle physics at CERN, Fermilab's sister 
								 laboratory in Geneva, Switzerland.
							</li>
						</ul>
					</div>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab" id="tab-contacts">
					<span class="tab-title">Contacts</span>	
					<div class="tab-contents">
						<h2>Physicists</h2>
						<ul class="simple">
							<li>
								<a href="mailto:glass@fnal.gov">Henry Glass</a> - Fermilab / Auger
							</li>
							<li>
								<a href="mailto:barnett@lbl.gov">Michael Barnett</a> - Berkeley Lab
							</li>
							<li>
								<a href="mailto:jordant@fnal.gov">Tom Jordan</a> - University of Florida
							</li>
							<li>
								<a href="mailto:randal.c.ruchti.1@nd.edu">Randy Ruchti</a> - Notre Dame University
							</li>
						</ul>
						<h2><a href="../library/students.jsp">Student Research Groups</a></h2>
					</div>
				</div>
				
				<div class="tab" id="tab-animations">
					<span class="tab-title">Animations</span>
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<a href="../flash/daq_only_standalone.html">Classroom Cosmic Ray Detector</a>
								 - Equipment at each school to collect data.
							</li>
							<li>
								<a href="../flash/daq_portal_rays.html">Send Data to Grid Portal</a>
								- Data collected at schools is sent to grid portal.
							</li>
							<li>
								<a href="../flash/analysis.html">Analysis</a>
								- Counter Performance study activates grid portal.
							</li>
							<li>
								<a href="../flash/collaboration.html">Collaboration</a>
								- How Students collaborate.
							</li>
							<li>
								<a href="../flash/SC2003.html">Loop</a>
								- Loop through the previous three for presentation.
							</li>
							<li>
								<a href="../flash/griphyn-animate_sc2003.html">QuarkNet vs.CMS</a>
								- Comparing use of Grid in QuarkNet with the CMS experiment
							</li>
							<li>
								<a href="../flash/DAQII.html">DAQII</a>
								- How the DAQII board works. <strong>Has SOUND.</strong>
							</li>
						</ul>
					</div>
				</div>
				<div class="tab" id="tab-animations">
					<span class="tab-title">IT Careers</span>
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<a href="http://www2.edc.org/ewit/materials/ITCCBRO.pdf">Career Cluster Pamphlet</a>
								 - (pdf) from Vocational information Center's <A href="http://www.khake.com/page17.html">Computer Science Career Guide</a>.
							</li>
							<li>
								<a href="http://www.microsoft.com/learning/training/careers/prepare.mspx">Prepare for an Information Technology (IT) Career</a>
								- from Microsoft Learning.
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
