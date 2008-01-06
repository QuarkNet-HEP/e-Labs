<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%
	user.resetFirstTime();
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Grid Student Intro</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/three-column.css"/>
	</head>
	
	<body id="first-web" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<!-- no nav here -->
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Join a national collaboration of high school students to study cosmic rays.</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<%@ include file="../include/left.jsp" %>
			</div>
		</td>
		<td>
			<div id="center">
				<h2>How to use the website. What you'll find on the next pages.</h2>
				<dl>
					<dt>Log in/Log out:</dt>
					<dd>Check the upper right hand corner to see the current status.</dd>
					
					<dt>Getting Around:</dt>
					<dd>
						Use the navigation bar.
						<p>
							<img src="../graphics/navigation_bar.jpg">
						</p>
						<p>
							<a target="map" href="../site-index/site-map-anno.jsp?display=static">Navigation Overview</a>
						</p>
					</dd>
					
					<dt>Special icons and links:</dt>
					<dd>
						Click on these.
						<p>
							<img src="../graphics/question.gif"> and links in the text for explanations 
							of terms in the glossary and variables in the analyses.
						</p>
						<p>
 							<img src="../graphics/Tright.gif"> and <img src="../graphics/Tdown.gif"> 
							to show and hide analysis controls.
						</p>
					</dd>
					
					<dt>Popup Windows:</dt>
					<dd>Be sure that you are not blocking popup windows in your browser.</dd>

					<dt>References:</dt>
					<dd>Explore tutorials, online resources, animations and contacts.</dd>
					
					<dt>Study Guide - A List of Milestones:</dt>
					<dd>
						<p>
							Concepts you need to know. Skills you need to use. Tasks you need to accomplish.
						</p>
	
						<p>
							To access resources associated with milestones, click on <img src="../graphics/ref.gif">.
						</p>
						
						<p>
							For review, go through the milestones in The Basics.
						</p>

						<p>
							Work your way through the list of milestones in the Study Guide.
						</p>
					</dd>

					<dt>Log Book:</dt>
					<dd>
						Check the upper right hand corner to get to your logbook. Click on these.
						<p>
							<img src="../graphics/logbook_pencil.gif"> and "<strong>Log it!</strong>"
							to add notes to your log book related to the milestones
						</p>
						
						<p>
							<img src="../graphics/logbook_view_comments_small.gif"> to access teacher comments in your logbook.
						</p>
					</dd>
				</dl>
			</div>
		</td>
		<td>
			<div id="right">
				<a class="button" href="../library/milestones-map.jsp">Let's Go!</a>
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