<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Teacher Site Map</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="site-map">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">


<h1>Cosmic Site Map</h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<h2>Teacher Pages</h2>
				<ul class="simple">
					<li><a href="index.jsp"><b>Home</b></a></li>
					<ul class="simple">
					<li><a href="web-guide.jsp">Website Features</a></li>
					<li>Rubrics - <A HREF="../assessment/rubric-ci.html">Content & Investigation</A>,
						<A HREF="../assessment/rubric-r.html">Process</A>, <A HREF="../assessment/rubric-t.html">Computing</A>,
						<A HREF="../assessment/rubric-wla.html">Literacy</A> and <A HREF="../assessment/rubric-p.html">Poster</A></li>
</ul>

					<li><a href="community.jsp"><b>Community</b></a> - Library and Forum</li>
					
					
					<li><a href="standards.jsp"><b>Standards</b></a></li>
<li><a href="site-map.jsp"><b>Site Index</b></a></li>


				</ul>
				
			</div>
		</td>
		
		<td>
			<div id="center">
			</div>
		</td>
		<td>
			<div id="right">
				<h2>Student Pages</h2>
				<ul class="simple">
					<li><a href="../home/">Home</a></li>
					<li><a href="../site-index/">Site Index</a></li>
				</ul>
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
