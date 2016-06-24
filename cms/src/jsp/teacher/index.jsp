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
		<script type="text/javascript" src="../../cosmic/include/elab.js"></script>

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
				<p>Getting ready for the Next Generation Science Standards? This e-Lab meets ALL NGSS science practices. See Standards link in the menu for listing.</p>
				<P>Click on each topic or its arrow to expand it. Click again to collapse it. Click on <b>Expand All Topics</b> or <b>Collapse All Topics</b> to expand or collapse all the content on the page. These
				only work when you have Javascript enabled in your web browser.
				<div id="all-v" style="text-align:center; visibility:visible; display:"><a href="#" onclick="HideShow('all-v');HideShow('all-h');showAll(1,9);return false;">Expand All Topics</a></div>
				<div id="all-h" style="text-align:center; visibility:hidden; display: none"><a href="#" onclick="HideShow('all-v');HideShow('all-h');hideAll(1,9);return false;">Collapse All Topics</a></div>
			
				<div id="vsId1-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
								</div><div id="vsId1-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId1-v');HideShow('vsId1-h');return false;"><H2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> e-Lab Summary</H2></a>
				<p>Students can join a scientific collaboration in this series of studies of high-energy collisions 
				   from the Large Hadron Collider (LHC) at CERN. We are collaborating with the Compact Muon Solenoid 
				   (CMS) experiment to produce a student-led, teacher-guided project. We have authentic data from 
				   well over 200,000 proton-proton collision events in CMS. By using the web, students are able to 
			       analyze and share these data with fellow students and other researchers. Students write a 
				   researchable question and analyze data in much the same way as professional scientists. Tools from the e-Lab  
				   facilitate collaboration among students as they develop their investigations and report their 
				   results.
				</p>
				
				<p>Students begin their investigation by watching a Cool Science video to get some insight into the 
				   context of their project. They can then use a variety of data exploration tools to perform studies 
			       and develop their own investigation. They can use the project milestones to gain some necessary 
				   background and guide their research.  Also, they can record their work and reflect on their progress in 
				   their e-Logbook. Students post the results of their studies as online posters. The real scientific 
				   collaboration follows. Students can review the results of other studies online, comparing data and 
				   analyses. Using online tools, they can correspond with other research groups, post comments and 
				   questions, and participate in the part of scientific research that is often left out of 
				   classroom experiments.
				</p>

				<p>These two posters, one that <a href="../posters/display.jsp?name=zboson_decay-cms-gagnon-michael_cartwright-mounds_view_high_school-arden_hills-mn-2015.0421.data" target="_blank">meets expectations</a>, and one that 
				   <a href="../posters/display.jsp?name=poster_muonetavspt-cms-khendrix-kurt_hendrix-dundalk_high_school-dundalk-md-2015.0724.data" target="_blank">exceeds expectations</a>, can help guide 
				   teachers to set expectations for their own students and understand what students can accomplish.
				</p>
				
				</div>
				
				<div id="vsId2-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Introduction to CMS</h2></a>
									</div><div id="vsId2-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Introduction to CMS</h2></a>
				
				<p>The CMS detector studies proton-proton collisions from the LHC in search of new physics.  Myriad particles are produced from these collisions and subsequent decays.  By exploring the various subdetectors arrayed to detect these collision products and by attending to the crucial roles played by conservation of mass-energy, momentum and charge in event analysis, students are able to make sense of the plots particle physicists use to analyze collision data. They can in turn produce their own plots and use these to set up and pursue questions they themselves put to the data.</p>
				<p>Visit the <a href="http://cms.web.cern.ch/" target="cms">CMS</a> website to get more background.

					</div>
				<div id="vsId3-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Good Research Questions</h2></a>
									</div><div id="vsId3-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Good Research Questions</h2></a>
				
				<p>What kinds of particles are produced in the proton-proton collisions inside the CMS detector? What are the smallest known particles? Students can pose a number of questions and then analyze the data for answers. Some answers are new to students but well answered by physicists. These include the smallest known particles, the kinds of particles that are produced in proton-proton collisions and how these produced particles interact with the detector. However, there are still many questions that the CMS collaboration hopes to address.</p>
				<p>Students may be able to contribute insights to these efforts by looking at the data in fresh ways. What can they learn about the behavior of particles? About the CMS detector itself?</p>
				<p>Examples of research questions correlated with the <a href="../assessment/rubric-p.html" target="poster">poster rubric</a> are:</p>
