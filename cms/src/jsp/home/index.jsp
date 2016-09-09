<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/two-column-home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
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
				<%@ include file="../include/check-javascript.jsp" %>
				<c:choose>
					<c:when test="${user == null}"> <%-- User is not logged in --%>
						<h1>Welcome: Join an international collaboration of high school students to study CMS data.</h1>
						<h2>Bookmark This Page!</h2>
						<table border="0" id="main">
							<tr>
					 	 		<td>
					 	 			<div id="left-animation"><%@ include file="../home/splash-home.html" %></div>
				 	 			</td>
				 	 			<td>
									<div id="right">
										<%@ include file="../include/newsbox.jsp" %>
										<div align="center"><a href="about-us.jsp" style="text-decoration: none;"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></div>
										<jsp:include page="../login/login-control.jsp">
											<jsp:param name="prevPage" value="../home/login-redir.jsp"/>
										</jsp:include>
									</div>
								</td>
			 	 			</tr>
		 	 			</table>
					</c:when>
					<c:otherwise> <%-- User is logged in --%>
						<h1>Home: Join an international collaboration of high school students to study CMS data.</h1>
						
						<%-- Newsbox --%>	
						<%String jLIstring = request.getParameter("justLoggedIn"); %>
						
						<c:set var="jLI" value="${param.justLoggedIn}"/>
						
						<c:choose>
						<c:when test="${jLI != 'yes'}"> <%--Do not show newsbox because user has not just logged in--%>
							<div id="newsbox-v" style="visibility:visible; display"> 
							<a href="#" onclick="HideShow('newsbox-v');HideShow('newsbox-h');return false;"><H2><img src="../graphics/Tright.gif" alt=" " border="0" /> View News Alert</H2></a>
						    </div>
						    
						    <div id="newsbox-h" style="visibility:hidden; display: none">
							<a href="#" onclick="HideShow('newsbox-v');HideShow('newsbox-h');return false;"><H2><img src="../graphics/Tdown.gif" alt=" " border="0" /> View News Alert</H2></a>
						    <%@ include file="../include/newsbox.jsp" %>
						   </div>
						</c:when>
					 	
				        <c:otherwise> <%--Show newsbox because user has just logged in--%>
				        <div id="newsbox-v" style="visibility:hidden; display: none">					   
							<a href="#" onclick="HideShow('newsbox-v');HideShow('newsbox-h');return false;"><H2><img src="../graphics/Tright.gif" alt=" " border="0" /> View News Alert</H2></a>
						</div>
						
						<div id="newsbox-h" style="visibility:visible; display">
							<a href="#" onclick="HideShow('newsbox-v');HideShow('newsbox-h');return false;"><H2><img src="../graphics/Tdown.gif" alt=" " border="0" /> View News Alert</H2></a>
							<%@ include file="../include/newsbox.jsp" %>
						</div>
					    </c:otherwise>
					    </c:choose>
						<%-- End Newsbox --%>
						
						<h3>Project Map: To navigate the CMS e-Lab, follow the path; complete the milestones. Hover over each hot spot to preview; click to open. Along the main line are milestone seminars, 
						opportunities to check how your work is going. Project milestones are on the four branch lines. 	
						<e:popup href="../video/CMSe-LabNavigation.html" target="tryit" width="655" height="500">Getting Around the e-Lab</e:popup>
						</h3>

						<div style="text-align: center;">
							<c:choose>
							 	<c:when test='${user.role == "teacher" }'>
								    <jsp:include page="../library/milestones-map-teacher.jsp" />
								    <br />
								</c:when>
								<c:otherwise>
								    <jsp:include page="../library/milestones-map-student.jsp" />
								    <br />
								</c:otherwise>
							</c:choose>
							<br />
							<a href="../library/milestones.jsp">Milestones (text version)</a>
						</div>
						<h4>Your team may use the milestones above, or your teacher may have other plans. Make sure you know how to record your progress, keep your teacher apprised of your work and publish your results.</h4>
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