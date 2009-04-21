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
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Looking for information? Check out the online resources or contact someone.</h1>
<p>You can find lots of information in the e-Lab's <a href="../references/showAll.jsp?t=reference">References for the Study Guide</a> and <a href="../references/showAll.jsp?t=glossary">Glossary</a>.</p>
<table border="0" id="main">
	<tr>
		<td>
			<div id=left>
				
				<div class="tab" id="tab-tutorials">
					<span class="tab-title">Tutorials</span>
					<div class="tab-contents-sublevel">
						<ul class="simple">
							<li>
								<e:popup href="../analysis-performance/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and <a href="../analysis-performance/tutorial.jsp">Tutorial</a>
								 - Understand how to do and interpret the output of the <b>Performance Study</b>.
							</li>
							<li>
								<e:popup href="../analysis-shower/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and  <a href="../analysis-shower/tutorial.jsp">Tutorial</a>
								- Discover how to tell if you have seen a <b>shower</b>.
							</li>
							<li>
								<e:popup href="../analysis-flux/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and <a href="../analysis-flux/tutorial.jsp">Tutorial</a>
								- Learn how to understand the results of a <b>Flux Study</b>.
							</li>
							<li>
           						<e:popup href="../analysis-lifetime/tryit.html" 
           							target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and  <a href="../analysis-lifetime/tutorial.jsp">Tutorial</a>
								- Discover how to read a <b>Lifetime Study </b> graph.
							</li>
							
							
							<c:if test="${user.upload}">
					            <li>
									<a href="../geometry/tutorial.jsp">Updating Geometry Tutorial</a>
									 - Learn how to properly input the layout of your detector.
								</li>
							</c:if>
						</ul>
					</div>
				</div>
			
				<div class="tab" id="tab-contacts">
					<span class="tab-title">Contacts</span>	
					<div class="tab-contents-sublevel">
						<h2>Physicists</h2>
						<ul class="simple">
							<li>
								<a href="mailto:glass@fnal.gov">Henry Glass</a> - Fermilab/Auger
							</li>
							<li>
								<a href="mailto:barnett@lbl.gov">Michael Barnett</a> - Lawrence Berkeley National Laboratory
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
					<div class="tab-contents-sublevel">
						<ul class="simple">
							<li>
								<a href="../flash/daq_only_standalone.html">Classroom Cosmic Ray Detector</a>
								 - Equipment to collect data.
							</li>
							<li>
								<a href="../flash/daq_portal_rays.html">Send Data to Grid Portal</a>
								- Data collected at schools is sent to grid portal.
							</li>
							<li>
								<a href="../flash/analysis.html">Analysis</a>
								- Counter performance study activates grid portal.
							</li>
							<li>
								<a href="../flash/collaboration.html">Collaboration</a>
								- How students collaborate
							</li>
							<li>
								<a href="../flash/SC2003.html">Loop</a>
								- Loop through the previous three
							</li>
							<li>
								<a href="../flash/griphyn-animate_sc2003.html">QuarkNet vs.CMS</a>
								- Comparing use of Grid in cosmic ray studies with the CMS experiment
							</li>
							<li>
								<a href="../flash/DAQII.html">Data Acquisition Card</a>
								- How the DAQ works. Rollovers provide more information on the board and the format of the data. <strong>Has SOUND.</strong>
							</li>
						</ul>
					</div>
				</div>
				<div class="tab" id="tab-animations">
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
				




			</div>
		</td>
		<td>
		
		<div id="right">
					
				<div class="tab" id="tab-online">
					<span class="tab-title">Online</span>
					<div class="tab-contents-sublevel">
						<h2>General Background</h2>
						<ul class="simple">
							<li>
								<a href="../content/CosmicExtremes.pdf">Cosmic Extremes</a>
								- Excellent cosmic ray overview rom Columbia University (pdf file)
							</li>
							<li>
								<a href="http://www.auger.org/">Pierre Auger Cosmic Ray Observatory</a>
								- Background and Q&A
							</li>
							
							 
							<li>
								<a href="http://quarknet.fnal.gov/resources/QN_CloudChamberV1_4.pdf">Build a Cosmic Ray Cloud Chamber</a>
								- Instructions (pdf file)
							</li>
							<li><a href="
 http://imagine.gsfc.nasa.gov/docs/science/know_l1/cosmic_rays.html">Cosmic Rays</a>, a larger perspective from NASA</li>
  
 <li><a href="
  http://helios.gsfc.nasa.gov/qa_cr.html">COSMICOPIA</a></li>


							<li>
								<a href="http://www2.slac.stanford.edu/vvc/cosmic_rays.html">Cosmic Rays</a>,
								from SLAC, Stanford University
							</li>
							<li>
								<a href="http://farweb.minos-soudan.org/events/LiveEvent.html" target="activity">MINOS</a>
								- Physicists detect cosmic rays in their neutrino detectors.
							</li>
							<li>
								<a href="http://www.symmetrymagazine.org/cms/?pid=1000688">Cosmic Weather Gauges</a>
								- Cosmic rays and upper atmospheric temperatures from Symmetry Magazine
							</li>
						</ul>
						<h2>Cosmic Ray Simulations (need
  QuickTime plugin)</h2>
						<ul class="simple">
						
						<li><a href=
  "javascript:showRefLink('http://astro.uchicago.edu/cosmus/projects/aires/protonshoweroverchicago.mpeg',800,600)">COSMUS</a>,  from University of  Chicago </li>
  
  <li><a href=
  "javascript:showRefLink('http://www.th.physik.uni-frankfurt.de/~drescher/CASSIM/c10.mpg',800,700)">
Simulation</a>, from Goethe Universitat Frankfurt am Main</li>
  </ul>
						
						<h2>Online Labs</h2>
						<ul class="simple">
							<li>
								<a href="http://outreach.physics.utah.edu/javalabs/java102/hess/index.htm">ASPIRE</a>
								- Investigations into the origin of cosmic rays, from the University of Utah
							</li>
						</ul>
						
						<h2>Grid Computing</h2>
						<ul  class="simple">
							<li>
								<a href="http://gridcafe.web.cern.ch/gridcafe/">The Grid Cafe</a>
								- An introduction. From there, go to <a href="http://www.gridtalk.org/">Grid Talk</a> where you can read <a href="http://www.gridtalk.org/briefings.htm">Grid Briefings</a> and explore the <a href="http://www.gridguide.org/">Grid Guide</a>, from CERN.
							</li>
							<li>
								<a href="http://www.tryscience.org/grid/home.html" target="activity">Grids for Kids at TryScience</a>
								- Use grid computing to model Mt. Vesuvius' volcanic activity and discover whether residents need warning, from New York Museum of Science. 
							</li>
							</ul>

						<h2>Professional Sites (Very Advanced)</h2>
						<ul class="simple">
							
	
							<li>
								<a href="http://scipp.ucsc.edu/milagro/Animations/AnimationIntro.html">Milagro Animations</a>
								- Simulations of extensive air showers and Milagro Detector. Most movies run under 5 megabytes and 
								are about 15 seconds long, by Miguel Morales (need QuickTime plugin)
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
