<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Flux study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="performance" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

			<p>
			<p>
			<center>
				You can:
				<ol>
						 <li> Find some help on this page</li>
						<li><e:popup href="../posters/display.jsp?type=poster&name=adler_flux.data"
							target="Possible Particle Decays" width="700" height="510">View</e:popup> 
							a poster created using this study
						</li>
						<li><a href="javascript:openPopup('tryit_flux.html','TryIt',510,600); ">Try it</a>: 
						Step-by-Step Instructions</li>
			</center>			
	
			<p>
			<center>        
			<p>
			<p>
			<table width = 650 cellpadding =8>
				<tr>
					<td colspan = 2>
						<center>
							<font color="#0a5ca6" size=+3>
								<b>
	 								Flux Study
	 							</b>
	 						</font>
	 					</center>
	 				</td>
	 			</tr>
				
				
				<tr>
		 			<td width = 321 valign = top>
		 				This is the analysis path for the <a HREF="javascript:glossary('flux',100)">flux</a> study. 
					</td>
					
					<td width = 321 valign = top>
						You may be interested in looking at flux throughout the day or year to see if there are changes in the rain of these particles.<p>
					</td>
				</tr>
				
				<tr>
					<td colspan = 2>
						<img src="../graphics/fluxDAG.png" align="middle">
					</td>
				</tr>
	
				<tr>
			
					<td valign=top>
						<img src="../graphics/flux.png" width = 294 height = 304>
					</td>
			
					<td valign=top>
						&nbsp<p>
											
						The plot to the left shows <a HREF="javascript:glossary('flux',350)">flux</a> 
						measurements for <a HREF="javascript:glossary('detector',350)">detector # 180 </a> 
						on 8 August 2003. The measurements start around <a HREF="javascript:glossary('GMT',100)">17:19</a>
						 and end 36 minutes later at <a HREF="javascript:glossary('GMT',100)">17:45.</a><p>
						One interesting feature occurs between <a HREF="javascript:glossary('GMT',100)">17:31</a> and 
						<a HREF="javascript:glossary('GMT',100)">17:33</a>-the 
						<a HREF="javascript:glossary('flux',100)">flux</a> drops from 20,000 units to very 
						small values in a short time. What might cause this? Is the effect real or is it some 
						artifact of the way this file was plotted? Is there a way that you can tell?
					</td>
				</tr>
			</table>
		</center>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

