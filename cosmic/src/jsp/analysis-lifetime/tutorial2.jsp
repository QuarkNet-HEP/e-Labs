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
					<td valign="top" width=322>
						<center>
							<img src="../graphics/lifetime_example.gif">
						</center>
					</td>
					<td width=5>&nbsp;
							</td>
					
					<td valign = "top" width=322>
					&nbsp;<p>
					
						Muon decay follows an exponential law&mdash;just like radioactive decay and many other natural phenomena. 
						<a href="http://www.purplemath.com/modules/graphexp.htm">Exponential plots</a> have a characteristic shape.<p>
						
						Finding the value of the exponent leads to the 
						lifetime of the particle&mdash;one of many characteristics that allow us to describe 
						particles. Others include mass and electric charge.<p>
						<P>
						We measure the time between two <a href="javascript:glossary('signal',350)">signals</a>  in the same counter and look for patterns in the time difference between two consecutive signals. 
						The difference may result from a muon decay. 
						<p>Two types of backgrounds are minimized in the accompanying example.   
						<ol>
							<li>Hardware errors on some signals with large pulse widths can generate fake second-hits at very small times, so times are excluded below 100ns.</li>
							<li>The DAQ was configured so it did not collect times above 10 microseconds in a single triggered event.  Second hits in counter 2 could resulting from things other than an electron. 
							For example, noise or a second muon can occur randomly and would occupy the regions at longer times.</li>
						</ol>
						<p>If we plot a histogram of the length between signals for many of these candidate decays, we can fit the result with an exponential 
		 				distribution for the <a href="javascript:glossary('decay',350)">decays</a> plus a flat component for any random backgrounds.  
		 				The mean lifetime from that fit is shown in the plot as 2.2 microseconds.	
					</td>
				</tr>
				<tr>
					<td colspan=3>
						&nbsp;
						<p align=center>Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> &amp; <a href="index.jsp">Analysis</a>
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



