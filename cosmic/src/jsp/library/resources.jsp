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
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Resources: Check out the online resources or contact someone.</h1>
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
								<e:popup href="../analysis-flux/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and <a href="../analysis-flux/tutorial.jsp">Tutorial</a>
								- Learn how to understand the results of a <b>Flux Study</b>.
							</li>
							<li>
								<e:popup href="../analysis-shower/tryit.html" 
									target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
								and  <a href="../analysis-shower/tutorial.jsp">Tutorial</a>
								- Discover how to tell if you have seen a <b>shower</b>.
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
					<span class="tab-title">Plots</span>
					<div class="tab-contents-sublevel">
						
				<ul  class="simple">
						
						<li>
					 <a href="http://nces.ed.gov/nceskids/graphing/">
  Create a Graph</a> - Practice
  making area, bar and line graphs and pie charts, from <i>Kids'Zone</i> at Shodor.</il>

<li><a href="http://www.shodor.org/interactivate/activities/flydata/index.html">
  Interactive X-Y plot</a> - Enter and practice plotting your
  data, from Inter<i>activate</i> at Shodor.</il>

 <li><A HREF="http://www.shodor.org/interactivate/activities/scatterplot/index.html">
  Scatter Plots</a> - Create the most basic scatter plot, from Inter<i>activate</i> at Shodor.</il>
  

 <li><a href="http://musr.physics.ubc.ca/~jess/hr/skept/Meas/node2.html">
  Graphs and Error Bars</a> - A definition from <i>Believe It or Not - A Skeptics Guide</I></il>

 <li><a href="http://www.purplemath.com/modules/graphexp.htm">
  Graphing Exponential Equations</a> - Lessons from
  <i>Purplemath</i>.<//il>

<li><a href="http://www.shodor.org/interactivate/activities/histogram/">
  Histogram</a> - All about histograms with an
  interactive example from Inter<i>activate</i> at Shodor</il>

<li><a href="http://www.teacherschoice.com.au/images/histogram.gif">
  Histogram</a> - An example</il>

<li><a href="http://www.deakin.edu.au/~agoodman/sci101/chap12.php#RTFToC12">
  3D Graphs</a> - Wxamples from an individual at Deakin University</il>
  
  <li><a href="http://www.teacherschoice.com.au/images/scientific_plot.gif">
  Scientific Plot</a> - A line graph with error bars on
  points and best fit line</li>

 <a href="http://instruct1.cit.cornell.edu/courses/virtual_lab/LabZero/Experimental_Error.shtml">Experimental Error</a>, from Cornell University</li>

 <a href="http://www.batesville.k12.in.us/physics/APPhyNet/Measurement/Measurement_Intro.html">Physics and Measurements</a>, by  JL Stanbrough
  </li>

						</ul>
						</div>		
						</div>
		</td>
		<td>
		
		<div id="right">
					
				<div class="tab" id="tab-online">
					<span class="tab-title">Cosmic Ray Sites</span>
					<div class="tab-contents-sublevel">
						<h2>General Background</h2>
						<ul class="simple">
						
						<li><a href="http://en.wikipedia.org/wiki/Cosmic_rays">Wikipedia</a>, a good place to start</li>

							<li>
								<a href="http://www.auger.org/">Pierre Auger Cosmic Ray Observatory</a>
								- Background and Q&A
							</li>

							<li>
								<a href="../content/CosmicExtremes.pdf">Cosmic Extremes</a>
								- Excellent cosmic ray overview rom Columbia University (pdf file)
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
							<li><a href="http://ed.fnal.gov/pdf/leo.pdf">Leo's Logbook</a> - Tips for keeping a logbook</il>
						
							
						</ul>
						<h2>Cosmic Ray Simulations (need
  QuickTime plugin)</h2>
						<ul class="simple">
						
						<li><a href=
  "http://astro.uchicago.edu/cosmus/projects/aires/protonshoweroverchicago.mpeg">COSMUS</a>,  from University of  Chicago </li>
  
  <li><a href=
  "http://www.th.physik.uni-frankfurt.de/~drescher/CASSIM/c10.mpg">
Simulation</a>, from Goethe Universitat Frankfurt am Main</li>
	
  </ul>
						
						<h2>Online Labs</h2>
						<ul class="simple">
							<li>
								<a href="http://outreach.physics.utah.edu/javalabs/java102/hess/index.htm">ASPIRE</a>
								- Investigations into the origin of cosmic rays, from the University of Utah
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
						<div class="tab" id="tab-online">
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
							
							<div class="tab" id="tab-online">
					<span class="tab-title">Reporting Research</span>
					<div class="tab-contents-sublevel">
						<ul  class="simple">

		
						<ul  class="simple">
						
						<li><a href="http://www.madsci.org/posts/archives/2004-02/1075755143.Me.r.html">
  Defend your reseach</a>, from <i>MacSci Network</i></li>
  
 <li><a href="http://leo.stcloudstate.edu/bizwrite/abstracts.html">
  Writing Abstracts</a> - A good tutorial from <i>Write Place</i></li>
  
<li><a href="http://www.space.com/scienceastronomy/gravity_speed_030116.html">
  Science at odds</a>, from SPACE.COM showing when science requires public
  discourse among experts to advance
						</li>
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
