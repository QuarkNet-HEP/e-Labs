<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>LIGO Elab Teacher Information</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
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

<h1>Teacher Home</h1>

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
					same way as a professional scientist. E-Lab tools will facilitate 
					collaboration between students as they develop their projects and 
					report their results.
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
					science operations.
				</p>
					
				<h2>Prior Knowledge and Skills:</h2>
				<p>
					Before doing the LIGO E-Lab, students should be comfortable with these 
					skills:
						<ul>
							<li>Make simple measurements</li>   
							<li>Make simple calculations</li>
							<li>Interpret simple graphs</li>
							<li>Write a research question</li>
							<li>Make a research plan</li>
						</ul>
					We provide a refresher for students who need to brush up on these skills.
					Here is what the students see:  <a href="../library/research-basics.jsp">Review of Basic Skills</a>
				</p>
				
				<h2>Learner Outcomes:</h2>
				<p>
					Here are the E-Lab outcomes that students must demonstrate:</p> 
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
									Design an investigation that asks a testable hypothesis, can be answered from seismic data and provides an explanation of what you learn about seismic data.								
								</li>
							</ul>
							</li>
							
							<%@ include file="learner-outcomes.jsp" %>
			   	</ul>
				</p>

				<h2>Research Question:</h2>
				<p>
					Developing a good research question is one of the most challenging 
					parts of the E-Lab for many students. A good research question provides 
					a framework around which the students can build a research plan. Good 
					research questions are testable. "How often do earthquakes happen?" 
					might not be a helpful research question since it doesn't point to a 
					deeper cause-and-effect relationship. "Is there a relationship between 
					how often earthquakes happen and <i>where</i> they happen (epicenter)?" 
					is a better question because the researcher will inevitably be faced 
					with cause-and-effect connections as the reserch plan unfolds. The LIGO 
					E-Lab provides the opportunity for many good research questions based on 
					earthquakes.  Students should look through the on-line discussion rooms
					to gain ideas for research questions. 
				</p>
  
				<h2>Assessment:</h2>
				<p>
					Asssessment is aligned to learner outcomes. We provide the following 
					tools to meet specific outcomes for your students. You may wish to 
					modify some to meet your needs.
					
					<ul>
						<li>
							Rubrics: <a href="../assessment/rubric-ci.html">Overall Content & Investigation</a>, 
							<a href="../assessment/rubric-r.html">Research Skills</a>, 
							<a href="../assessment/rubric-t.html">Computing Skills</a>,
							<a href="../assessment/rubric-wla.html">Writing and Language Arts</a> and 
							<a href="../assessment/rubric-p.html">Poster</a>
						</li>
						<li>
							<a href="../test/test.jsp?type=presurvey&studentid=0">Pre</a>
							- and <a href="../test/test.jsp?type=postsurvey&studentid=0">post</a>
							- tests of content knowledge.</li>
						<li>Student results for 
							<a href="../test/results.jsp?type=presurvey">pre</a>
							- and <a href="../test/results.jsp?type=postsurvey">post</a>-tests.
						</li>
						<li>
							e-Logbooks: Track and comment on student work. Review 
							group logbook or all student entries for a particular 
							milestone, e.g., class cosmic ray descriptions.
						</li>
					</ul>
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