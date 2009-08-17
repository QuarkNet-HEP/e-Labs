<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%
	user.resetFirstTime();
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Classroom Notes </title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	
	<body id="first-web" class="home">
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
			<div class="float-right">
				<a class="button" href="../library/milestones-map.jsp">Let's Go!</a>
			</div>


<h1>Getting Started on the LIGO I2U2 e-Lab</h1>
<p>
  <em>The e-Lab process</em> follows three basic steps. The e-Lab road 
  map that you'll see when you click 
  <a href="../library/milestones-map.jsp">Study Guide</a> (on the 
  <a href="../library">Library</a> submenu) shows you the steps.
</p>

<p>
  <em>Step 1: Get Started</em> Review and refresh some of your basic 
  science skills.  Practice using 
  <a href="/ligo/tla/" target="_blank">Bluestone</a> 
  to make graphs of real seismometer data.
</p>
<p>
  <em>Step 2:  Figure It Out</em> Make your research question. Use Bluestone 
  to plot LIGO seismometer data. You will test and improve your ideas (your 
  hypothesis) by making more plots and by looking at other sources of data. 
  You will share your ideas with classmates and with your teacher.  
  Eventually your research will lead you to an answer to your research question. 
  It's the scientific method at work!
</p>
<p>
  <em>Step 3:  Tell Others</em> Build an online poster and use it to discuss 
  your research and your conclusions with your classmates and others.
</p>
<p>
  <em>Use</em> the link menus to help you! The top link menu provides guidance 
  for accomplishing the e-Lab. The sidebar links give you additional science 
  resources, a Bluestone tutorial, a Bluestone link and Discussion Site links.
</p>
<p>
  <em>Watch</em> for little icons on the e-Lab screens. Clicking on 
  <img src="../graphics/ref.gif" /> will give you a reference popup that will 
  help with a milestone. The logbook icon, 
  <img src="../graphics/logbook_pencil.gif" align="middle">, will open your 
  electronic log book. The looking glass, 
  <img src="../graphics/logbook_view_comments_small.gif" align="middle">, lets 
  you access teacher comments about your log entries.
</p>
<p>
  <em>The heart</em> of the LIGO e-Lab is software named 
  <a href="/ligo/tla/">Bluestone</a>.  Bluestone lets 
  you to select the LIGO data channels that you wish to view and lets you 
  control the features of the plots that you make.  Bluestone mimics software 
  that LIGO scientists and engineers use at the Observatory sites.  Your 
  teacher will tell you how to use Bluestone.
</p> 
<p>
  <em>Another</em> key feature of the LIGO e-Lab is a comprehensive
  portal site.   Here you will also find a
  <a href="/glossary/">glossary</a>, 
   along with 
  <a href="/forum_index.php">discussion rooms</a>
  in which you can share research ideas with others.
  Your teacher will tell you how to log in.
</p>


<p>
  <em>Now What?</em> Hit the <a href="../library/milestones-map.jsp">Let's Go</a> link above 
  and start working your way through the e-Lab!
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
