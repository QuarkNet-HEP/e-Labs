<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>

<%
	// Check if the teacher is in the study
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	boolean newSurvey = false;  
	boolean teacher   = false; 
	
	if (user != null) {
		if (user.isTeacher()) {
			teacher = true; 
			newSurvey = elab.getSurveyProvider().hasTeacherAssignedSurvey(user.getId());
		}
		request.setAttribute("userId", user.getId());
		
	}
	request.setAttribute("newSurvey", newSurvey);
	request.setAttribute("teacher", teacher);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Elab Teacher Information</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	<script type="text/javascript" src="http://www.i2u2.org/elab/cosmic/include/elab.js"></script>

<script type="text/javascript">
	window.onload=function(){
	 hideAll(1,9);
}
function showAll(start, finish)
	{
	for (var i = start; i < finish; i++) {
		showObj = document.getElementById("vsId" + i +"-h").style;
		hideObj = document.getElementById("vsId" + i +"-v").style;
		hideObj.visibility = "hidden";
		hideObj.display = "none";
		showObj.visibility = "visible";
		showObj.display = "";
	}
}
	function hideAll(start, finish)
	{
	for (var i = start; i < finish; i++) {
		hideObj = document.getElementById("vsId" + i +"-h").style;
		showObj = document.getElementById("vsId" + i +"-v").style;
		hideObj.visibility = "hidden";
		hideObj.display = "none";
		showObj.visibility = "visible";
		showObj.display = "";
	}
}
	
	</script>
	</head>

	<body id="teacher" class="teacher">
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

