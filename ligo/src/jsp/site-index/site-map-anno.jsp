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
		<link rel="stylesheet" type="text/css" href="../css/site-help.css"/>
	</head>
		<script type="text/javascript">
			function setDisplay(objectID,state) {
			    var object=document.getElementById(objectID);
			    if (object != null) object.style.visibility=state;
		    }

			function hideAll()
			{
			     setDisplay("sitehelp-home","hidden");
			     setDisplay("sitehelp-library","hidden");
			     setDisplay("sitehelp-data","hidden");
			     setDisplay("sitehelp-posters","hidden");
			     setDisplay("sitehelp-upload","hidden");
			     setDisplay("sitehelp-assessment","hidden");
			}
		</script>
	<body id="site-map-anno" class="site-index"  onLoad="hideAll();">
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
			

<table border="0" id="main">
	<tr>
		<c:if test="${param.display != 'static'}">
			<td id="left">
				<%@ include file="../include/left-alt.jsp" %>
			</td>
		</c:if>
		<td id="center">
			<h1><img src="../graphics/site-map-button.gif" border="1" style="border-color: white" valign="bottom" /> Explore! Click on hotspots in this site map.</h1>
				<p>You can always return to this page by clicking "Explore!" on the Site Index submenu.</p>
				<div id="sitemap" align="center" >
					<table width="525" cellpadding="0" cellspacing="0">
						<tr>
							<td><a href="../home/" onmouseover="javascript:hideAll();setDisplay('sitehelp-home','visible')" /><img src="../graphics/explore-home.gif"></a></td>
									<td><a href="../library/" onmouseover="javascript:hideAll();setDisplay('sitehelp-library','visible')" /><img src="../graphics/explore-library.gif"></a></td>
									<td><a href="../data/" onmouseover="javascript:hideAll();setDisplay('sitehelp-data','visible')" /><img src="../graphics/explore-data.gif"></a></td>
									<td><a href="../posters/" onmouseover="javascript:hideAll();setDisplay('sitehelp-posters','visible')" /><img src="../graphics/explore-posters.gif"></a></td>
									<td><a href="../assessment/index.jsp"  onmouseover="javascript:hideAll();setDisplay('sitehelp-assessment','visible')" /><img src="../graphics/explore-assessment.gif"></a></td>
								
							</td>
						</tr>
						<tr>
							<td width="125" valign="bottom">
								<div id="sitehelp-home">
  									<a href="../home/cool-science.jsp">Cool Science</a><br />
									<a href="../home/about-us.jsp">About Us</a><br />
									<a href="javascript:window.open('../jsp/showLogbook.jsp', 'log', 'width=800,height=600, resizable=1, scrollbars=1');return false;">Logbook</a><br />
									<a href="../library/milestones.jsp">Milestones (text)</a><br />
								</div>
							</td>
							<td width="125" valign="bottom"  align="center">
								<div id="sitehelp-library">
									<a href="/library/kiwi.php?title=Category:LIGOGLOSSARY" target="glossary"">Glossary</a><br />
									<a href="../library/resources.jsp">Resources</a><br />
									<a href="../library/big-picture.jsp">Big Picture</a><br />
									<a href="#" onclick="javascript:window.open('\/library\/kiwi.php\/LIGO_FAQ', 'faq', 'width=500,height=300, resizable=1, scrollbars=1');return false;">FAQs</a><br />
									<a href="../library/site-tips.jsp">Site Tips</a>
										</div>
							</td>
							<td width="125" valign="bottom" align="center">
								<div id="sitehelp-data">

									<a href="/ligo/tla/tutorial.php">Tutorial</a><br />
									<a href="/ligo/tla/">Bluestone</a><br />
									<a href="../plots/">View Plots</a><br />
									<a href="../analysis/list.jsp">Analyses</a>
								</div>
							</td>
							<td width="125" valign="bottom" align="center">
								<div id="sitehelp-posters">
									<a href="../posters/new.jsp">New Poster</a><br />
									<a href="../posters/edit.jsp">Edit Poster</a><br />
									<a href="../posters/view.jsp">View Posters</a><br />
									<a href="../posters/delete.jsp">Edit Poster</a><br />
									<a href="../plots?submit=true&key=group&value=guest&uploaded=true">View Plots</a><br />
									<a href="../jsp/uploadImage.jsp">Upload Image</a>
								</div>
							</td>
							<td width="125" height="110"  valign="bottom" border="0">
								<div id="sitehelp-assessment">
									<a href="../assessment/index.jsp">Assessment</a>
								</div>
							</td>
						</tr>
					</table>
				</div> <!-- end sitemap -->
		</td>
	</tr>
</table>

 

		<c:if test="${param.display == 'static'}">
  			<A HREF="javascript:window.close();">Close Window and Go Back to Home</A>
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
