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
<script src="AC_RunActiveContent.js" language="javascript"></script>
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
				
<h1>Cool Science: Studying CMS test beam data &mdash; solving scientific mysteries!</h1>
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
							<h2>Scientists are trying to answer questions about the nature of matter<br>
							and the universe by analyzing data from the Compact Muon Solenoid<br>Collaboration, CMS, experiment at CERN in Geneva. Join them!
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
			'src', 'CMS_Slice',
			'quality', 'high',
			'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
			'align', 'middle',
			'play', 'true',
			'loop', 'false',
			'scale', 'showall',
			'wmode', 'window',
			'devicefont', 'false',
			'id', 'CMS_Slice',
			'bgcolor', '#ffffff',
			'name', 'CMS_Slice',
			'menu', 'true',
			'allowFullScreen', 'false',
			'allowScriptAccess','sameDomain',
			'movie', 'CMS_Slice',
			'salign', ''
			); //end AC code
	}
</script>
<noscript>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="640" height="480" id="CMS_Slice" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="CMS_Slice.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />	<embed src="CMS_Slice.swf" quality="high" bgcolor="#ffffff" width="640" height="480" name="CMS_Slice" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
	</object>
</noscript>
</td></tr>
</table>
<table width="648" style="padding: 10px;">
<tr><td><p>Scientists must understand how well their detector works before taking real collider data. They bombard each detector component with known particles and<br>collect and analyze "test beam data".</p>
<p>This interactive from the CERN laboratory in Geneva shows how particles move through the CMS detector.  Click on one of the particles to see how it is trapped in the various sub-detectors and its characteristics measured.
</p></td></tr>
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