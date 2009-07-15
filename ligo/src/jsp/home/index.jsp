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
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<c:choose>
						<c:when test="${user != null}">
							<%@ include file="../include/nav-rollover.jsp" %>
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
				<td id="left">
					<%-- include file="../include/left.jsp" --%>
				</td>
				<td id="center">
					<h1>Welcome: Join a national collaboration of students to study LIGO seismic data.</h1>	  
					<p> </p>
					<table> 
						<tr>
							<td><img src="/elab/ligo/graphics/lho_aerial_photo.jpg" /></td>
							<td class="float-right bordered">
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
					<span id="links">
						<table align="center">
							<tr>
								<td style="width:150px; text-align:center;"><a href="cool-science.jsp" style="text-decoration: none; color="#ff9933"><img src="../graphics/cool-science-button.gif" border="0"><br><span style="color="#ff9933">Cool Science</span></a></td>
								<td style="width:150px; text-align:center;"><a href="/elab/ligo/site-index/site-map-anno.jsp"style="text-decoration: none;"><img src="../graphics/site-map-button.gif" border="0"><br>Explore!</a></td>
								<td style="width:150px; text-align:center;"><a href="about-us.jsp" style="text-decoration: none;"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></td>
							</tr>
						</table>
					</span>
					<p>Project Map: Your team may use the milestones below, or your teacher may have other plans. Make sure you know how to record your progress, keep your teacher appraised of your work and publish your results. </p>
					<center>
						<%@ include file="../library/milestones-map-student.jsp" %>
						<p><a href="/elab/ligo/library/milestones.jsp">Milestones (text version)</a></p>
					</center>
					<p>Think of this map as a subway map with one main line and four branch lines.  Along the main line are stops, milestone seminars, opportunities to check how the work is going. Off each main stop are branch lines where each stop is a project milestone. Hover over each milestone or milestone seminar to preview; click milestones to open. </p>
					
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
