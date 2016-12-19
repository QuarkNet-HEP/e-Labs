<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Lifetime study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="lifetime-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			
			You can:
				<strong>1)</strong> Find some help on this page
				<strong>2)</strong> 
					<e:popup href="../posters/display.jsp?type=poster&amp;name=lifetime_16may16-cosmic-crdata-robert_s._peterson-fermilab_test_array-batavia-il-2016.1114.data" 
						target="MuonLifetime" width="700" height="510">View</e:popup> a poster 
					created using this study
				<strong>3)</strong> 
					<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: 
					Step-by-Step Instructions
	
	<p>
			<center>
			<table width = "655" cellpadding ="8">
				<tr>
					<td colspan = "3">
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Lifetime Study
 								</b>
							</font>
						</center>
					</td>
				</tr>
			
				<tr>			
				<p align=center><font size=+2><b>From Raw Data to Plot</b></font></p>
				
						<img src="../graphics/lifetimeDAG.png" alt="">
						<p>
						<hr>
						<p>
					</td>
				</tr>
								
				<tr>
					
					</td>
				</tr>
				
				<tr>
					<td colspan=3>
						&nbsp;
						<p align=center> Tutorial Pages: <a href="tutorial.jsp">1</a> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> <b>4</b> & <a href="index.jsp">Analysis</a></p>	
					</td>
				</tr>
			</table>
			<p>
		</center>
		
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>



