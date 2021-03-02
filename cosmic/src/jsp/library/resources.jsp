<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%
	String referer = request.getParameter("referer");
	if (referer == null) {
		referer = request.getHeader("Referer");
	}
	request.setAttribute("referer",referer);
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
		<script>
			function goBackAndRefresh() {
				var referer = document.getElementById("referer");
				if (referer.value != null) {
				    window.location = referer.value;
				} 
			}
		</script>
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
			<input type="hidden" name="referer" id="referer" value="${referer}" >
			<% if (hideMenu.equals("yes")) { %>
			<a href="javascript:goBackAndRefresh();" style="font-size: 20px; text-decoration: none">Go back to the Cosmic Ray e-Lab</a><br /><br />			
			<% } %>							
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
						<li>
           					<e:popup href="../analysis-timeofflight/tryit.html" 
           					target="TryIt" width="520" height="600">Step-by-Step Instructions</e:popup>
							and  <a href="../analysis-timeofflight/tutorial.jsp">Tutorial</a>
							- Learn how to understand the results of a <b>Time of Flight Study </b>. 
						</li>
						   
						<c:if test="${user.upload}">
						<li>Geometry, GPS, Notifications Tutorials:<br>
						    <a target="_blank" href="../geometry/tutorial.jsp">Updating Geometry</a> - Properly input detector layout.
						    <br>
						    <a target="_blank" href="../geometry/gps_tutorial.jsp">GPS Coordinates</a> - Find your GPS Coordinates.
						    <br>
						    <e:popup href="Notif_tryit.html" target="TryIt" width="750" height="600">Notifications</e:popup> - View or send notifications for your group. 
						</li>		
						<li>
							Data Blessing Tutorials:<br />
							<a href="../analysis-blessing/benchmark-overview-tutorial.jsp">Overview</a><br />
							<a href="../analysis-blessing/benchmark-tutorial.jsp">Benchmark</a><br />
							<a href="../analysis-blessing/benchmark-process-tutorial.jsp">Blessing</a><br />
						</li>
						</c:if>
						
						<li>
							Advanced details on how to use the CRMD:<br />
							<a href="http://quarknet.i2u2.org/sites/default/files/cf_6000crmdusermanual-small.pdf">
							Series "6000" CRMD Users Manual </a>
						</li>
						<li>
							Learn how to assemble the CRMD:<br />
							<a href="http://quarknet.i2u2.org/sites/default/files/cf_crmdassemblyinstructions-small.pdf">
							Series "6000" CRMD Assembly Instructions </a>
						</li>
						<li>
							Series "6000" CRMD Plateauing Instructions:<br />
							<a href="http://quarknet.i2u2.org/sites/default/files/quarknet/cf_6000crmd_how_to_plateau.ppt">
							"6000" HOWTO PowerPoint </a>
							<br />
							<a href="http://quarknet.i2u2.org/sites/default/files/quarknet/cf_6000plateau_template.xls">
							"6000" SpreadSheet Form</a>
						</li>
					</ul>
				</div>
			</div>
								
			<div class="tab" id="tab-equip">
				<span class="tab-title" style="width: 200px;">CRMD Data Collection</span>	
				<div class="tab-contents-sublevel">
					<ul class="simple">
						<li>
							"6000" Series DAQ data collection software: <a href="../data/equip.jsp">EQUIP java interface</a>
						</li>
						<li>
							<a href="http://quarknet.i2u2.org/page/equip-raspberry-pi">EQUIP on Raspberry Pi </a>
						</li>
						<li>
							<a href="https://quarknet.org/sites/default/files/HowtouseEQUIP-PDF-19Aug2016.pdf">How to use EQUIP</a>
						</li>						
						<li>
							<a href="../data/gps.jsp">Step-by-Step Instructions</a> to fix the incorrect date produced by GPS hardware.
						</li>
					</ul>					
				</div>
			</div>		
									
			<div class="tab" id="tab-contacts">
				<span class="tab-title">Contacts</span>	
				<div class="tab-contents-sublevel">
					<h2>Physicists</h2>
					<ul class="simple">
						<li><a href="mailto:glass@fnal.gov">Henry Glass</a> - Fermilab/Auger</li>
						<li><a href="mailto:adams@fnal.gov">Mark Adams</a> - Fermilab</li>
						<li><a href="mailto:randal.c.ruchti.1@nd.edu">Randy Ruchti</a> - Notre Dame University</li>
					</ul>
					<% if (hideMenu.equals("no")) { %>
						<h2><a href="../library/students.jsp">Student Research Groups</a></h2>
					<% } %>
				</div>
			</div>

				
			<div class="tab" id="tab-animations">
				<span class="tab-title">Animations</span>
				<div class="tab-contents-sublevel">
					<ul class="simple">
						<li><a href="../flash/daq_only_standalone.html">Classroom Cosmic Ray Detector</a>
							 - Equipment to collect data.
						</li>
						<li><a href="../flash/DAQII.html">Data Acquisition Card</a>
							- How the DAQ works. Rollovers provide more information on the board and the format of the data. <strong>Has SOUND.</strong>
						</li>
					</ul>
				</div>
			</div>
				
					
	 		<div class="tab" id="tab-plots">     
				<span class="tab-title">Plots</span>
				<div class="tab-contents-sublevel">				
				<ul  class="simple">						
					<li><a href="http://nces.ed.gov/nceskids/graphing/">Create a Graph</a> - Practice
  						making area, bar and line graphs and pie charts, from <i>Kids'Zone</i> at Shodor.
  					</li>

					<li><a href="http://www.shodor.org/interactivate/activities/flydata/index.html">
  						Interactive X-Y plot</a> - Enter and practice plotting your
  						data, from Inter<i>activate</i> at Shodor.
  					</li>

 					<li><A HREF="http://www.shodor.org/interactivate/activities/scatterplot/index.html">
  						Scatter Plots</a> - Create the most basic scatter plot, from Inter<i>activate</i> at Shodor.
  					</li>
  
 					<li><a href="http://musr.physics.ubc.ca/~jess/hr/skept/Meas/node2.html">
  						Graphs and Error Bars</a> - A definition from <i>Believe It or Not - A Skeptics Guide</I>.
  					</li>

 					<li><a href="http://www.purplemath.com/modules/graphexp.htm">Graphing Exponential Equations</a> - Lessons from
  					<i>Purplemath</i>.
  					</li>

					<li><a href="http://www.shodor.org/interactivate/activities/histogram/">Histogram</a> - All about histograms with an
  					interactive example from Inter<i>activate</i> at Shodor.
  					</li>

					<li><a href="http://www.teacherschoice.com.au/images/histogram.gif">Histogram</a> - An example.</li>

					<li><a href="http://www.deakin.edu.au/~agoodman/sci101/chap12.php#RTFToC12">3D Graphs</a> 
					- Examples from an individual at Deakin University.
					</li>
  
					<li><a href="http://www.teacherschoice.com.au/images/scientific_plot.gif">
  			  		Scientific Plot</a> - A line graph with error bars on points and best fit line.
  			  		</li>

 					<li><a href="http://instruct1.cit.cornell.edu/courses/virtual_lab/LabZero/Experimental_Error.shtml">Experimental Error</a>, from Cornell University
 					<a href="http://www.batesville.k12.in.us/physics/APPhyNet/Measurement/Measurement_Intro.html">Physics and Measurements</a>, by  JL Stanbrough.
 					</li>
				</ul>
				</div>	
			</div>
			
			<div class="tab" id="tab-archives">
                                <span class="tab-title">Archives</span>
                                <div class="tab-contents-sublevel">
                                        <ul class="simple">
                                                <li><a href="../archives/manual_setup_200_5000.jsp">200 and 5000 Series</a> - Equipment and manuals.
                                                </li>
                                        </ul>
                                </div>
                        </div>

		</div><!-- close left div -->
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
								- Excellent cosmic ray overview from Columbia University (pdf file)
							</li>
							<li>
								<a href="http://quarknet.fnal.gov/resources/QN_CloudChamberV1_4.pdf">Build a Cosmic Ray Cloud Chamber</a>
								- Instructions (pdf file)
							</li>
							<li>
								<a href="http://imagine.gsfc.nasa.gov/docs/science/know_l1/cosmic_rays.html">Cosmic Rays</a>, a larger perspective from NASA
							</li>
 							<li>
 								<a href="http://helios.gsfc.nasa.gov/qa_cr.html">COSMICOPIA</a>
 							</li>
							<li>
								<a href="http://www2.slac.stanford.edu/vvc/cosmic_rays.html">Cosmic Rays</a>,
								from SLAC, Stanford University
							</li>
							<li>
								<a href="http://www-numi.fnal.gov/" target="activity">MINOS</a>
								- Physicists detect cosmic rays in their neutrino detectors.
							</li>
						  	<li>
						  		<a href="https://icecube.wisc.edu/science/icetop/" target="activity">IceTop</a> and <a href="http://whyfiles.org/2012/chasing-neutrinos-at-the-south-pole/" target="activity">IceCube</a>
								- Projects investigate neutrinos, but they also capture cosmic ray data.
							</li>
							<li>
								<a href="http://www.symmetrymagazine.org/cms/?pid=1000688">Cosmic Weather Gauges</a>
								- Cosmic rays and upper atmospheric temperatures from Symmetry Magazine
							</li>
							<li><a href="http://ed.fnal.gov/pdf/leo.pdf">Leo's Logbook</a> - Tips for keeping a logbook</li>
						    <li><a href="http://www.dtu.dk/english/News/2013/09/Danish-experiment-suggests-unexpected-magic-by-cosmic-rays-in-cloud-formation/">The SKY experiment</a>, from Denmark.</li>
							<li><a href="https://home.cern/about/experiments/cloud/">The CLOUD experiment</a> - The role of cosmic rays in CLOUD function, an atmospheric research at CERN.</li>
							<li><a href="http://www.space.dtu.dk/english/Research/Climate_and_Environment/">Center for Sun-Climate Research</a> - Investigation of the connection between solar activity and climatic changes on Earth.</li>
							<li><a href="https://wiki.iac.isu.edu/index.php/Cosmics_for_High_School_Teachers">Cosmic Ray overview for students</a></li>
							<li><a href="http://cosray.phys.uoa.gr/nmdb-barometric/nmdb-barometric.htm">How to calculate barometric pressure correction</a></li>
							<li><a href="http://neutronm.bartol.udel.edu/">Bartol Research Institute neutron monitor</a></li>
							<li><a href="http://www.sciencedaily.com/releases/2011/01/110125131450.htm">How strong is the weak force? New measurement of the muon lifetime</a></li>
						</ul>
						
						<h2>Cosmic Ray Simulations (need QuickTime plugin)</h2>
						<ul class="simple">
							<li>
								<a href="http://astro.uchicago.edu/cosmus/projects/aires/protonshoweroverchicago.mpeg">COSMUS</a>  from University of  Chicago 
							</li>
  							<li>
  								<a href="http://www.th.physik.uni-frankfurt.de/~drescher/CASSIM/c10.mpg">Simulation</a>, from Goethe Universitat Frankfurt am Main
  							</li>
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
						</ul>
					</div>
			</div>

			<div class="tab" id="tab-grid">
				<span class="tab-title">Grid Computing</span>
				<div class="tab-contents-sublevel">
					<p>The e-Lab uses <a href="http://www.wikipedia.org/wiki/Distributed_computing" target="website" width="850" height="600">distributed computing</a> where multiple computers, 
					networked together, perform the analysis of the data.  Many scientists use the grid - one form of distributed computing.  Learn more about the grid.</p>
					<ul class="simple">
						<li>See <a href="https://www.youtube.com/watch?v=LZDSLzU9pZ4" target="_blank">The Grid</a> and <a href="https://home.cern/about/computing/worldwide-lhc-computing-grid" target="_blank">
						The Worldwide LHC Computing Grid</a> for an introduction.  From there, go to <a href="http://gridtalk.org/">Grid Talk</a> where you can read 
						<a href="http://gridtalk.org/briefings.htm">Grid Briefings</a> and explore the <a href="http://www.gridguide.org/">Grid Guide</a>, from CERN.
						</li>
						<li>
							<e:popup href="http://www.tryscience.org/grid/home.html" target="website" width="850" height="600">Grids for Kids at TryScience</e:popup> - Use grid computing to model Mt. Vesuvius' volcanic activity and discover whether residents need warning, from New York Museum of Science.
						</li>
						<li>
							<e:popup href="http://www.wikipedia.org/wiki/Grid_computing" target="website" width="850" height="600">Grid Computing</e:popup> - Read the Wikipedia article on grid computing.
						</li>
					</ul>
				</div>
			</div>
						
			<div class="tab" id="tab-careers">
				<span class="tab-title">IT Careers</span>
				<div class="tab-contents-sublevel">
					<ul class="simple">
						<li>ACM's <A href="http://computingcareers.acm.org" target="_blank">Computing Degrees & Careers</a>
						</li>
						<li>
							<A target="_blank" href="http://www.microsoft.com/learning/training/careers/prepare.mspx">Prepare for an Information Technology (IT) Career</a>, 
							from Microsoft Learning.
						</li>
						<li>
							<A href="http://www.cisco.com/c/en/us/training-events/training-certifications/overview.html" target="_blank">Training & Certifications</a> from Cisco
						</li>
						<li>
							<A href="https://www.education.ne.gov/nce/careerclusters/2013/INFOTE.pdf" target="_blank">Career cluster</a> from Nebraska Department of Education						
						</li>
					</ul>
				</div>
			</div>				
							
			<div class="tab" id="tab-reporting">
				<span class="tab-title">Reporting Research</span>
				<div class="tab-contents-sublevel">
					<ul  class="simple">
						<li><a href="http://www.madsci.org/posts/archives/2004-02/1075755143.Me.r.html">
 							Defend your reseach</a>, from <i>MacSci Network</i>
 						</li>
 						<li><a href="http://leo.stcloudstate.edu/bizwrite/abstracts.html">
  							Writing Abstracts</a> - A good tutorial from <i>Write Place</i>
  						</li>
  
						<li><a href="http://undsci.berkeley.edu/article/howscienceworks_16">
  							Scrutinizing science: Peer review</a>, from Understanding Science (University of California), explains the process.
  						</li>	
						<li>Research Citation (Purdue University):  <a target="_blank" href="https://owl.english.purdue.edu/owl/resource/560/01/">APA Formatting and Style Guide</a> & 
							<a target="_blank" href="https://owl.english.purdue.edu/owl/resource/747/01/">MLA Formatting and Style Guide</a>
						</li>	
					</ul>
				</div>
			</div>
			
			</div><!-- close right div -->
			</td>
			</tr>
			</table>
			
			</div><!-- end content -->			
			<div id="footer"></div>
		</div><!-- end container -->
	</body>
</html>
