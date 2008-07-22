<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Site Overview</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/site-index.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
	<body id="site-map-anno" class="site-index">
		<!-- entire page container -->
		<div id="container">
			
			<c:if test="${param.display != 'static'}">
			<!-- display set to "static" allows showing a site overview without a real menu -->
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
						<div id="nav">
							<%@ include file="../include/nav.jsp" %>
							<div id="subnav">
								<%@ include file="../include/nav-site-index.jsp" %>
							</div>
						</div>
					</div>
				</div>
			</c:if>
			
			<div id="content">
			

<table border="0" id="main">
	<tr>
		<c:if test="${param.display != 'static'}">
			<td id="left">
				<%@ include file="../include/left-alt.jsp" %>
			</td>
		</c:if>
		<td id="center">
			<h2>LIGO E-Lab Site Map</h2>
			
			<ul>
				<li>
					Student pages
					<ul>
						<li><a href="../home">Home</a></li>
						<li><a href="../library">Library</a></li>							
						<li><a href="../data">Data</a></li>
						<li><a href="http://tekoa.ligo-wa.caltech.edu/tla">Bluestone, the
LIGO Analysis Tool</a></li>
						<li><a href="../data/tutorial.jsp">Bluestone Tutorial</a></li>
						<li><a href="../maps">LIGO Maps</a></li>
						<li><a href="../sensors">LIGO Sensors</a></li>
						<li><a href="../info/related-data.jsp">Related Data</a></li>
						<li><a href="../posters/">Posters</a></li>
						<li><a href="../assessment/">Assessment</a></li>
					</ul>
				</li>
			</ul>
		</td>
	</tr>
</table>

 

		<c:if test="${param.display == 'static'}">
  			<A HREF="javascript:window.close();">Close Window and Go Back to Getting Started Page</A>
		</c:if>

			</div>
			<!-- end content -->	
		
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