<h1>Teacher Home - Bookmark It!</h1>
				<%@ include file="../include/check-javascript.jsp" %>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		
		<td><div id="expandHeading">
				<P>Click on each topic or its arrow to expand it. Click again to collapse it. Click on <b>Expand All Topics</b> or <b>Collapse All Topics</b> to expand or collapse all the content on the page. These
				only work when you have Javascript enabled in your web browser.
				<div id="all-v" style="text-align:center; visibility:visible; display:"><a href="#" onclick="HideShow('all-v');HideShow('all-h');showAll(1,9);return false;">Expand All Topics</a></div>
				<div id="all-h" style="text-align:center; visibility:hidden; display: none"><a href="#" onclick="HideShow('all-v');HideShow('all-h');hideAll(1,9);return false;">Collapse All Topics</a></div>
				



				<div id="vsId1-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
								</div><div id="vsId1-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
				<p>Students can join a scientific collaboration in this series of studies of high-energy collisions from the Large Hadron Collider
				(LHC) at CERN. We are collaborating with the Compact Muon Solenoid (CMS) experiment to produce a student-led, <b>teacher-guided</b>
				project. At the present, we have test beam, Monte Carlo (simulated) data and run data. We expect more data through 2010 and 2011.
				By using the web, students are able to analyze and share these data   with fellow students and other researchers. Students write
				a researchable question and analyze data in much the same way as professional scientists. e-Lab tools facilitate collaboration among
				students as they develop their investigations and report their results.</p>
				<p>Students begin their investigation by watching a Cool Science video to understand the context of their project. They can perform one of several calibration studies AND TOM L. They can use the project milestones to guide their research and can record their work and reflect on their progress in their e-Logbook. Students post the results of their studies as online posters. The real scientific collaboration follows. Students can review the results of other studies online comparing data and analyses. Using online tools, they can correspond with other research groups, post comments and questions, prepare summary reports and, in general, participate in the part of scientific research that is often left out of classroom experiments.</p>

				<p>Coming later this year: two posters, one that meets expectations and one that exceeds expectations.</p>

					</div>
				
				<div id="vsId2-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Introduction to CMS</h2></a>
									</div><div id="vsId2-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Introduction to CMS</h2></a>
				
				<p>Situated in the LHC, the CMS detector is studying proton-proton collisions in search of the predicted Higgs boson that may be instrumental in explaining why particles have mass and other crucial physics questions. Pions, muons, electrons, photons, neutrinos and other particles are produced in these collisions and subsequent decays. By exploring the various subdetectors arrayed to detect this myriad of collision products and by attending to the crucial roles played by conservation of mass, momentum and charge in event analysis, students are able to make sense of the same plots which particle physicists use in analyzing collision data. They can in turn produce their own plots and use these to set up and pursue questions they themselves put to the data.</p>
				
				<p>Visit the <a href="http://cms.web.cern.ch/cms/index.html" target="cms">CMS</a> website to get more background.

					</div>
				<div id="vsId3-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Good Research Questions</h2></a>
									</div><div id="vsId3-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Good Research Questions</h2></a>
				<p>What kinds of particles are produced in the proton-proton collisions inside the CMS detector? What are the smallest known particles?  Students can pose a number of questions and then analyze the data for answers. Some answers are new to students but well answered by physicists. These include the smallest known particles, the kinds of particles that are produced in proton-proton collisions and how these produced particles interact with the detector. However, some questions like "Is there a Higgs boson?" or "What causes objects to have mass?" are open questions that the CMS Collaboration hopes to address. </p>
				<p>Students may be able to contribute insights to these efforts. Many experiments have been investigating the smallest particles. For example, the top quark was discovered at the accelerator at Fermi National Accelerator Laboratory by the CDF and D&Oslash; collaborations. Students will be able to see the results of other researchers in this field. Students can explore simulated data, and once the real data becomes available, they can enter into the CMS research effort by analyzing run data, comparing it to simulated data, and sharing it with a collaboration of their peers.</p>
 				</div>

						<div id="vsId4-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
								</div><div id="vsId4-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
				<p>Before doing this project, students should know how to:</p> 
				<ul>
					<li>Make basic measurements.</li>
					<li>Make basic calculations.</li>
					<li>Interpret basic graphs.</li>
					<li>Write a research question.</li>
					<li>Make a research plan.</li>
				</ul>
				<p>We provide refresher references for students who need to brush up on these skills. Students access these from "The Basics" section of the <a href="../home/index.jsp" target="show">Project Map</a>. </p>
				</div>
						<div id="vsId5-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
								</div><div id="vsId5-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
				<p>Students will know and be able to:</p>  
				<ul>
					<li>Content and Investigation:
						<ul>
							<li>Describe particles colliding in and emerging from collisions detected by CMS as predicted by the Standard Model.</li>
							<li>List in order and describe the CMS subdetectors in terms of the properties of the particles they detect.</li>
							<li>Explain the role that conservation of mass/energy, momentum, and charge play in analyzing events detected at CMS.</li>
							<li>Analyze data plots in order to extract and describe the physical meaning of any apparent features.</li>
							<li>Design, conduct and report on an investigation of a testable hypothesis for which evidence can be provided using CMS data.</li> 								
						</ul>
					</li>
					<%@ include file="learner-outcomes.jsp" %>
				</ul>
				<p>Assessment is aligned to learner outcomes. While many teachers will want to design their own assessments, we provide some options. </p>

				<ul>
					<li>
						<b>Rubrics:</b> <a href="../assessment/rubric-ci.html">Content &amp; Investigation</a>,
						<a href="../assessment/rubric-r.html">Process</a>, <a href="../assessment/rubric-t.html">Computing</a>,
						<a href="../assessment/rubric-wla.html">Literacy</a> and <a href="../assessment/rubric-p.html">Poster</a>
					</li>
										
					<c:choose>
						<c:when test="${teacher == true }">
							<li>
								<b>Tests</b>: <a href="../survey/survey.jsp?type=pre&studentid=0&id=2">Pre</a>- and <a href="../survey/survey.jsp?type=post&studentid=0&id=2">post</a>-tests of content knowledge
								and student results for 
								<a href="../survey/results.jsp?type=pre">pre</a>- 
								and <a href="../survey/results.jsp?type=post">post</a>-tests.
							</li>
						</c:when>
						<c:otherwise>
							<li>
								<b>Tests</b>: Pre- and post-tests of content knowledge and reporting tools for student results. 
							</li>
						</c:otherwise>
					</c:choose>
						
					<li>
						<b>e-Logbooks:</b> Track progress and provide feedback on student work.<br />
						Review student evidence of what they know/understand and reflections on their research.<br /> 
						Review all student entries for a particular milestone&mdash;e.g., describe CMS physics&mdash;and make notes in your teacher's logbook for next year. 
						Look at this <a href="#" onclick="javascript:window.open('../graphics/logbook-sample.gif', 'content', 'width=504,height=373, resizable=1, scrollbars=1');return false;">sample logbook</a>.
					</li>
					<li>
						<b>Milestone Seminars:</b> Check student understanding before they move from one section of the project milestones to another. 
					</li>
				</ul>
				
				</div>
						<div id="vsId6-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
								</div><div id="vsId6-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
					<p>
				A good way to begin CMS studies is to invite the class to watch <b>Cool Science</b>
				together. Play the <a href="../home/cms-animation-wobutton.swf">Standalone Movie</a> and enlarge the window.</p>
				<P>Questions to ask students? How to motivate students. TOM</P>
				<p>Milestones on the Project Map provide opportunities for students to build basic scientific skills,  learn how the detector works,  understand subatomic particles, learn how to use the analysis tools, use plots to explain results an post the results of their studies as online posters.
				Students should look through the posters to gain ideas for research questions.</p> 
				

 
				<p>
				<b>Calibration Studies: For Teachers</b> - Calibration studies explore the "rediscovery" of known physical quantities to verify the proper operation of the CMS detector. This is the rough equivalent of verifying that a scale is working properly by weighing an object whose mass is independently well known. The approxiamte rest masses of the J/Psi - 3.1 GeV, Upsilon - 9.46 GeV, and the Z boson - 91.Gev are the well-known objects in this CMS e-Lab calibration exercise. These rest masses are determined through measurement of the combined kinetic energies of the particles (a muon-antimuon pair) into which it decays.</p>
				<p>
				Conservation of energy is the principle justifying this derivation of the mass of the parent (the J/PSi, Upsilon or Z boson) from the total energy of its dimuon offspring. Conservation of charge is verified by also exploring the possibility of like-signed children (mu+mu+, or mu-mu-); none of these are found in energy (referred to in this study, following the convention of particle physicists, as "mass") measurements of these like-charged combinations of leptons. In the advanced mode, conservation of lepton number can also be verified by looking at oppositely charged combinations of different leptons (e+mu-, for example).</p>
				<p>
				With simulated data these studies require deliberate creation of file types with particles and any background simulated intentionally, one particle type at a time; the results are thus a bit messy. But the steps students take in the e-Lab are the same as they with run data, and the conclusions they can reach are similar: that the (simulated) detector is functioning properly, since it verifies well-known physics results. With run data the whole process becomes cleaner: all particles and background will be delivered by nature, and the same data set will contain multiple points of verification. Events passing the dimuon filter, for example, will contain J-Psi, Upsilon,  and Z signatures, as well as a range of background that passes the filter's requirements. That same data set can be used to see reflections of conservation of energy, charge and lepton number, as well as energy-momentum rough equivalence (given the relatively small rest masses of muons, compared to the high energies involved in LHC collisions.)</p> 
				<p>
				<b>Momentum-Energy Study: For Teachers</b> - <b>E<sup>2</sup> = P<sup>2</sup> + M<sup>2</sup></b>. (TOM introductory motivational material to this: a derivation, perhaps?)</p>
				<p>
				This exercise will highlight two important points for students:</p>
				<p>
				1. In high-energy physics (HEP), the rest mass term is often negligible. Certainly for the lighter, more stable particles that last for very long, since the energies and momenta are so relatively large. (Without awareness of this fact, students will be unable to think their way through the application of conservation laws to the interpretation of CMS data.)</p>
				<p>
				2. Transverse momentum is an especially important quantity in HEP. LHC is a proton-proton collider. But because the energies involved are sufficient in a direct collision to overcome the electromagnetic repulsion of these particles, it is the partons (quarks and gluons) that are colliding in the highest-energy collisions. Since the portion of the energy of the proton present in any parton is unknown, the initial energies and momenta of primary collisions are not known in advance. So while total energy and momenta can be calculated for LHC collisions in a variety of ways, they are not known in advance. What is known from measurement is the quantity of energy deposited in the calorimeters. For small particles, that energy is equivalent to the initial momentum. What is also known at the LHC is that in the primary collisions, particles are carefully steered along the z axis (the beam line), and thus have very small components of transverse momentum (momentum that is radial, orthogonal to the beam line). So initial transverse momentum for primary collisions is treated as zero. Transverse momentum (P<sub>t</sub>) for secondary collisions can be calculated through procedures that this exercise will help to motivate (from tracker, calorimeter and timing data.) From that calculated Pt, missing transverse momentum can be used to identify missing energy, neutrinos (not directly observed in CMS) can be identified, and coherent event reconstruction becomes possible.</p>
				<p>
				This exercise will begin by presuming that students know that electron mass (at roughly ?? KeV) is negligible for LHC collisions and thus that momentum and energy are equivalent for electron pair production (one electron, one positron, hereafter, ee), as well as the definition of transverse momentum. By looking at Z &rarr; ee data, students will use transverse momentum to verify for themselves the equivalence of energy and momentum for that subset of particles, all of whose momentum is in a transverse direction.</p>
				<p>
				SCREENCAST
				</p><p>
				Discuss with students the difference between the Pt vs. E plots  from both before and after the "low-eta" cut was applied to the data. Students should leave the discussion understanding that our selection of low-eta events was in effect a selection of events, all of whose momentum was in the transverse (radial) direction. (We looked at P<sub>t</sub>, rather than P, simply because P was not available in our analysis tool, but also because Pt of the primary colliding particles is known in advance to be essentially zero. Particle physicists thus use P<sub>t</sub> to reconstruct events from this zero-P<sub>t</sub> initial state. That's why P<sub>t</sub>, not P, is present in our investigations.) Since all of P is P<sub>t</sub> for the low-eta selected set of events, then energy should be equivalent to P<sub>t</sub>, as we see that it is. This exercise presumed and then verifies the presumption that electron mass is negligible: if it weren't, then energy and momentum would not be equivalent, as we can see through this exercise that they plainly are in the simulated data.
				</p><p>Some students may want to look at the same plot after applying a high-eta cut, as well, where (as in the uncut version, only to a more magnified extent) the P<sub>t</sub> and E values will diverge. Students may also be interested in repeating the study for Z-zero to dimuon events.
				</p>
				
				</div>
				
				<p>
					<H2>&nbsp;&nbsp;&nbsp;<a href="web-guide.jsp">Navigating Students Through the e-Lab</a></H2>

						<div id="vsId7-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Help Desk</h2></a>
								</div><div id="vsId7-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Help Desk</h2></a>
					<p>
				<p>
					      <table style="margin-left:20px"><tr><td>Use the <a href="/elab/cms/teacher/forum/HelpDeskRequest.php?elab=CMS" class="external text" title="/ elab/cms/teacher/forum/HelpDeskRequest.php?elab=CMS" rel="nofollow">Help Desk Form</a> to get technical assistance from I2U2 staff. Click on the lifesaver
					     icon in the upper right hand corner of the teacher pages when you are logged in.</td><td><img src="../graphics/Lifesaver.png"></td></tr></table>
						</p>
					</div>
					
					<div id="vsId8-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId8-v');HideShow('vsId8-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> e-Lab Technology Requirements</H2></a>
								</div><div id="vsId8-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId8-v');HideShow('vsId8-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> e-Lab Technology Requirements</H2></a>
						<p>
						Relax!  The e-Lab requires Javascript and Plug-ins enabled in your Web browser. Most browsers default to these settings.</p>  
						<ul>
						<li>If Javascript is not enabled, you will see a message on the student home page and at the top of this page.</li>
						<li>If Plug-ins are not enabled, you won't see the Flash movie on the student home page.</li>
						</ul>
						<p>
						 Ask your tech support person if you need help with browser settings. The Resources in the Library and the background material may include YouTube videos and java applets, but these are not critical for using the e-Lab.</p>  
						</p>
					</div>

					
					
                </div>
             </div>
		</td>
		<td>
			<div id="right">
				<%@ include file="../include/newsbox.jsp" %>
				<jsp:include page="../login/login-control.jsp"/>
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
