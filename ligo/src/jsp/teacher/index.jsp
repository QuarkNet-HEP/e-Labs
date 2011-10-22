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
	<link type="text/css" href="http://www.i2u2.org/elab/cosmic/include/jquery/css/default/jquery-ui-1.7.custom.css" rel="Stylesheet" />	
	<script type="text/javascript" src="http://www.i2u2.org/elab/cosmic/include/jquery/js/jquery-1.6.1.min.js"></script>
	<script type="text/javascript" src="http://www.i2u2.org/elab/cosmic/include/jquery/js/jquery-ui-1.7.custom.min.js"></script>
	<script type="text/javascript" src="http://www.i2u2.org/elab/cosmic/include/jquery/js/jquery.event.hover-1.0.js"></script>
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
						<p>
						Students can collaboarate to analyze seismic data from  LIGO, 
					the Laser Interferometer Gravitational-wave Observatory. From start to finish 
					this is a student-led, <b>teacher-guided</b> project. 
					Students 
					write a researchable question and analyze data in much the 
					same way as professional scientists. e-Lab tools facilitate 
					collaboration among students as they develop their investigations and 
					report their results.</p><p>
				Students begin their investigation by watching a Cool Science video to understand 
				the context of their project. They can perform one of four studies: earthquake, 
				frequency band, microseismic and human-induced seismic activity. 
				They can use the project 
				 milestones to guide their research and can record their work and reflect on their 
				 progress in their e-Logbook. Students post the results of their studies as online 
				 posters. The real scientific collaboration follows. Students can review the results 
				 of other studies online comparing data and analyses. Using online tools, they can 
				 correspond with other research groups, post comments and questions, prepare 
				 summary reports and, in general, participate in the part of scientific research 
				 that is often left out of classroom experiments.</p><p>
				<p> One sample poster is available. In the future, a poster that exceeds expectations will also be included.</p>
				<ul>
				<li><a href="#" onclick="javascript:window.open('..\/posters\/display.jsp?name=scott_andrew_peter.data', 'poster', 'width=700,height=900, resizable=1, scrollbars=1');return false;">Seismic Wave Travel Time</a> - meets expectations.</li>
				</ul>
						</p>
					</div>
					
				<div id="vsId2-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Introduction to LIGO</h2></a>
									</div><div id="vsId2-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId2-v');HideShow('vsId2-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Introduction to LIGO</h2></a>
						<p>
				<p>
					LIGO's huge laser interferometers in Washington State and in 
					Louisiana
					listen for the faint ripples of space-time called gravitational waves.
					LIGO seeks to detect gravitational waves from the collisions of black 
					holes or neutron stars and from star explosions known as supernovae. 
					These interferometers are capable of measuring movements that are 
					smaller than one thousandth of the diameter of a proton. Because the 
					detectors are built on the ground, ground vibrations can affect 
					their operation. Consequently, LIGO closely monitors these vibrations 
					through an array of seismometers mounted at each Observatory. 
					Students can use data from these seismometers to explore a wide vareity 
					of seismic questions, many of which will have a connection to LIGO's 
					science operations. <br>
					Make sure your students begin with the
					<a href="../home/cool-science.jsp">Cool Science</a> video to understand
					the context of their research.</p>
					<p>
					<a href="http://www.ligo-wa.caltech.edu">LIGO Hanford</a> in Washington State -  
					<a href="http://www.ligo-la.caltech.edu">LIGO Livingston</a> in Louisiana
				</p>
						
					</div>
				
				<div id="vsId3-v" style="visibility:hidden; display: none">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Good Research Questions</h2></a>
									</div><div id="vsId3-h" style="visibility:visible; display:">
				<a href="#" onclick="HideShow('vsId3-v');HideShow('vsId3-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Good Research Questions</h2></a>
				<p>
					Developing a good research question is one of the most challenging 
					parts of the e-Lab for many students. A good research question provides 
					a framework around which students can build a research plan. Good 
					research questions are testable. "How often do earthquakes happen?" 
					might not be a helpful research question since it doesn't point to a 
					deeper cause-and-effect relationship. "Is there a relationship between 
					how often earthquakes happen and <i>where</i> they happen (epicenter)?" 
					is a better question because the researcher will inevitably be faced 
					with cause-and-effect connections as the reserch plan unfolds. The LIGO 
					e-Lab provides the opportunity for many good research questions based on 
					earthquakes.  
				</p>

					</div>
						<div id="vsId4-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
								</div><div id="vsId4-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId4-v');HideShow('vsId4-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Student Prior Knowledge and Skills</h2></a>
						<p>
					Before doing the LIGO e-Lab, students should be comfortable with these 
					skills:</p>
						<ul>
							<li>Make basic measurements</li>   
							<li>Make basic calculations</li>
							<li>Interpret basic graphs</li>
							<li>Write a research question</li>
							<li>Make a research plan</li>
						</ul>
					<p>We provide a refresher for students who need to brush up on these skills.
					Students access these from "The Basics" section of the <a href="../home/index.jsp" target="show">project milestones</a>.  
						</p>
					</div>
					
						<div id="vsId5-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
								</div><div id="vsId5-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId5-v');HideShow('vsId5-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Learner Outcomes and Assessment</h2></a>
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
			 
				
				<p>Assessment is aligned to learner outcomes. While many teachers will want to design their own assessments, 
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
						
						</c:otherwise>
					</c:choose>
						
					
							<li>
							<b>e-Logbooks:</b> Track progress and provide feedback on student work.<br />
