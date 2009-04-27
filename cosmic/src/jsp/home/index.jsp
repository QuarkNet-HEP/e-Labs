<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
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
					<div id="nav">
						<c:if test="${user != null}">
							<%@ include file="../include/nav.jsp" %>
						</c:if>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Join a national collaboration of high school students to study cosmic rays.</h1>

<!-- there is no way to do this without tables unfortunately -->
<table border="0" id="main">
	<tr>
	    <td>
 	 <c:if test="${user != null}">
  
	    <h2 style="text-align:center"><A href="../library/big-picture.jsp">Cool Science</a> - <a href="../site-index/site-map-anno.jsp">Explore</a> - <a href="about-us.jsp">About Us</a></h2>
	  </c:if>  
	    </td>
	
	
	</tr>
	<tr>
		<td>
			<div id="left">
	 <c:if test="${user != null}">
		<script type="text/javascript" src="../include/elab.js"></script>
        <%@ include file="../login/login-required.jsp" %>
	    <%@ include file="../library/milestones-map-student.jsp" %>
	  </c:if>  
 	 <c:if test="${user == null}">
 	    <%@ include file="../home/splash-home.html" %>

	  </c:if>  
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