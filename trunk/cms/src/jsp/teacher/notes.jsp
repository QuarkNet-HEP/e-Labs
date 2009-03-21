<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Classroom Notes</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">


<h1>Learn how to do CMS Test Beam studies in your classroom.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		
		<td>
			<div id="center">
				<h2>Classroom Notes</h2>
				<p>
					<!--  this should probably be a ul -->
					<a href="notes.jsp">Notes</a>
					- <a href="strategy.jsp">Teaching Strategies</a>
					- <a href="web-guide.jsp">Research Guidance</a>
					- <a href="activities.jsp">Sample Classroom Activities</a>
				</p>
				<p> 
					<a href="http://cmsinfo.cern.ch/outreach/index.html">The CMS Detector</a>
				</p>
				
				<h2>Experiments Students Can Perform</h2>
				<ol> 
					<li>Shower Depth</li>
					<li>Lateral Size</li>
					<li>Beam Purity</li>
					<li>Detector Resolution</li>
					<li>Other studies devised by students</li>
				</ol> 

				<h2>Shower Depth Study</h2>
				<img class="float-right" src="../graphics/blast2.jpg" width="80" height="155" />
				<p>
					Shower Depth studies allow students to discover how deeply into 
					the calorimeter a particular type of particle deposits its energy. 
					This deposition is often called a shower because its spatial 
					pattern in the detector resembles a detector.
				</p>
				<p>
					In the calorimeter, particle first pass through the electromagnetic 
					calorimeter (Ecal) and then pass through the hadronic calorimeter 
					(Hcal). Particle's that deposit most of their energy in Ecal are 
					said to have a lesser shower depth and those that deposit most of 
					their energy in Hcal are said to have a greater shower depth. 
					Electrons deposit most of their energy  in the Ecal. Pions deposit 
					most of their energy in the Hcal. When CMS begins taking colliding 
					beam data with the LHC, particles other than electrons, pions and 
					muons will deposit energy in the calorimeters.  Electrons and 
					photons will deposit most of their energy in Ecal while hadrons 
					will deposit most of their energy in the Hcal. Muons pass through 
					the calorimeter depositing little energy in Ecal or Hcal.
				</p>
				<p>
					Students should begin by studying one kind of particle at single 
					energy(e.g. 50GeV electrons or 100 GeV pions). Then they should 
					look at the same particle at different energies. The ratio of Ecal 
					energy to Total Energy and of Hcal energy to Total energy may be 
					useful.
				</p>

				<h2>Lateral Size Study</h2>
				<img class="float-right" src="../graphics/hcal_shower_smaller.jpg" width="240" height="180" />
				<p>
					Lateral size studies allow students to discover how spatially 
					spread out the energy deposition of a particle's shower is in the 
					plane perpendicular to the particle's trajectory. In the diagram 
					the green part of the detector is Ecal. The left shower is an 
					electron shower and the right shower is a photon shower. The 
					yellow portion of the detector is Hcal. The left shower is from 
					a charged hadron, like a pion. While the right shower is from a 
					neutral particle shower, like a neutron.
				</p>
				<p>
					The broadness of the shower depends on both the type and energy 
					of the particle.
				</p>
				<p>
					Narrower showers should have higher Tower Energy to Total Energy 
					ratios. While broader showers should have lower Tower Energy to 
					Total Energy ratios. This should seem reasonable since in a 
					narrower shower most of the energy of the shower is deposited in 
					a single tower. In a broader shower the energy is deposited in 
					several towers.
				</p>
				<p>
					Students should begin by studying one kind of particle at a single 
					energy (e.g. 50GeV electrons or 100 GeV pions). Then they should 
					look at the same particle at different energies. We recommend that 
					students do the shower depth study first. With that experience and 
					their results of this study, students should be able to correlate 
					shower depth with lateral shower size.
				</p>
				
				<h2>Beam Purity Study</h2>
				<img class="float-right" src="../graphics/graph_3.png" width="220" height="194" />
				<p>
					Beam purity studies allows students to discover what fraction of 
					the beam is actually the type of particle requested. No beam is 
					100% pure. For instance, a pion beam may only be 95% pions.
				</p>
				<p>
					A very pure beam can be produced, but the selection process 
					reduces the number of beam particles. The number of beam particles 
					is called 'luminosity'.  Decreased luminosity decreases the rate of 
					collisions which lengthens the require data collection time.
				</p>
				<p>
					To discover the types of particles present in the beam, students 
					should do a scatter plot of Ecal vs Hcal with Ogre. Students should 
					begin by studying one kind of particle at a single energy (e.g. 
					50GeV electrons or 100 GeV pions). Then they should look at the 
					same particle at different energies. We recommend that students 
					do shower depth and lateral shower studies first. With that 
					experience and the results of this study, students should be able 
					to determine what % of the beam is the particle requested.
				</p>
				
				<h2>Detector Resolution Study</h2>
				<img class="float-right" src="../graphics/bell-curve.png" alt="Put a bell curve graph here" />
				<p>
					Detector Resolution studies allow students to determine how precisely
					the calorimeter measures a particle's energy. As in the other studies, 
					the students should begin by choosing a particular type of beam and 
					energy (e.g. 50GeV electrons or 100 GeV pions).
				</p>
				<p>
					Students should to make a histogram of the Ecal energies for 
					electron beams and Hcal energies for pion beams. The histogram should 
					resemble a  bell-shaped curve. Students should then measure the 
					half-width of the curve at half of the curves maximum height. This 
					width will be  in units of energy (GeV). 
				</p>
				<p>
					A typical result would be (100<u>+</u>15) GeV: 100GeV is the mean 
					(average) value and 15GeV is the HWHM or precision. Another valuable 
					(and maybe more familiar) indicator of precision is the RMS (root 
					mean square deviation) of the distribution.
				</p>
				<p>
					We recommend that students do shower depth,  lateral shower and beam 
					purity studies first.  With that experience and the results of this 
					study, students should be able to explain how precisely the detector 
					measures the energy of a particular  particle beam.
				</p>
				
				<h2>Use Root Tools Extend Studies</h2>
				<img class="float-right" src="../graphics/root_logo.jpg" alt="root logo" width="176" height="117" />
				<p>
					OGRE is an interface for ROOT, an object-oriented data analysis 
					framework, to simplify the analysis for students. When the students 
					have completed all four of these studies using OGRE, they might be 
					interested in learning to use ROOT. It is the same analysis program 
					that the scientists use to analyze collision data. ROOT is a free 
					software and can be downloaded with all the tutorials from 
					<a href="http://root.cern.ch">http://root.cern.ch</a>.
				</p>
				<p>
					Presently I2U2 online analysis tools allow students  to analyze Test 
					Beam data in order to study how particles interact with the CMS 
					calorimeter. These types of studies are the precursors to the 
					calibrations of the calorimeters. In the future (2007) the LHC 
					(Large Hadron Collider) will provide the highest energy beam-beam 
					collisions in the world (14 TeV). Through this eLab students will be 
					able to select and analyze this data at the energy frontier.
				</p>
			</div>
		</td>
		<td>
			<div id="right">
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
