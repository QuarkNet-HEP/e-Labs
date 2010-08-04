<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
		<script type="text/javascript" src="../include/elab-custom.js"></script>
		<script src="insertMovie.js" language="JavaScript" type="text/javascript"></script>
		<script type="text/javascript" src="../include/swfobject.js"></script>
		
		<script type="text/javascript">
		var flashvars = {
			movie: "../home/gravity-waves.flv",
			autoplay: true,
			controls: "hide"
		}; 
		var params = {
			allowfullscreen: false,
			allscriptaccess: "always"
		}; 
		var attributes = {}; 
		swfobject.embedSWF("../include/flayr.swf", "gravityMovie", "320", "240", "9.0.115.0", "../include/expressInstall.swf", flashvars, params, attributes);  
		</script>

</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<c:choose>
						<c:when test="${user != null}">
							<%@ include file="../include/nav-rollover.jspf" %>
						</c:when>
						<c:otherwise>
							<div id="nav">
								<h1>Build Your Own Research Project Using Professional Science Data</h1>
							</div>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
			
			<div id="content">

<!-- There is no way to do this without tables?  I DOUBT IT -EAM -->


<c:choose>
	<c:when test="${user == null}">
		<table border="0" id="main">
  			<tr>
				<td id="left" style="display: none;" >
					<%-- include file="../include/left.jsp" --%>
				</td>
				<td id="center" style="text-align: center;">
					<h1>Join a national collaboration of students to study LIGO seismic data.</h1>	  
					<p> </p>
					<table> 
						<tr>
							<td style="text-align: center;">
								<div id="gravityMovie">
									<p><img src="gravity.jpg" /></p>
								</div>
								<br />
								
								<div style="font-size:80%";margin-bottom:12px;>Orbiting Black Holes Creating Gravitational Waves<br>Credit: Henze, NASA</div>
								<p style="font-size:90%">LIGO seeks to detect gravitational waves from orbiting black holes, neutron stars and other sources.</p>
								<p style="font-size:90%">Scientists must distinguish gravitational waves  from "noise" caused by seismic waves passing through the ground underneath LIGO's detectors.</p>
							</td>
							<td class="float-right bordered">
							<div align="center"><a href="about-us.jsp" style="text-decoration: none;"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></div>
								<jsp:include page="../login/login-control.jsp">
									<jsp:param name="prevPage" value="../home/login-redir.jsp"/>
								</jsp:include>
								<%@ include file="../include/newsbox.jsp" %>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</c:when>
	<c:otherwise>
		<table border="0" id="main">
			<tr>
				<td id="left">
					<%@ include file="../include/left-alt.jsp" %>
				</td>
				<td id="center">
					<h1>Join a national collaboration of students to study LIGO seismic data.</h1>
					<br />
					<br />
					<p>Project Map: To navigate the CMS e-Lab, follow the path; complete the milestones. Hover over each hot spot to preview; click to open. Along the main line are milestone seminars, opportunities to check how your work is going. Project milestones are on the four branch lines.</p>
					<center>
						<%@ include file="../library/milestones-map-student.jsp" %>
						<p><a href="/elab/ligo/library/milestones.jsp">Milestones (text version)</a></p>
					</center>
					<p>Your team may use the milestones above, or your teacher may have other plans. Make sure you know how to record your progress, keep your teacher appraised of your work and publish your results. </p>
					
				</td>
			</tr>
		</table>
	</c:otherwise>
</c:choose>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
