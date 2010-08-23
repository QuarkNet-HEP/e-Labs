<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab: About Us</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column-home.css"/>
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Welcome! Contribute to our scientific collaboration. Who are we?</h1>

<!-- there is no way to do this without tables unfortunately -->
<table border="0" id="main">
	<tr>
		<td>
			<div id="left-column">
				<img src="../graphics/crop.jpg"/>
			</div>
		</td>
		<td>
			<div id="right-column">

				<h2>Who are we?</h2>
				<p>We're a collaboration of high school students and teachers collecting and analyzing cosmic ray data. We're working with cutting edge tools that use the grid techniques to share data, create plots and posters and collaborate with other students internationally.</p>

				<h2>Who can join?</h2>
				<p><strong>You</strong>! Think about steps you'd take to investigate cosmic rays. How would you get started? What do you need to know? Can you collect and use data?
				<ul>
					<li>Here's your chance to do a research study.</li>
					<li>Find out what other students have done.</li>
					<li>Talk it over.</li>
					<li>Then ask other questions and refine your study!</li>
				</ul>
				<h2>Do a study!</h2>
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
				<%@ include file="../include/newsbox.jsp" %>
				<jsp:include page="../login/login-control.jsp">
					<jsp:param name="prevPage" value="../home/login-redir.jsp"/>
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