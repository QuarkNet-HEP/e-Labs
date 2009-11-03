<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>CMS Beam Purity</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Beam Purity Study</h1>
<h2>Using OGRE to Determine the Beam Purity</h2>
<h3>What is the composition of the beam?</h3>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<div class="tab">
					<span class="tab-title">Analysis</span>
					<div class="tab-contents">
						<p>
							<a href="background.jsp">Beam Purity Tutorial</a> -
							Read background information about the shower study.
						</p>
						<p>
							<a href="/~ogre/"  target="ogre">Access OGRE</a> -
							Do your analysis with OGRE (Online Graphical ROOT Environment). Remember to save any good plots so you can upload
							them when you make a poster.
						</p>
						<p>
							<a href="http://www-root.fnal.gov/root/">ROOT Tutorial</a> - 
							Learn how to use ROOT (the underpinnings of OGRE) to analyze
							any aspect of the data directly. (Recommended for Advanced Users)
						</p>
					</div>
				</div>		
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
