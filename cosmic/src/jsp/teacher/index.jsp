<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	// Check if the teacher is in the study
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	if (user != null) {
		boolean newSurvey = user.isStudy();
		request.setAttribute("newSurvey", new Boolean(newSurvey));
	}

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Teacher Page</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	<script type="text/javascript" src="http://www.i2u2.org/elab/cosmic/include/elab.js"></script>

	<script type="text/javascript">
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

<h1>Teacher Home - Bookmark It!</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		
		<td><div id="expandHeading">
				<P>Click on each topic or its arrow to expand it. Click again to collapse it. Click on <b>Expand All Topics</b> or <b>Collapse All Topics</b> to expand or collapse all the content on the page.
				<div id="all-v" style="text-align:center; visibility:visible; display:"><a href="#" onclick="HideShow('all-v');HideShow('all-h');showAll(1,8);return false;">Expand All Topics</a></div>
				<div id="all-h" style="text-align:center; visibility:hidden; display: none"><a href="#" onclick="HideShow('all-v');HideShow('all-h');hideAll(1,8);return false;">Collapse All Topics</a></div>
				
				<div id="vsId1-v" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
								</div><div id="vsId1-h" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
				<p>
					Working in a research group, students experience the environment of scientific collaborations 
					in this series of investigations into high-energy cosmic rays. 
					From start to finish this is a student-led, <b>teacher-guided</B> project. 
					Schools with cosmic ray detectors can upload data to the web. 
					A virtual data portal enables students to share these data and 
					associated analysis code with students at other schools whether 
					or not those schools have their own cosmic ray detectors. 
				</p>
