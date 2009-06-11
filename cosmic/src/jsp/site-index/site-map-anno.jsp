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
		<link href="../css/site-help.css" rel="stylesheet" type="text/css" />
	</head>
<script type="text/javascript">
    hideAll();
    
function setDisplay(objectID,state) {
    var object=document.getElementById(objectID);
    if (object != null) object.style.display=state;
    }



function hideAll()
{
     setDisplay("sitehelp-home","none");
     setDisplay("sitehelp-library","none");
     setDisplay("sitehelp-data","none");
     setDisplay("sitehelp-posters","none");
     setDisplay("sitehelp-upload","none");
     setDisplay("sitehelp-assessment","none");
}


</script>
	<body class="siteindex" onload="hideAll()">
		<!-- entire page container -->
		<div id="container">

			<c:if test="${param.display != 'static'}">
			<!-- display set to "static" allows showing a site overview without a real menu -->
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
						<%@ include file="../include/nav-rollover.jspf" %>
					</div>
				</div>
			</c:if>

<div id="content">
<h1><img src="../graphics/site-map-button.gif" border="1" style="border-color: white" valign="bottom"> Explore! Click on hotspots in this site map.</h1>
<p>You can always return to this page by clicking "Explore!" on the Site Index submenu.</p>
<div id="sitemap" align="center" >
<table width="736" cellpadding="0" cellspacing="0">
<tr><td width="128" valign="bottom">
<div id="sitehelp-home">
<a href="../home/index.jsp">Home</a><br>
<a href="../library/milestones.jsp">Milestones (text)</a><br>
<a href="../home/cool-science.jsp">Cool Science</a><br>
<a href="../home/about-us.jsp">About Us</a><br>
<a href="javascript:window.open('../jsp/showLogbook.jsp', 'log', 'width=800,height=600, resizable=1, scrollbars=1');return false;">Logbook</a><br>
<td width="122" valign="bottom"  align="center">
<div id="sitehelp-library">
<a href="../references/showAll.jsp?t=glossary">Glossary</a><br>
<a href="../library/resources.jsp">Resources</a><br>
<a href="../library/big-picture.jsp">Big Picture</a><br>
<a href="../library/FAQ.jsp">FAQs</a><br>
<a href="../library/site-help.jsp">Site Tips</a>
</div></td>
<td width="126" valign="bottom" align="center">
<div id="sitehelp-upload">
<a href="../data/upload.jsp">Upload Data</a><br>
<a href="../geometry">Geometry</a>
</div></td>
<td width="120" valign="bottom" align="center">
<div id="sitehelp-data">
<a href="../data/search.jsp">View Data</a><br>
<a href="../analysis-performance/">Performance</a><br>
<a href="../analysis-flux/">Flux</a><br>
<a href="../analysis-shower/">Shower</a><br>
<a href="../analysis-lifetime/">Lifetime</a><br>
<a href="../plots/">View Plots</a><br>
<a href="../analysis/list.jsp">Analyses</a>
</div></td>
<td width="116" valign="bottom" align="center">
<div id="sitehelp-posters">
<a href="../posters/new.jsp">New Poster</a><br>
<a href="../posters/edit.jsp">Edit Poster</a><br>
<a href="../posters/view.jsp">View Posters</a><br>
<a href="../posters/delete.jsp">Edit Poster</a><br>
<a href="../plots?submit=true&key=group&value=guest&uploaded=true">View Plots</a><br>
<a href="../jsp/uploadImage.jsp">Upload Image</a>
</div></td>
<td width="116" height="110"  valign="bottom" border="0"><div id="sitehelp-assessment">
<a href="../assessment/index.jsp">Assessment</a>
</div></td></tr>
<tr><td colspan="6" >
<img src="../graphics/site-map.gif" width="736" height="170" border="0" alt="" usemap="#site_map2_Map">
<map name="site_map2_Map">
<area shape="rect" alt="" coords="0,1,119,167" href="../home/" onmouseover="javascript:hideAll();setDisplay('sitehelp-home','block')">
<area shape="rect" alt="" coords="614,0,734,108" href="../assessment/index.jsp"  onmouseover="javascript:hideAll();setDisplay('sitehelp-assessment','block')">
<area shape="rect" alt="" coords="498,0,614,158" href="../posters/" onmouseover="javascript:hideAll();setDisplay('sitehelp-posters','block')">
<area shape="rect" alt="" coords="377,1,496,160" href="../data/" onmouseover="javascript:hideAll();setDisplay('sitehelp-data','block')">
<area shape="rect" alt="" coords="251,1,373,134" href="../data/upload.jsp" onmouseover="javascript:hideAll();setDisplay('sitehelp-upload','block')">
<area shape="rect" alt="" coords="127,0,254,170" href="../library/" onmouseover="javascript:hideAll();setDisplay('sitehelp-library','block')">
</map>
</td></tr></table>
</div> <!-- end sitemap -->
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
</BODY>
</HTML>
