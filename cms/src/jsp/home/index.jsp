<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column-home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
	</head>
	
	<body id="home" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<c:if test="${user != null}">
							<%@ include file="../include/nav.jsp" %>
						</c:if>
					</div>
				</div>
			</div>
			
			<div id="content">
				

 	 <c:if test="${user != null}">
<h1>Home: Join a national collaboration of high school students to study CMS test beam data.</h1>
  
	   <div id="links"><table align="center"><tr>
	   <td width="150" align="center"><A href="cool-science.jsp"><img src="../graphics/cool-science-button.gif" border="0"><br>Cool Science</a></td>
	   <td width="150" align="center"><a href="../site-index/site-map-anno.jsp"><img src="../graphics/site-map-button.gif" border="0"><br>Explore!</a></td>
	   <td width="150"align="center"><a href="about-us.jsp"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></td></tr></table></div>
<h3>Project Map: Your team may use the milestones below, or your teacher may have other plans. Make sure you know how to record your progress, keep your teacher appraised of your work and publish your results. 
</h3>
<h4>Think of this map as a subway map with one main line and four branch lines.  Along the main line are stops, milestone seminars, opportunities to check how the work is going. Off each main stop are branch lines where each stop is a project milestone.
 Hover over each milestone or milestone seminar to preview; click milestones to open. 
</h4>
	  </c:if>  
 	 <c:if test="${user == null}">
<h1>Welcome: Join a national collaboration of high school students to study CMS test beam data.</h1>
	  </c:if>  

<!-- there is no way to do this without tables unfortunately -->
<table border="0" id="main">
<%--
	<tr>
	    <td colspan="2">
 	 <c:if test="${user != null}">
  
	   <div id="links"><A href="../library/big-picture.jsp">Cool Science</a> - <a href="../site-index/site-map-anno.jsp">Explore</a> - <a href="about-us.jsp">About Us</a></div>
	  </c:if>  
	    </td>
	
	
	</tr>
 --%>
	<tr>
		<td>
	 <c:if test="${user != null}">
		<div id="left">
			<script type="text/javascript" src="../include/elab.js"></script>
	        <%@ include file="../login/login-required.jsp" %>
		    <%@ include file="../library/milestones-map-student.jsp" %>
 		</div>
	  </c:if>  
 	 <c:if test="${user == null}">
		<div id="left-animation">
 	    	<%@ include file="../home/splash-home.html" %>
 		</div>
	  </c:if>  
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

	<c:if test="${user != null}">
		<div style="text-align: center;">
	    	<a href="../library/milestones.jsp">Milestones (text version)</a>
	    </div>
	</c:if>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>