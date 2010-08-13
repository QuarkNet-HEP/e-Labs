<% 
	String pre, post; 
	if (user.getNewSurveyId() != null) {
		pre  = "../survey/show-students.jsp?type=pre" ;
		post = "../survey/show-students.jsp?type=post";
	}
	else {
		pre  = "../test/show-students.jsp?type=presurvey" ;
		post = "../test/show-students.jsp?type=postsurvey";
	}
	request.setAttribute("pre", pre);
	request.setAttribute("post", post);
%>
<h1>Getting started! Work as a team. Make sure each	team member meets these milestones.</h1>

<table width="794" cellpadding="4">
	<tr>
		<td><font face="ARIAL" size="+1"><b>Click on <img border="0" src="../graphics/ref.gif"> for
		references to help you meet each <a href="javascript:glossary('milestone_text')">milestone</a>.</b></font></td>
	</tr>
</table>
<h1 class="bottomheader">Watch the <a href="../home/cool-science.jsp">Cool Science</a> video about CMS science.</h1>
<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="tab">
					<span class="tab-title">Research Basics</span>
					<div class="tab-contents" style="background-color: #ffffff;">
						<h2>Use these milestones if you need background on:</h2>
						<ul>
							<li>
								Measurement.
								<a href="javascript:reference('measurement',420)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Calculations.
								<a href="javascript:reference('calculations',550)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Graphs.
								<a href="javascript:reference('graphs',550)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Research Questions.
								<a href="javascript:reference('research question',400)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Research Plans.
								<a href="javascript:reference('research plan',220)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
						</ul>
						<h2><a href="javascript:glossary('milestone_seminar_text')">Milestone Seminar</a></h2>
					</div>
				</div>
				<div class="tab">
					<span class="tab-title">B. Figure It Out</span>
					<div class="tab-contents" style="background-color: #ffffff;">
						<h2>Prepares the team to analyze data:</h2>
						<ul>
							<li>
								Know how to collect data and upload files to our server (teams with detectors). 
								<a href="javascript:reference('collect upload data',450)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Know how to use your analysis tools and how to search for data of interest. 
								<a href="javascript:reference('analysis tools',450)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Know how to correct for background and errors when appropriate. 
								<a href="javascript:reference('data errors',400)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
						</ul>
						<h2>Milestone Seminar</h2>
					</div>
				</div>			</div>
		</td>
		<td>
			<div id="right">
				<div class="tab">
					<span class="tab-title">A. Get Started</span>
					<div class="tab-contents" style="background-color: #ffffff;">
						<h2>Prepares the team to design the investigation:</h2>
						<ul>
							<li>
								Describe cosmic rays in simple terms.
								<a href="javascript:reference('cosmic rays',420)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Determine what you can study about cosmic rays.
								<a href="javascript:reference('cosmic ray study',550)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Describe what the detector can do.
								<a href="javascript:reference('detector',400)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Write a research question and proposal.
								<a href="javascript:reference('research proposal',220)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
						</ul>
						<h2>Milestone Seminar</h2>
					</div>
				</div>
				<div class="tab">
					<span class="tab-title">C. Tell Others</span>
					<div class="tab-contents" style="background-color: #ffffff;">
						<h2>Prepares the team to enter into scientific discourse with other researchers:</h2>
						<ul>
							<li>
								Assemble evidence for your results. 
								<a href="javascript:reference('assemble evidence',250)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Use the e-Lab to publish your results. 
								<a href="javascript:reference('publish results',280)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							</ul>
						<h2>Milestone Seminar</h2>
						<ul>
							<li>
								Use the e-Lab to discuss results with your peers. 
								<a href="javascript:reference('discuss results',420)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
						</ul>
					</div>
				</div>


			</div>
		</td>
	</tr>
</table>
<h1>Take the <a href="${post}">Post-Test</a> when you have completed the e-Lab.</h1>

