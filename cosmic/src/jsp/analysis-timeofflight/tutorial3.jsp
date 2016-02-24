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
	 										Time of Flight Study (3)
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr><tr>
 			<td colspan=3>
 			
			    <p>1.  Place counter 2 in between 1 and 4.  Measure &Delta;t between 1 and 4 (and 4 and 1).<br></br>  
				<img src="../graphics/tryPerf/ToF_3_counters_124and421.png"/> <br></br>
				Sample Results (from 1-4 setup?):<br></br>
				
				</p>
				
				<p>2.  Counters at an angle.<br>
				
				a.)  Set up the following configuration to measure muons coming in at an angle.   <br></br>
				<img src="../graphics/tryPerf/ToF_2_counters_41A.png"/> 
				<img src="../graphics/tryPerf/TOF_4-1_-650cm_14_all_4dec.tiff"/><br></br>
				
				b.)  Set up the configuration above with counter 2 between 1 and 4. <br></br>
				<img src="../graphics/tryPerf/ToF_3_counters_421A.png"/> 
				<img src="../graphics/tryPerf/TOF_4-1_-650cm_142_all_4dec.tiff"/><br></br>
				As you can see from the graph, the addition of counter 2 does not make much difference.<br></br>
				
				c.)  Reverse the setup in b.) (reverse counters 1 and 4).   <br></br>
				<img src="../graphics/tryPerf/ToF_3_counters_124A.png"/> 
				<img src="../graphics/tryPerf/TOF_4-1_650cm_14_all_3dec.tiff"/><br></br>
				Notice that this graph is basically the mirror image of the graph in b.).<br></br>

				</p>
				
				<p>3.  The following configuration will also measure muons coming in at an angle.  We include a 
				veto counter (2).  <br></br>
				<img src="../graphics/tryPerf/ToF_3_counters_14AVeto.png"/> 
				<img src="../graphics/tryPerf/TOF_4-1_-650cm_142v_all_4dec.tiff"/><br></br>

				<img src="../graphics/tryPerf/ToF_3_counters_14AVeto.png"/> <br></br>
				Explain...<br></br>
				Results:<br></br>
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
				<p align=center> Tutorial Pages: <a href="tutorial.jsp">1</a> <a href="tutorial2.jsp">2</a> <b>3</b> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a></p>				
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

