<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Time of Flight study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<p>
<center>
<p>
<p>	
	
	<table width="655">
		<tr>
							<td colspan = 3>
								<center>
									<font color="#0a5ca6" size=+3>
										<b>
	 										Time of Flight Study (2)
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr><tr>
 			<td colspan=3>
 				<p>
 				1.  Use a third counter so that your muon has to pass through all three counters.  
 				This will reduce the two-muon background noise due to the two counters being too far apart.<br></br>
 				<img src="../graphics/tryPerf/ToF_3_counters_124.png"/>			
 				</p>
			    
			    <p>2.  Alternatively, you can use a third counter that will not be fired by your muon passing through the original two counters, 
			    but background muons (from other directions) will hit.  Require that this new <q>veto</q> counter does not fire in the events you select.
			    One can also intentionally set up the <q>14</q> direction so that the background 2-muon events (mainly vertical) fire the 
			    counters with a different &Delta;t than those single muons that actually travel between 1 and 4.  Use the &Delta;t shape of the 2-muon background to 
			    subtract the background from the normal 1-muon &Delta;t distribution.  <br></br>
			    <img src="../graphics/tryPerf/ToF_2_counters_14Veto.png"/> 
			    </p>	    		    
				
				<p>3.  Remember:  Not all muons go exactly vertically.  Those who travel at an angle travel a longer path.  This is a systemic error that you should estimate. 
				What are the <e:popup href="explain_longer_path.html" target="Explain Longer Path" width="450" height="200">effects of a longer path</e:popup> 
				on muon travel time between counters 1 and 4? <br></br>
				<img src="../graphics/tryPerf/ToF_3_counters_124VA.png"/> 
				</p>
				
				<p><font size="3" color="red">Just get started!</font>
				Clearly, you could keep improving your measurement by addressing each of these effects, but do not be too concerned.  Just get started.  
				Make a first measure of the muon speed by setting up the detectors in your first, best guess and see which of these effects you want to 
				attack later to make your result more accurate.<br></br>
				Click on page 3 to see some results from three counter setup.
				</p>
				
			</td>
		</tr>
				
		<tr>
			<td width=5>&nbsp;</td>					
			<td valign="top" width=322>
				&nbsp<p>
				&nbsp<p>
				
			</td>
		</tr>
				
		<tr>
			<td colspan=3>
				<p align=center> Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a></p>				
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

