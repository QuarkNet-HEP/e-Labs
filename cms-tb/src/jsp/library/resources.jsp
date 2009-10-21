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
					<span class="tab-title">Online</span>
					<div class="tab-contents">
						<h2>Student-Friendly Sites</h2>
						<ul class="simple">
							<li>
								<a href="http://cmsinfo.cern.ch/outreach/CMSmedia/CMSmovies.html">2 minute video Introduction to Cern</a>
								- A two minute video to introduce CERN- a downloadable Real/Video file. 7 MB.
							</li>
							<li>
								<a href="http://cmsinfo.cern.ch/Welcome.html/">CMS Outreach Activities</a>
								- Decent site, includes CMS trivia, information, and picture.
							</li>
							<li>
								<a href="http://www.phys.ufl.edu/hee/cms/">CMS Experiment</a>
								- Concise explanation of CMS, links, and picture.
							</li>
							<li>
								<a href="http://www.iisc.ernet.in/pramana/april2000/dae11.htm">LHC Program/CMS Experiment</a>
								- PDF file &ndash; extremely detailed, would recommend site for someone who already has a good
								idea of the CMS experiment.
							</li>
							<li>
								<a href="http://en.wikipedia.org/wiki/Compact_Muon_Solenoid">CMS Wikipedia Encyclopedia Definition</a>
								- Definition of CMS, relevant links.
							</li>
							<li>
								<a href="http://www.phy.hr/~dpaar/fizicari/">Famous Physicists</a>
								- List of many famous physicists with a picture and small biography.
							</li>
							<li>
								<a href="http://physics.about.com/cs/glossary/a/glossary.htm">Physics Glossary</a>
								- Physics glossary with terms and definitions.
							</li>
							<li>
								<a href="http://www.exploratorium.edu/origins/cern/tools/lhc.html">The Large Hadron Collider </a>
								- Detailed explanation of the LHC, with pictures, and links. Easy to understand explanation.
							</li>
						</ul>

						<h2>Professional Sites</h2>
						<ul class="simple">
							<li>
								<a href="http://www.gaengineering.com/INGLESE%20ok/INDUSTRIAL%20PROGRAMMES/CMS/CMS.htm">G&amp;A Engineering CMS</a>
								- Description of the CMS detector, including a mission overview and CMS layout.
							</li>
							<li>
								<a href="http://www-td.fnal.gov/projects/muon.html">Fermilab's CMS Website</a>
								- Description of CMS with good links.
							</li>
						</ul>
					</div>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab" id="tab-tutorials">
					<span class="tab-title">Tutorials</span>
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<a href="http://www-root.fnal.gov/root/">ROOT Tutorial</a>
								- Learn how to use ROOT (the underpinnings of OGRE)  to analyze any aspect of the data directly.
							</li>
							<li>
           						<a href="../analysis-shower-depth/background.jsp">Shower Depth Study </a> - Background
							</li>
							<li>
								<a href="../analysis-lateral-size/background.jsp">Lateral Size Study </a>- Background
							</li>
							<li>
								<a href="../analysis-beam-purity/background.jsp">Beam Purity Study </a>- Background
							</li>
				            <li>
								<a href="../analysis-resolution/background.jsp">Detector Resolution Study </a>- Background
							</li>
						</ul>
					</div>
				</div>
				
				<div class="tab" id="tab-contacts">
					<span class="tab-title">Contacts</span>	
					<div class="tab-contents">
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
					<div class="tab-contents">
						<ul class="simple">
							<li>
								<a href="http://www.phys.ufl.edu/~acosta/cms/mcdonald_reu_talk.pdf">Study 
                  				of the Optimum Momentum Resolution of CMS Experiment</a>
                  				- Presentation on CMS experiment. Written by Timothy McDonald
							</li>
							<li>
								<a href="http://www.wlap.org/wl-repository/umich/phys/um-cern-reu/2004/20040805-umwlap002-08-wagner/real/sld001.htm">Muon Identification in CMS</a>
								- Slideshow on the CMS experiment, written by Andrew Wagner.
							</li>
							<li>
								<a href="http://outreach.phys.uh.edu/index_files/PPT/Notre%20Dame/CMS_Coll.ppt">The 
                  				Compact Muon Solenoid at the Large  Collider</a> - Presentation on the Compact Muon 
                  				Solenoid, written by Dan Green.
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
