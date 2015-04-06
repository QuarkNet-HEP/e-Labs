<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@ page import="gov.fnal.elab.util.URLEncoder" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<title>e-Labs</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link href="../css/i2u2style.css" rel="stylesheet" type="text/css" />
	</head>
	<body>
		<div id="banner">e-Labs</div>
		<div id="rightText">Enhancing Student Investigations and Collaborations</div>
		<div id="headerAlign">
			<div id="header">
				<ul></ul>
			</div>
			<div id="submenu">
				<ul>
					<li>
						<a href="/">Home</a>
					</li>
					<li><a href="/elab/cms/">CMS e-Lab</a></li>
					<li><a href="/elab/cosmic/">Cosmic Ray e-Lab</a></li>
					<li><a href="/elab/ligo/">LIGO e-Lab</a></li>					
					<li id="currentSubmenu"><a href="/elab/about.jsp">About</a></li>
					<li><a href="/elab/scaffolding.html">Ed Scaffolding</a></li>
					<li><a href="/elab/teacher.html">Teacher Registration</a></li>
				</ul>
			</div>
		</div>
		<div id="content">
			<div id="contentWithMargin"> 
				<h2>About</h2>
				<p>
					The <strong>e-Labs differ</strong> from other collaborative education 
					environments because they build on the power of distributed computing and the 
					Virtual Data System to add exciting education components not available 
					with other models. Students contribute to and access shared data, most 
					derived from professional research databases. They use common analysis 
					tools, store their work and <B>use metadata to discover, replicate and 
					confirm the research of others.</B> This is where real scientific 
					collaboration begins. Using online tools, students correspond with 
					other research groups, post comments and questions, prepare summary 
					reports, and in general participate in the part of scientific research 
					that is often left out of classroom experiments.
				</p> 
				<p>
					Teaching tools such as student and teacher logbooks, pre-tests and post-tests 
					and an assessment rubric aligned with learner outcomes help teachers 
					guide student work. Constraints on interface designs and administrative 
					tools such as registration databases give teachers the "one-stop-shopping" 
					they seek for multiple e-Labs. Teaching and administrative tools also 
					allow us to track usage and assess the impact on student learning.
				</p>
				<p>
					The e-Labs address ALL science practices in the Next Generation Science Standards. 
					The Cosmic Ray e-Lab also addresses ALL engineering practices.<br />
					<ul style="list-style-type: none;">
						<li>1. Asking questions (for science) and defining problems (for engineering)</li>
						<li>2. Developing and using models</li>
						<li>3. Planning and carrying out investigations</li>
						<li>4. Analyzing and interpreting data</li>
						<li>5. Using mathematics and computational thinking</li>
						<li>6. Constructing explanations (for science) and designing solutions (for engineering)</li>
						<li>7. Engaging in argument from evidence</li>
					</ul>								
				</p>
				<p>
			<%
				String subject = "Question/Comment";
				String body = URLEncoder.encode("Please complete each of the fields below:"
					+ "First Name:\n\n"
					+ "Last Name:\n\n"
					+ "City:\n\n"
					+ "State:\n\n"
					+ "School:\n");
				String mailURL = "mailto:e-labs@fnal.gov?Subject=" + subject + "&Body=" + body;
			%>
					If you have any questions or comments, contact us at <a href="<%= mailURL %>">e-labs@fnal.gov</a>.
				</p>
				<br /><br />
				</div>
		</div>
	</body>
</html>
