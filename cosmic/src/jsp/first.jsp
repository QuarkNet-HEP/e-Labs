<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Quarknet Grid Student Intro</title>
		<%= elab.css("css/style2.css") %>
		<%= elab.css("css/home.css") %>
	</head>
	
	<body id="first" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top"
				<div id="header">
					<%@ include file="include/header.jsp" %>
				</div>
				<div id="nav">
					<!-- no nav here -->
				</div>
			</div>
			
			<div id="content">
				
<div id="content-header">
	Join a national collaboration of high school students to study cosmic rays.
</div>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<%@ include file="include/left.jsp" %>
			</div>
		</td>
		<td>
			<div id="center">
				<h1>Welcome! Contribute to our scientific collaboration</h1>
				<ul>
					<li>Here's your chance to do a research study.</li>
					<li>Find out what other students have done.</li>
					<li>Talk it over.</li>
					<li>Then ask other questions and refine your study!</li>
				</ul>
				<h1>Do a study!</h1>
				<ul>
					<li>
						You will:
						<ul>
							<li>Ask questions about cosmic rays.</li>
							<li>Develop a study plan to answer these questions.</li>
							<li>
								Execute your plan.
								<!-- ?? -->
								<ul>
									<li>Gather data (if you have a detector in your classroom).</li>
									<li>Gather evidence from data.</li>
								</ul>
							</li>
							<li>Share and defend your results.</li>
						</ul>
					</li>
				</ul>
			</div>
		</td>
		<td>
			<div id="right">
				<a class="button" href="first_web.jsp">Get Started</a>
				<%@ include file="modules/poster/postersamplesmall.jsp" %>
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