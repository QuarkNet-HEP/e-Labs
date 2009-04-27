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


<script type="text/javascript">
function setDisplay(objectID,state) {
	var object = document.getElementById(objectID);	
	object.style.display = state;
}
</script>
</head>
	
	<body id="lifetime-tutorial" class="data, tutorial">
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
			<center>
			<p>
			<p>
			<table width="655">
			<tr>
					<td>
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Lifetime Study
 								</b>
							</font>
					</center>
						&nbsp;<p>
					
					
		 				Cosmic ray <a href="javascript:glossary('muon',100)">muons</a> reach the detector with 
		 				varying amounts of energy and deposit that energy in the 
		 				<a href="javascript:glossary('counter',350)">counter</a>. Some are trapped in the 
		 				counter and eventually <a href="javascript:glossary('decay',350)">decay</a> into 
		 				an electron, a neutrino and an anti-neutrino.
					These three new particles zoom away (to conserve the momentum of the stopped muon). 
						
					<p>&nbsp;
					<center>
						<img src="../graphics/decay.gif" alt="" width="508" height="220"/>
				</center>
					<p>&nbsp;
				
<<<<<<< .mine
				<tr>
					<td colspan="2" valign="top" align="center">
						<div id="image" style="display:block"><a href="javascript:setDisplay('image','none');setDisplay('movie','block');">
						<img src="../graphics/decay.gif" alt="" width="508" height="220" align="middle"/></a></div>
						
						<div id="movie"  style="display:none"><object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" 
							codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" 
							width="504" height="216" id="muondecay2" align="middle">
							<param name="allowScriptAccess" value="sameDomain" />
							<param name="movie" value="../flash/muondecay2.swf" />
							<param name="quality" value="high" />
							<param name="bgcolor" value="#ffffff" />
							<embed src="../flash/muondecay2.swf" quality="high" bgcolor="#ffffff" width="504" 
							height="216" name="muondecay2" align="middle" allowscriptaccess="sameDomain" 
							type="application/x-shockwave-flash" 
							pluginspage="http://www.macromedia.com/go/getflashplayer"/>
						</object>
						</div>
<p>Click to see an animation.</p>
					</td>
				</tr>
				
				<tr>
					<td colspan ="2">
							
					</td>
				</tr>
				
				<tr>
					<td width = "321" valign="top">
						Once the PMT "sees" the electron, we know the amount of time between the muon 
						stopping and decaying. The node that asks "Any Decays" looks for a light 
						signal from one counter (the incoming muon) and then waits. 
					</td>
=======
							<p>Once the charged electon leaves a signal in the detector, we know the amount of time between the muon 
						stopping and decaying. <p>We look for a 
						signal from one counter (the incoming muon) and then wait. 
					
						If we see another signal within the same counter before the time window closes, we may 
						have a decay! 
						<p>There is one unresolvable problem with this method. . . we can't tell if the second signal
		 				is from an electron (indicating a decay) or from the next 
		 				muon coming through the dectector. 
		 				They both look similar to the <a href="javascript:glossary('photomultiplier_tube',100)">photomultiplier tube</a>.
>>>>>>> .r1793
					
					<p>&nbsp;
					<center>
						<p>Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> & 	<a href="index.jsp">Analysis</a>
						</center>
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

