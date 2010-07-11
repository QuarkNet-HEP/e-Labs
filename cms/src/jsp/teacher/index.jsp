<%@ include file="../include/elab.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Elab Teacher Information</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
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

<%
	// Check if the teacher is in the study
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	boolean newSurvey = false;  
	
	if (user != null) {
		if (user.getRole().equalsIgnoreCase("teacher")) {
			newSurvey = elab.getSurveyProvider().hasTeacherAssignedSurvey(user.getId());
		}
		request.setAttribute("userId", user.getId());
	}
	request.setAttribute("newSurvey", newSurvey);
%>

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
Students can join a scientific collaboration in this series of studies of high-energy collisions from the Large Hadron Collider (LHC) at CERN. We are collaborating with the Compact Muon Solenoid (CMS) Experiment to produce a student-led, teacher-guided project. At the present we have both test beam and Monte Carlo (simulated) data for analysis; run data is expected by 2011. By using the web students are able to analyze and share these data   with fellow students and other researchers.

</p>
				<h2>Milestones on the Project Map :</h2>
				<p>
					Milestones on the Project Map provide opportunities for students to build basic scientific skills,  learn how the detector works,  understand subatomic particles, learn how to use the analysis tools and use plots explain results. Students post the results of their studies as online posters and then review the results of other studies online, comparing data and analyses. Using online tools, they can correspond with other research groups, post comments and questions, prepare summary reports and in general, participate in an aspect of scientific research that is often left out of classroom experiments.</p>
					<p>Read about the <a href="web-guide.jsp">website features</a> that guide and support student research.
				</p>
					 
				
				
				<h2>Introduction to Research:</h2>
				<p>
					The CMS e-Lab explores the potential of using the tools and techniques of research physicists for secondary science education. Like the Cosmic ray e-Lab, this e-Lab provides an opportunity for:<ul>
					<li>	Students to do authentic research using exploratory data tools to access, process and publish data, report and share their results as online posters, and have online discussions with one another about their work.</li>
					<li>Student researchers to experience membership in a scientific collaboration.</li>
					<li>Student researchers to make contributions to the study of particle physics.</li>
				</ul>
					<p>Situated in the LHC, the CMS detector is studying proton-proton collisions in search of the predicted Higgs boson that may be instrumental in explaining why particles have mass and other crucial physics questions. Pions, muons, electrons, photons, neutrinos and other particles are produced in these collisions and subsequent decays. By exploring the various subdetectors arrayed to detect this myriad of collision products and by attending to the crucial roles played by conservation of mass, momentum and charge in event analysis, students are able to make sense of the same plots which particle physicists use in analyzing collision data. They can in turn produce their own plots and use these to set up and pursue questions they themselves put to the data.</p>
					
				<h2>Prior Knowledge and Skills:</h2>
				<p>
					Before doing this project, students should know how to: 
					<ul>
						<li>Make simple measurements.</li>
						<li>Make simple calculations.</li>
						<li>Interpret simple graphs.</li>
						<li>Write a research question.</li>
						<li>Make a research plan.</li>
					</ul>

					We provide refresher references for students who need to brush up on 
					these skills. Students access these from "The Basics" section of the <a href="../home/index.jsp" target="show">Project Map</a>. 
				</p>
				
				<h2>Learner Outcomes and Assessment:</h2>
				<p>
					Students will know and be able to:  
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
				</p>
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
					






	
						<li>
							<b>Tests</b>: <a href="../test/test.jsp?type=presurvey&studentid=0">Pre</a>
							- and <a href="../test/test.jsp?type=postsurvey&studentid=0">post</a>
							- tests of content knowledge and student results for 
							<a href="../test/results.jsp?type=presurvey">pre</a>
							- and <a href="../test/results.jsp?type=postsurvey">post</a>- tests.
						</li>
						
					

				
							<li>
							<b>e-Logbooks:</b> Track progress and provide feedback on student work.<br>
							Review student evidence of what they know/understand and reflections on their research.<br> 
							Review all student entries for a particular milestone&mdash;e.g., describe CMS physics&mdash;and make notes in your teacher's logbook for next year. 
							Look at this <a href="#" onclick="javascript:window.open('../graphics/logbook-sample.gif', 'content', 'width=504,height=373, resizable=1, scrollbars=1');return false;">sample logbook</a>.
							
							</li>
							<li>
							<b>Milestone Seminars:</b> Check student understanding before they move from one section of the project milestones to another. 
							</li>
					
				</ul>
			

				<h2>Research Question:</h2>
				<p>
					What kinds of particles are produced in the proton-proton collisions inside the CMS detector? What are the smallest known particles?  Students can pose a number of questions and then analyze the data for answers. Some answers are new to students but well answered by physicists. These include the smallest known particles, the kinds of particles that are produced in proton-proton collisions and how these produced particles interact with the detector. However, some questions like "Is there a Higgs boson?" or "What causes objects to have mass?" are open questions that the CMS Collaboration hopes to address. 
				</p>
				<p>
					Students may be able to contribute insights to these efforts. Many experiments have been investigating the smallest particles. For example, the top quark was discovered at the accelerator at Fermi National Accelerator Laboratory by the CDF and D0 collaborations. Students will be able to see the results of other researchers in this field. Students can explore simulated data, and once the LHC comes on line they can enter into the CMS research effort by analyzing run data, comparing it to simulated data, and sharing it with a collaboration of their peers.
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
