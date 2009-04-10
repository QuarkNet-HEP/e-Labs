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
	<body class="siteindex">
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
<h1>Lost? Click on hotspots in this site map.</h1>
<div align="center">
<img src="../graphics/site-map.gif" width="670" height="524" border="0" alt="" usemap="#site_map">

<map name="site_map">
<area shape="rect" alt="" coords="242,202,403,318" href="../home/">
<!-- 
<area shape="rect" alt="" coords="412,64,662,254" href="https://www18.i2u2.org/elab/cosmic/logbook/">
 -->
<area shape="rect" alt="" coords="0,71,235,260" href="../assessment/index.jsp">
<area shape="rect" alt="" coords="0,273,233,460" href="../posters/">
<area shape="rect" alt="" coords="243,320,402,524" href="../data/">
<area shape="rect" alt="" coords="408,269,662,458" href="../data/upload.jsp">
<area shape="rect" alt="" coords="242,0,402,202" href="../library/">
</map>
</div>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