<ul>
<li><b>Exceeds Expectations</b>: Does the width of the distribution of the Z signature in the dimuon mass spectrum vary as a function of transverse momentum?

<li><b>Meets Expectations</b> Do all portions of the detector report the same value for the mass of the Z boson?

<li><b>Does not Meet Expectations</b>: Can mini black holes be found in CMS data?
</ul>
 				</div>

						<div id="vsId4-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
								</div><div id="vsId4-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
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
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
								</div><div id="vsId5-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
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
						<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
								</div><div id="vsId6-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId6-v');HideShow('vsId6-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Suggestions for Getting Started</h2></a>
					<p>Students can start with simple studies and then increase the sophistication. Initial investigations might include finding the mass of the Z boson and seeing how many particle \"bumps\" they can find in the dimuon and dielectron mass spectra. They can then see the effects of various cuts on the data. How is the J/Psi mass plot affected by including only events with two \"global\" muon tracks? How does a high transverse momentum cut affect the results of a plot? How about varying eta, the pseudorapidity?</p>
				    <p>Students can also probe the performance of the detector. Are the distribution momenta and energies uniform as angle phi around the beampipe is varied? At what value of eta do they maximize, and where do they disappear? Why?</p>
				</div>
				
				<p>
					<H2>&nbsp;&nbsp;&nbsp;<a href="web-guide.jsp">Navigating Students Through the e-Lab</a></H2>

						<div id="vsId7-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Help Desk & Sharing Ideas</h2></a>
								</div><div id="vsId7-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Help Desk & Sharing Ideas</h2></a>
					<p>
					<p>
					      <table style="margin-left:20px"><tr><td>Use the <a href="/elab/cms/teacher/forum/HelpDeskRequest.php?elab=CMS" class="external text" title="/ elab/cms/teacher/forum/HelpDeskRequest.php?elab=CMS" rel="nofollow">Help Desk Form</a> to get technical assistance from our staff. Click on the lifesaver
					     icon in the upper right hand corner of the teacher pages when you are logged in.</td><td><img src="../graphics/Lifesaver.png"></td></tr>
					     <tr><td colspan="2">Be sure to click on <b>Share Ideas</b> to see what other teachers have shared in Facebook. They may have the answers to your questions. You may have answers to theirs! Maybe you want to collaborate on a study.</td></tr>
					     </table>
					</p>
					</div>
					
					<div id="vsId8-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId8-v');HideShow('vsId8-h');return false;"><H2><img src="/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> e-Lab Technology Requirements</H2></a>
								</div><div id="vsId8-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId8-v');HideShow('vsId8-h');return false;"><H2><img src="/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> e-Lab Technology Requirements</H2></a>
						<p>
						Relax!  The e-Lab requires Javascript and Plug-ins enabled in your Web browser. Most browsers default to these settings.</p>  
						<ul>
						<li>If Javascript is not enabled, you will see a message on the student home page and at the top of this page.</li>
						<li>If Plug-ins are not enabled, you won't see the Flash movie on the student home page.</li>
						</ul>
						<p>
						 Ask your tech support person if you need help with browser settings. The Resources in the Library and the background material may include YouTube videos and java applets, but these are not critical for using the e-Lab.</p>  
						</div> 
				</p>
					</div><!-- end expandHeading -->
		</td>
		<td>
			<div id="right">
				<%@ include file="../include/newsbox.jsp" %>
				<jsp:include page="../login/login-control.jsp">
					<jsp:param name="login_as" value="teacher" />
				</jsp:include>
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
