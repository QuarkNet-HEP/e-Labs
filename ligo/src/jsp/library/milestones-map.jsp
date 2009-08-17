<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Study Guide</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="milestones-map" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			<div id="content">
				
<table border="0" id="main">
  <tr>
  <td id="left">
	  <%@ include file="../include/left-alt.jsp" %>
  </td>
  <td id="center">
	  <h1>Getting started! Make sure you accomplish the milestones on the diagram.</h1>
	  <p>
		  Follow the workflow map below to guide your work.
		  Click on the hotspots to get references for accomplishing your
		  milestones.
		  The colored dots in the workflow indicate where your
		  teacher monitors your progress. 
		  Your teacher will comment on the entries that you make in your
		  logbook for each milestone.
		  Be sure to read the teacher comments! 
	  </p>
	  <center>
		  <c:choose>
			  <c:when test="${user.group.profDev}">
				  <%@ include file="milestones-map-profdev.jsp" %>
			  </c:when>
			  <c:otherwise>
				  <%@ include file="milestones-map-student.jsp" %>
			  </c:otherwise>
		  </c:choose>
		  <div class="link-list">
			  <a href="milestones.jsp">Milestones (text version)</a>
			  |
			  <a href="/glossary/index.php/LIGO_Glossary"
				 target="_blank">LIGO Glossary</a>
			  | 
			  <a href="../references/showAll.jsp?t=reference">All References for Study Guide <img src="../graphics/ref.gif"/></a>
		  </div>
	  </center>

			
			<p>
				The diagram above is a road map that takes you through an e-Lab. Another
				name for the map is a <em>workflow diagram</em>. Drag your mouse over 
				the diagram.  You'll see that the circles are links. The links on the 
				ends point to the pre-test and post-test that you will take to measure 
				your e-Lab learning.  Other links represent <em>milestones</em> -- 
				tasks that you must master in order to move on. Click on a milestone 
				and you'll see a pop-up box.  The box will contain a statement of the 
				milestone, some <em>references</em> that you can use to learn how to 
				master the milestone, and a "log it!" link that takes you to your 
				electronic log book.  When you've mastered a milestone, write the 
				evidence in your log book.  Your teacher will read your entry.
			</p>
			<p>
				Now you're ready to begin.  Go through the e-Lab tasks one at a time; 
				The Basics (optional), Get Started, Figure It Out and Tell Others.
			</p>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>	
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
