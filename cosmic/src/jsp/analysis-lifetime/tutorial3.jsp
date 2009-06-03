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
			<p>
			<p>
			<table width="655">
			<tr>
					<td colspan=3>
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Lifetime Study
 								</b>
							</font>
						</center>
						</td></tr>
						
						<tr><td width=233 valign=top>
						<center>
							<img src="../graphics/lifetime_example.gif">
						</center>
						</td><td width=10>
						&nbsp;
						</td>
						
				<td width=233 valign=top>
		 				&nbsp;<p>
		 			
					
						<p>The only way out is to collect many, many of these "candidates" and then plot a 
						histogram of the length between signals. Real 
						<a href="javascript:glossary('decay',350)">decays</a> will be much longer between 
						signals <i>and</i> have an exponential distribution with a "longish" time constant.	
					
				
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

