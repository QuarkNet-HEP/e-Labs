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
								<a href="javascript:studentLogbook('measurements',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Calculations.
								<a href="javascript:studentLogbook('calculations',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Graphs.
								<a href="javascript:studentLogbook('graphs',550)">
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
								<a href="javascript:studentLogbook('research_plan',800)">
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
								<a href="javascript:studentLogbook('collect_upload_data',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Know how to use your analysis tools and how to search for data of interest. 
								<a href="javascript:studentLogbook('analysis_tools',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Know how to correct for background and errors when appropriate. 
								<a href="javascript:studentLogbook('data_error',800)">
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
								<a href="javascript:studentLogbook('cosmic_rays',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Determine what you can study about cosmic rays.
								<a href="javascript:studentLogbook('cosmic_ray_study',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Describe what the detector can do.
								<a href="javascript:studentLogbook('detector',400)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Write a research question and proposal.
								<a href="javascript:studentLogbook('research_proposal',800)">
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
								<a href="javascript:studentLogbook('assemble_evidence',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							<li>
								Use the e-Lab to publish your results. 
								<a href="javascript:studentLogbook('publish_results',800)">
									<img src="../graphics/ref.gif">
								</a>
							</li>
							</ul>
						<h2>Milestone Seminar</h2>
						<ul>
							<li>
								Use the e-Lab to discuss results with your peers. 
								<a href="javascript:studentLogbook('discuss_results',800)">
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

