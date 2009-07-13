<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Site Tips</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
		
	<body id="site-tips" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>

			<div id="content">


<table border="0" id="main">
	<tr>
		<td id="left">
			<%@ include file="../include/left-alt.jsp" %>
		</td>
		<td id="center">


<h1>Site Tips: Use these tips to help you use the e-Lab.</h1>
<p>
  <em>Use</em><font class=content_text> the Project Map on the home page to guide your research.
</p>
<p>
  <em>Use</em><font class=content_text> the navigation bars and the links in the sidebars to help you! The top 
  navigation bar gives you access to the main parts of the e-Lab. The sidebar 
  links give you additional science resources, a Bluestone tutorial, a 
  Bluestone link.
</p>
<p>
  <em>Watch</em><font class=content_text> for little icons on the e-Lab 
  screens. Clicking on <img src="../graphics/ref.gif" /> will give you a 
  reference popup that will help with a milestone.  The logbook icon, 
  <img src="../graphics/logbook_pencil.gif" align="middle" />, will open 
  your electronic log book. The looking glass, 
  <img src="../graphics/logbook_view_comments_small.gif" align="middle" />, 
  lets you access teacher comments about your log entries.
</p>
<p>
  <em>The heart</em><font class=content_text> of the LIGO e-Lab is software
   named <a href="/ligo/tla/">Bluestone</a>. 
   Bluestone lets you to select the LIGO data channels that you wish to 
   view and lets you control the features of the plots that you make.
   Bluestone mimics software that LIGO scientists and engineers use at the 
   Observatory sites.  Your teacher will show you how to use Bluestone.
</p> 
<p>
  <em>Another</em> key feature of the LIGO e-Lab is a comprehensive
   portal site.   Here you will also find a
   <a href="/glossary/">glossary</a>, 
   along with 
  <a href="/forum_index.php">discussion rooms</a>
  in which you can share research ideas with others.
  Your teacher will tell you how to log in.
</p>



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
