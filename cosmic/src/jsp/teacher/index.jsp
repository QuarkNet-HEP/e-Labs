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
		
		<td>
			<div id="center">
				<h2>Abstract:</h2>
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
					To begin their research, students check the performance of the detectors they 
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
				

				<p>
					Read about the <a href="web-guide.jsp">website features</a> that guide and support student research.
				</p>
				
				<h2>Introduction to Research:</h2>
				<p>
					The Cosmic Ray e-Lab provides
					an opportunity for:
				</p>
				<ul>
					<li>
						Students to do authentic research using exploratory virtual 
						data tools to access, process and publish data, report and 
						share their results as online posters, and have online 
						discussions with one another about their work. 
					</li>
					<li>
						Student researchers to experience the environment of 
						scientific collaborations. 
					</li>
					<li>
						Student researchers to make real contributions to the study 
						of high-energy cosmic rays.
					</li>
				</ul>
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
					the primary came from.
				</p>
				
				<h2>Prior Knowledge and Skills</h2>
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
					
				<h2>Learner Outcomes and Assessment:</h2>
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
			
					 
				
				<h2>Research Question:</h2>
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

					Many experiments have measured cosmic array showers, including 
					<a href="http://en.wikipedia.org/wiki/Chicago_Air_Shower_Array">CASA</a> 
					(Chicago Air Shower Array), project <a href="http://www.nd.edu/~grand/index.html">G.R.A.N.D.</a>  
					(Gamma Ray Astrophysics at Notre Dame) and the <a href="http://www.auger.org/">Pierre Auger 
					Project</a> (an array in Argentina). 
				</p>
				<p>
					Students will be able to look into the size of cosmic ray 
					showers by comparing their cosmic ray detector data with that 
					from others across a wide area to see where particles struck 
					earth's surface in closely correlated time windows. (Data contain time and geographic location information.)  
					Students will be a part of this ongoing research by providing 
					data to a collaboration of their peers. 
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