<!-- 
					<p>
					Students start this e-lab with an animation that raises
					questions researchers ask about cosmic rays.
				</p>
 -->
				<p>
					Students begin their research by watching a Cool Science video to understand the context of they project. They check the performance of the detectors they 
					have chosen for their study. Then they can perform one of three 
					investigations: muon lifetime, muon flux or extended air showers. 
					Students can use the project milestones to conduct their research and
					can record their work and reflect on their progress in their e-Logbook. Students post the results of their studies as online posters. 
					The real scientific collaboration follows. Students can 
					review the results of other studies online comparing data and 
					analyses. Using online tools, they can correspond with other 
					research groups, post comments and questions, prepare summary 
					reports and, in general, participate in the part of scientific 
					research that is often left out of classroom experiments. 
				</p>
				<p> Two Posters, one that meets expectations - 
				<a href="#" onclick="javascript:window.open('..\/posters\/display.jsp?name=effect_of_roof_on_muon_detector.data', 'poster', 'width=700,height=900, resizable=1, scrollbars=1');return false;">Effect of Roof on Muon Detector</a> (Shaffer)
				- and one that excedes expectations - <a  href="#"  onclick="javascript:window.open('..\/posters\/display.jsp?name=callisto_poster.data', 'poster', 'width=700,height=900, resizable=1, scrollbars=1');return false;">Effect of Leonid Meteor Shower on Cosmic Ray Detection</a> (Gosling).</p>
				
					</div>
					
				<div id="vsId2-v" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Introduction to Cosmic Ray Research</h2></a>
									</div><div id="vsId2-h" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Introduction to Cosmic Ray Research</h2></a>
				<p>
					Cosmic rays are typically protons, neutrons, gamma rays or other 
					particles that originate in any number of astronomical objects. 
					When these "primary" cosmic rays encounter earth's atmosphere, they 
					can interact with nuclei of atoms and produce new, often unstable 
					particles (e.g., pions and kaons). In turn, these secondary cosmic 
					rays further decay and create muons, electrons, photons and neutrinos. 
					If these cosmic rays are sufficiently energetic, they can reach the 
					earth's surface and be detected. (Neutrinos are capable of passing 
					through the earth and are generally undetected.) 
				</p>
				<p>
					Occasionally the primary cosmic ray possesses tremendous energy, creating
					many decay products. An array of detectors on the earth's 
					surface can indirectly measure the energy of the primary by counting 
					the number of particles in the detector array simultaneously. These 
					observations can lead to a calculation of the part of the sky that 
					the primary came from. Many experiments have measured cosmic array showers, including 
					<a href="http://en.wikipedia.org/wiki/Chicago_Air_Shower_Array">CASA</a> 
					(Chicago Air Shower Array), project <a href="http://www.nd.edu/~grand/index.html">G.R.A.N.D.</a>  
					(Gamma Ray Astrophysics at Notre Dame) and the <a href="http://www.auger.org/">Pierre Auger 
					Project</a> (an array in Argentina). 
				</p>
					</div>
				
				<div id="vsId3-v" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Good Research Questions</h2></a>
									</div><div id="vsId3-h" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Good Research Questions</h2></a>
				<p>
					How much area can a cosmic ray shower cover? Where do cosmic 
					rays come from? Students can pose a number of questions and 
					then analyze the data for answers. Some answers are new to 
					students but well answered by physicists. These include the 
					muon lifetime, rate of cosmic ray arrival as well as the 
					source of low-energy air showers. However, the origin of the 
					highest-energy cosmic rays is an open question&mdash;scientists are trying
					to answer this question now. Students may be 
					able to contribute data to these efforts.
					Students will be able to look into the size of cosmic ray 
					showers by comparing their cosmic ray detector data with that 
					from others across a wide area to see where particles struck 
					earth's surface in closely correlated time windows. (Data contain time and geographic location information.)  
					Students will be a part of this ongoing research by providing 
					data to a collaboration of their peers. 
				</p>
				
				</div>
				<div id="vsId4-v" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
						</div><div id="vsId4-h" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
				<p>
					Before doing this project, students should know how to: 
				</p>
				<ul>
					<li>Make simple measurements.</li>
					<li>Make simple calculations.</li>
					<li>Interpret simple graphs.</li>
					<li>Write a research question.</li>
					<li>Make a research plan.</li>
				</ul>
				<p>
					We provide refresher references for students who need to brush up on 
					these skills. Students access these from "The Basics" section of the <a href="../home/index.jsp" target="show">Project Map</a>. 
					</p>
					</div>
					
					<div id="vsId5-v" style="visibility:visible; display:">
					<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
							</div><div id="vsId5-h" style="visibility:hidden; display: none">
					<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
					<p>
						Students will know and be able to: 
					</p>
					<ul>
						<li>
							Content and Investigation:
							<ul>
								<li>Identify cosmic ray sources and describe how the resulting muons are created in the atmosphere.</li> 
								<li>Explain what the cosmic ray detector measures.</li> 
								<li>Manipulate the data in a way that helps them understand characteristics of the muon.</li> 
								<li>Design an investigation that asks a testable hypothesis, which can be answered from the cosmic ray data and provides a description of cosmic ray phenomena.</li> 
 
							</ul>
						</li>
							
							<%@ include file="learner-outcomes.jsp" %>
					</ul>
					<p>
					Assessment is aligned to learner outcomes. While many teachers will want to design their own assessments, 
					we provide some options. 
					
				</p>

				<ul>
					<li>
						<B>Rubrics:</B> <A HREF="../assessment/rubric-ci.html">Content & Investigation</A>,
						<A HREF="../assessment/rubric-r.html">Process</A>, <A HREF="../assessment/rubric-t.html">Computing</A>,
						<A HREF="../assessment/rubric-wla.html">Literacy</A> and <A HREF="../assessment/rubric-p.html">Poster</A>
					</li>
					<e:restricted role="teacher">
						<li>
							<b>Tests (for groups created before Summer 2009)</b>: <a href="../test/test.jsp?type=presurvey&studentid=0">Pre</a>-
							 and <a href="../test/test.jsp?type=postsurvey&studentid=0">post</a>-tests of content knowledge and student results for 
							<a href="../test/results.jsp?type=presurvey">pre</a>-
							and <a href="../test/results.jsp?type=postsurvey">post</a>-tests.
						</li>
							<li>
								<b>Tests (for groups created after Summer 2009)</b>:
								<a href="../survey/survey.jsp?type=pre&studentid=0">Pre</a>-
								and <a href="../survey/survey.jsp?type=post&studentid=0">post</a>-
								tests of content knowledge and student results for 
								<a href="../survey/results.jsp?type=pre">pre</a>-
								and <a href="../survey/results.jsp?type=post">post</a>-tests.
							</li>
					</e:restricted>
				
							<li>
							<b>e-Logbooks:</b> Track progress and provide feedback on student work.<br>
							Review students' evidence of what they know/understand and reflections on their research.<br> 
							Review all students' entries for a particular milestone, e.g., class cosmic ray descriptions, and make notes in your logbook for next year. 
							Look at this <a href="#" onclick="javascript:window.open('../graphics/logbook-sample.gif', 'content', 'width=680,height=901, resizable=1, scrollbars=1');return false;">sample logbook</a>.
							
							</li>
							<li>
							<b>Milestone Seminars:</b> Check student understanding before they move from one section of the project milestones to another. 
							</li>
					
				</ul>
			
					 
					</div>
				
				<div id="vsId6-v" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
						</div><div id="vsId6-h" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
				<div style="margin-left: 20px">
				<p>A good way to begin cosmic ray studies is to invite the class to watch Cool Science together. Play the <a href="">Standalone Movie</a> and enlarge the window.
				</p>
				<p>Questions to ask students? How to motivate students. BOB</p>
				
				<a name="Cosmic_Ray_Detector"></a><h4>Detectors Students Use</h4>
				<p>The data for this e-Lab comes from detectors operated by high school students around the world. If you have a detector, you should become familiar with
				how to set it up and take data.  Read this <a href="detector.jsp">Introduction to the QuarkNet cosmic ray detector</a>.  Pending funding, if you would like a detector and you are
				a member of QuarkNet, contact <a href="mailto:rspete@fnal.gov">Bob Peterson</a> or if you are not a member of QuarkNet, contact <a href="mailto:jordant@fnal.gov">Tom Jordan</a> to purchase
				a detector.  Fermilab gathers the requests, place orders for the parts in early spring and fills the orders throughout the summer.
				</p>

				<a name="Experiments_Students_Can_Perform"></a><h4>Experiments Students Can Perform</h4>
				<p>
					<b>Calibrations and performance studies</b> - Before students can "trust" the cosmic ray equipment, they 
					should do some calibrations to study the response of the 
					counters and the board. Calibration studies include 
					plateauing the counters, threshold selection and barometer 
					calibration. In addition, the QuarkNet online analysis 
					tools include a "system performance" study for uploaded data.
					</p>
					<p>
					<b>Flux Experiments</b> - Students can do a variety of flux experiments 
					investigating such things as cosmic ray flux as a function of 
					time of day, solar activity, angle from vertical, barometric 
					pressure, altitude. The list goes on. This can be an exciting 
					set of experiments as students study the factors that they 
					want to test.</p>
					
					<p>
					<b>Muon Lifetime Experiments</b> - A classic modern physics experiment to verify time dilation 
					is the measurement of the muon mean lifetime. Since nearly all 
					of the cosmic ray muons are created in the upper part of the 
					atmosphere (&gt;&gt;30 km above the earth's surface), the time of 
					flight for these muons as they travel to earth should be at 
					least 100 microseconds: <p>
  <img class='tex' src="../graphics/tof_equation.gif" />
</p>
				<p>
					This calculation assumes that muons are traveling at the speed 
					of light - anything slower would require even more time. If a 
					student can determine the muon lifetime and show that it is 
					significantly less than this time, they are presented with the 
					wonderful dilemma that the muon's time of flight is longer than 
					its lifetime! 
				</p>
				<p>
					This time dilation "proof" assumes that all muons are created in 
					the upper atmosphere. Although this is actually a good 
					approximation, students cannot test it. However, by using 
					the mean lifetime value and by measuring flux rates at two 
					significantly different elevations, one can develop experimental 
					proof for time dilation. This experiment requires 
					access to a mountain, an airplane, or collaboration with a team 
					from another school that is at a significantly different altitude! 
					Here is a wonderful opportunity for schools to work together 
					proving time dilation. A very thorough explanation of this 
					experiment is outlined in the 1962 classroom movie titled, "Time 
					Dilation: An Experiment with Mu Mesons." (This 30 minute movie 
					can be ordered on CD for $10 from www.physics2000.com/.)   This 
					movie helps students understand how to verify time dilation using the muon 
					lifetime measurement (along with flux measurements at two 
					different altitudes).
					</p>
					<p>
					<b>Shower Studies</b> - With the GPS device connected to the DAQ board, the absolute 
					time stamp allows a network of detectors (at the same site or at 
					different schools) to study cosmic ray showers. Students 
					can look for small showers or collaborate with nearby schools to look for larger showers. 
			
					The QuarkNet online analysis tools allow students to not only 
					look for showers but to calculate the direction from which the 
					shower (and thus the primary cosmic ray) originated.</p>
					
					<p><b>Other Studies Devised by Students</b></p
					</div>
				
				
			
					</div>
			
					<H2>&nbsp;&nbsp;&nbsp;<a href="web-guide.jsp">Navigating Students Through the e-Lab</a></H2>

						<div id="vsId7-v" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Help Desk</h2></a>
								</div><div id="vsId7-h" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Help Desk</h2></a>
				<p>
					      <table style="margin-left:20px"><tr><td>Use the <a href="/elab/cosmic/teacher/forum/HelpDeskRequest.php?elab=cosmic" class="external text" title="http://www.i2u2.org/elab/cosmic/teacher/forum/HelpDeskRequest.php?elab=Cosmic" rel="nofollow">Help Desk Form</a> to get technical assistance from I2U2 staff. Click on the lifesaver
					     icon in the upper right hand corner of the teacher pages when you are logged in.</td><td><img src="../graphics/Lifesaver.png"></td></tr></table>
				</p> 
				

 
				
				
 
				
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