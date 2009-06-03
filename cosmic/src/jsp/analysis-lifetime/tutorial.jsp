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
					<e:popup href="../posters/display.jsp?type=poster&amp;name=poster_decays.data" 
						target="PossibleParticleDecays" width="700" height="510">View</e:popup> a poster 
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
					<td colspan=3>
		 				
					
						
						Some short-lived cosmic rays <a href="javascript:glossary('muon',100)">muons</a> that reach Earth's surface  may stop in a <a href="javascript:glossary('counter',350)">counter</a>, 
						wait around a while and then <a href="javascript:glossary('decay',350)">decay</a>  into an electron, a neutrino and an anti-neutrino. The muon will leave one signature in the detector, the electron will leave another. You can ask, "How long before the muon decays?" "What is their <a href="javascript:glossary('lifetime',100)">
						lifetime</a>?"<br> (How the <A href="../flash/daq_only_standalone.html">detector works</a>) 
					
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
					<td valign="top" width=322>
						<center>
							<img src="../graphics/lifetime_example.gif">
						</center>
					</td>
					<td width=5>&nbsp;
							</td>
					
					<td valign = "top" width=322>
					&nbsp;<p>
					
					Muon
						decay follows an exponential 
						law&mdash;just like radioactive decay and many other natural phenomenon. 
						<a href="http://www.purplemath.com/modules/graphexp.htm">Exponential plots</a> have a characteristic shape.<p>
						
						Finding the value of the exponent leads to the 
						lifetime of the particle&mdash;one of many characteristics that allow us to describe 
						particles. Others include mass and electric charge.<p>
						<P>
						We measure the time between two <a href="javascript:glossary('signal',350)">signals</a>  in the same counter and look for patterns in the time difference between two consecutive signals. Occasionally the difference will be from a decay. Seeing many of these can increase your confidence in what you are observing.
						</td></tr>
						<tr>
						<td colspan=3>
						&nbsp;
						<p align=center> Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a>  & <a href="index.jsp">Analysis</a>
				</p>
						
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



