<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Big Picture</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
	</head>
<script language="javascript">AC_FL_RunContent = 0;</script>
<script src="AC_RunActiveContent.js" language="javascript"></script>
		
	<body id="big-picture" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jsp" %>
				</div>
			</div>
			
			<div id="content">
				
<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">
			<h2>LIGO: A New Way to Explore the Universe.</h2>
			
			<p />
			
			<span id="links">
				<table align="center">
					<tr>
						<td style="width:150px; text-align:center;"><a href="/elab/ligo/home/" style="text-decoration: none;"><img src="../graphics/home-button.gif" border="0"><br>Project Map</a></td>
						<td style="width:150px; text-align:center;"><a href="/elab/ligo/site-index/site-map-anno.jsp" style="text-decoration: none;"><img src="../graphics/site-map-button.gif" border="0"><br>Explore!</a></td>
						<td style="width:150px; text-align:center;"><a href="/elab/ligo/home/about-us.jsp" style="text-decoration: none;"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></td>
					</tr>
				</table>
			</span>
			<br />
			<div id="movie" align="center">
<script language="javascript">
	if (AC_FL_RunContent == 0) {
		alert("This page requires AC_RunActiveContent.js.");
	} else {
		AC_FL_RunContent(
			'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0',
			'width', '650',
			'height', '450',
			'src', 'ligo-dale',
			'quality', 'high',
			'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
			'align', 'middle',
			'play', 'true',
			'loop', 'false',
			'scale', 'showall',
			'wmode', 'window',
			'devicefont', 'false',
			'id', 'ligo-dale',
			'bgcolor', '#000000',
			'name', 'ligo-dale',
			'menu', 'true',
			'allowFullScreen', 'false',
			'allowScriptAccess','sameDomain',
			'movie', 'ligo-dale',
			'salign', ''
			); //end AC code
	}
</script>
<noscript>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="650" height="450" id="ligo-dale" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="ligo-dale.swf" /><param name="loop" value="false" /><param name="quality" value="high" /><param name="bgcolor" value="#000000" />	<embed src="ligo-dale.swf" loop="false" quality="high" bgcolor="#000000" width="650" height="450" name="ligo-dale" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
	</object>
</noscript>

<br />Be sure to turn on your sound!
</div>

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
