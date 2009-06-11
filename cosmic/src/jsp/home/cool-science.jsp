<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab: Cool Science</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column-home.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
<script language="javascript">AC_FL_RunContent = 0;</script>
<script src="../flash/AC_RunActiveContent.js" language="javascript"></script>
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
				
<h1>Cool Science: Studying cosmic rays &mdash; solving scientific mysteries!</h1>
 	 <c:if test="${user != null}">
	   <div id="links"><table align="center"><tr>
	   <td width="150" align="center"><A href="index.jsp"><img src="../graphics/home-button.gif" border="0"><br>Project Map</a></td>
<!-- 
	   <td width="150" align="center"><A href="cool-science.jsp"><img src="../graphics/cool-science-button.gif" border="0"><br>Cool Science</a></td>
 -->
	   <td width="150" align="center"><a href="../site-index/site-map-anno.jsp"><img src="../graphics/site-map-button.gif" border="0"><br>Explore!</a></td>
	   <td width="150"align="center"><a href="about-us.jsp"><img src="../graphics/about-us-button.gif" border="0"><br>About Us</a></td></tr></table></div>
	  </c:if>  

<!-- there is no way to do this without tables unfortunately -->
			<div id="content">
			<div align="center">
							<h2>
									Scientists study cosmic rays with large arrays of detectors. You can too!

								</h2>
				
	<table width="640" height="480" bgcolor="black"><tr><td valign="center"><!--url's used in the movie-->
<!--text used in the movie-->
<!-- saved from url=(0013)about:internet -->
<script language="javascript">
	if (AC_FL_RunContent == 0) {
		alert("This page requires AC_RunActiveContent.js.");
	} else {
		AC_FL_RunContent(
			'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0',
			'width', '640',
			'height', '480',
			'src', 'cassim-animation-collision',
			'quality', 'high',
			'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
			'align', 'middle',
			'play', 'true',
			'loop', 'false',
			'scale', 'showall',
			'wmode', 'window',
			'devicefont', 'false',
			'id', 'cassim-animation-collision',
			'bgcolor', '#ffffff',
			'name', 'cassim-animation-collision',
			'menu', 'true',
			'allowFullScreen', 'false',
			'allowScriptAccess','sameDomain',
			'movie', 'cassim-animation-collision',
			'salign', ''
			); //end AC code
	}
</script>
<noscript>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="640" height="480" id="cassim-animation-collision" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="cassim-animation-collision.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />	<embed src="cassim-animation-collision.swf" quality="high" bgcolor="#ffffff" width="640" height="480" name="cassim-animation-collision" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
	</object>
</noscript>
</td></tr>
</table>
<table width="648" style="padding: 10px;">
<tr><td>
<p>Physicist, Hans-Joachim Drescher, of Frankfurt University in Germany, created the simulation that provides the background  for this animation of what happens when a cosmic ray, a proton, hits an air molecule and creates a shower of particles.  Among these particles
is a muon like the ones you can detect with your detector. Watch more of Drescher's <a href="http://th.physik.uni-frankfurt.de/~drescher/CASSIM/" target="cassim">simulations</a>.</P>
</td></tr>
</table>
			</div>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>