Review all students' entries for a particular milestone and make notes in your logbook for next year.<br />
Click on the pencil icon in the navigation bar to access your logbook.<br />
Review students' evidence of what they know/understand and reflections on their research.<br /> Look at this
<a href="#" onclick="javascript:window.open('../graphics/logbook-sample.gif', 'content', 'width=680,height=400, resizable=1, scrollbars=1');return false;">sample logbook</a>.
							
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
						A good way to begin LIGO studies is to invite the class to watch Cool Science together. Play the <a href="../home/ligo.swf" target="movie">Standalone Movie</a> and enlarge the window.</p>
						<p>Teachers can help students get started in the e-Lab by asking broad questions in class discussion.  These are not research questions.  Their intent would be to motivate kids to start thinking about good research questions.  The following questions are general and would require no specific prior experience:</p>
						<ul>
						<li> Make a list of different types of events that could make the ground shake.  Which ones are the most interesting to you (the student)?
						<li> Do all earthquakes seem to affect LIGO's gravitational wave detectors equally?
						<li> If you observed an event on a graph of seismometer data, do you think you could determine if the event was caused by natural versus human activity?  How would you investigate this?
						</ul>
						<p>Other teacher questions might draw upon recent student learning.  For instance if students had completed an earth science unit, some motivational questions might be:</p>  
						<ul>
						<li> Do you think that you can see the difference between P and S earthquake waves in real seismometer data?
						<li> Can you use seismometer data to analyze the speeds at which seismic waves travel in the ground?
						<li> Do earthquakes of a certain magnitude tend to look the same in LIGO's seismometer data?
						</ul>
						<p>If students have covered wave behavior in a physics or physical science class, some starter questions could be:</p>
						<ul>
						<li> What can you learn by looking at a single seismic event in different frequencies?
						<li> Does the power carried by seismic waves vary with their frequency?   
						</ul>
						<p>Remember that students can look through completed posters to gain ideas for research questions.</p>
						<p>Here are some studies students can do:</p>
						<ul>
							<li><strong>Earthquakes</strong>: A number of earthquake studies are possible with the e-Lab data. From what epicenter distance can LIGO detect earthquake waves? How fast do earthquake waves travel? Are P and S waves distinguishable in the data? If so, what can we learn about how these waves travel through the earth? 
							</li>
							<li><strong>Frequency Band Studies</strong>: LIGO's Data Monitoring Tool data channels (DMT channels) are segregated by frequency ranges. Students can study similar time periods and/or similar seismic events by looking at different frequencies of seismic vibrations. 
							</li>
							<li><strong>Microseismic Studies</strong>: Microseisms provide a constant low-frequency seismic signal in the ground that is related to ocean wave activity. What environmental factors can cause microseisms to vary in strength? 
							</li>
							<li><strong>Studies of Human-induced Seismic Activity</strong>: Humans do things that make the ground shake. What types of human activity can show up in LIGO data? What effect do these activities exert on LIGO's interferometers?</li>
						</ul>
 
					</div>
			
					<H2>&nbsp;&nbsp;&nbsp;<a href="web-guide.jsp">Navigating Students Through the e-Lab</a></H2>
					
					
					<div id="vsId7-v" style="visibility:hidden; display: none">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tright.gif" alt=" " border="0" /> Help Desk & Sharing Ideas</h2></a>
								</div><div id="vsId7-h" style="visibility:visible; display:">
						<a href="#" onclick="HideShow('vsId7-v');HideShow('vsId7-h');return false;"><h2><img src="http://www.i2u2.org/elab/cosmic/graphics/Tdown.gif" alt=" " border="0" /> Help Desk & Sharing Ideas</h2></a>
					<p>
				<p>
					      <table style="margin-left:20px"><tr><td>Use the <a href="/elab/cms/teacher/forum/HelpDeskRequest.php?elab=CMS" class="external text" title="/elab/ligo/teacher/forum/HelpDeskRequest.php?elab=LIGO" rel="nofollow">Help Desk Form</a> to get technical assistance from I2U2 staff. Click on the lifesaver
					     icon in the upper right hand corner of the teacher pages when you are logged in.</td><td><img src="../graphics/Lifesaver.png"></td></tr>
					     <tr><td colspan="2">Be sure to click on <b>Share Ideas</b> in the menu above to see what other teachers have shared in the I2U2 Blog and in Facebook. They may have the answers to your questions. You may have answers to theirs! Maybe you want to collaborate on a study.</td></tr>
					     </table>
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