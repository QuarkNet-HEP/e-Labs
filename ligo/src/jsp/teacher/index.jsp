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
		<title>LIGO Elab Teacher Information</title>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="teacher" class="teacher">
		<!-- entire page container  -->
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
					At this Web site students will work with scientific data from  LIGO, 
					the Laser Interferometer Gravitational-wave Observatory. Students 
					will design and execute an inquiry-based investigation in much the 
					same way as a professional scientist. e-Lab tools will facilitate 
					collaboration between students as they develop their projects and 
					report their results.
				</p>
				<p>
					Read about the <a href="web-guide.jsp">website features</a> that guide and support student research.
				</p>
				
				<h2>Introduction to Research:</h2>
				<p>
					LIGO's huge laser interferometers in 
					<a href="http://www.ligo-wa.caltech.edu">Washington State</a> and in 
					<a href="http://www.ligo-la.caltech.edu">Louisiana</a>
					listen for the faint ripples of space-time called gravitational waves.
					LIGO seeks to detect gravitational waves from the collisions of black 
					holes or neutron stars and from star explosions known as supernovae. 
					These interferometers are capable of measuring movements that are 
					smaller than one thousandth of the diameter of a proton. Because the 
					detectors are built on the ground, vibrations of the ground can affect 
					their operation. Consequently, LIGO closely monitors ground vibrations 
					through an array of seismometers that are mounted at each Observatory. 
					Students can use data from these seismometers to explore a wide vareity 
					of seismic questions, many of which will have a connection to LIGO's 
					science operations. Make sure your students watch the video in
					<a href="../home/cool-science.jsp">Cool Science</a> to understand
					the context of their research.
				</p>
					
				<h2>Prior Knowledge and Skills:</h2>
				<p>
					Before doing the LIGO e-Lab, students should be comfortable with these 
					skills:
						<ul>
							<li>Make simple measurements</li>   
							<li>Make simple calculations</li>
							<li>Interpret simple graphs</li>
							<li>Write a research question</li>
							<li>Make a research plan</li>
						</ul>
					We provide a refresher for students who need to brush up on these skills.
					Students access these from "The Basics" section of the <a href="../home/index.jsp" target="show">project milestones</a>. 
				</p>
				
				<h2>Learner Outcomes and Assessment:</h2>
				<p>
					Here are the e-Lab outcomes that students must demonstrate:</p> 
					<ul>
						<li>Content and Investigation:
							<ul>
								<li>
									Describe some basic concepts of wave behavior such as speed, arrival time, frequency and amplitude in the context of seismic activity.
								</li>
								<li>
									Describe several factors that cause changes in LIGO's seismic data 
								</li>
								<li>
									Explain how LIGO's measurement of seismic waves contributes to the project's effort to detect gravitational waves.
								</li>
								<li>
									Design an investigation that asks a testable hypothesis, which can be answered from seismic data and provides an explanation of what you learn about seismic data.								
								</li>
							</ul>
							</li>
							
							<%@ include file="learner-outcomes.jsp" %>
			   	</ul>
				</p>
				Assessment is aligned to learner outcomes. While many teachers will want to design their own assessments, 
					we provide some options. 
					
				</p>

				<ul>
					<li>
						<B>Rubrics:</B> <A HREF="../assessment/rubric-ci.html">Content & Investigation</A>,
						<A HREF="../assessment/rubric-r.html">Process</A>, <A HREF="../assessment/rubric-t.html">Computing</A>,
						<A HREF="../assessment/rubric-wla.html">Literacy</A> and <A HREF="../assessment/rubric-p.html">Poster</A>
					</li>
					
					<c:choose>
						<c:when test="${teacher == true }">
							<li>
								<b>Tests</b>: <a href="../survey/survey.jsp?type=pre&studentid=0&id=1">Pre</a>-
								 and <a href="../survey/survey.jsp?type=post&studentid=0&id=1">post</a>-tests of content knowledge
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
							<b>e-Logbooks:</b> Track progress and provide feedback on student work.<br>
							Review students' evidence of what they know/understand and reflections on their research.<br> 
							Review all students' entries for a particular milestone and make notes in your logbook for next year. 
							Look at this <a href="#" onclick="javascript:window.open('../graphics/logbook-sample.gif', 'content', 'width=680,height=400, resizable=1, scrollbars=1');return false;">sample logbook</a>.
							
							</li>
							<li>
							<b>Milestone Seminars:</b> Check student understanding before they move from one section of the project milestones to another. 
							</li>
					
				</ul>
			

				<h2>Research Question:</h2>
				<p>
					Developing a good research question is one of the most challenging 
					parts of the e-Lab for many students. A good research question provides 
					a framework around which the students can build a research plan. Good 
					research questions are testable. "How often do earthquakes happen?" 
					might not be a helpful research question since it doesn't point to a 
					deeper cause-and-effect relationship. "Is there a relationship between 
					how often earthquakes happen and <i>where</i> they happen (epicenter)?" 
					is a better question because the researcher will inevitably be faced 
					with cause-and-effect connections as the reserch plan unfolds. The LIGO 
					e-Lab provides the opportunity for many good research questions based on 
					earthquakes.  Students should look through the on-line discussion rooms
					to gain ideas for research questions.
				</p>
				<p>
				Teachers should look for study ideas under the <b>Community</b> Menu item. Click on Classroom Activities and Notes .</p>
  
				
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