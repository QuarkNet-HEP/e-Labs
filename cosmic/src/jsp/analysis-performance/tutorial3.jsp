<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Performance study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="performance-tutorial" class="data, tutorial">
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
			<table width=655>
					<td colspan = 3>
								<center>
									<font color="#0a5ca6" size=+3>
								
										<b>
	 										Detector Performance Study
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr>
				<tr>
				
					<td valign=top width=322>
						&nbsp<p>
						<img src="../graphics/Ballard3.gif" alt="">
							<p>&nbsp
					</td>
					<td width=10>&nbsp
					</td>
					<td valign=top width=322>
						&nbsp<p>
						This particular graph shows a very noisy counter with a large peak centered at 3 ns. 
						This peak is so large that it may be masking the good data  centered near 8 ns that we saw previously.
<p>


						In a very loose sense, time over threshold is a measure of the amount of energy deposited in the 
						<a HREF="javascript:glossary('scintillator',350)">scintillator</a> for a given 
						<a HREF="javascript:glossary('muon',100)">muon</a>. There is a correlation 
						between the <a HREF="javascript:glossary('signal_width',350)">width of the signal</a> 
						in time and the height of the signal. 

						
					</td>
					
				
				</tr>
			
				<tr>
					<td align=center colspan=3>
					
						
					Tutorial Pages: <a href="tutorial.jsp">1</a> <a href="tutorial2.jsp">2</a> <b>3</b> &
						
					
						<a href="index.jsp">Analysis</a>
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
