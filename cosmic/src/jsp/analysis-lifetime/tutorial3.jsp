<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
		<h1>Lifetime Study</h1>
<p>
			<center>
			
			<table width = "650" cellpadding ="8">
				<tr>
					<td width="321" valign="top">
		 				We can't tell if the second light <a href="javascript:glossary('pulse',350)">pulse</a> 
		 				is from an electron (indicating a decay) or from the next 
		 				<a href="javascript:glossary('muon',100)">muon</a> coming through the dectector. 
		 				They both look similar to the <a href="javascript:glossary('photomultiplier_tube',100)">PMT</a>.
					</td>
					
					<td width = "321" valign="top">
						The only way out is to collect many, many of these "candidates" and then plot a 
						histogram of the length between flashes. Real 
						<a href="javascript:glossary('decay',350)">decays</a> will be much longer between 
						flashes <i>and</i> have an exponential distribution with a "longish" time constant.	
					</td>
				</tr>
				
				<tr>
					<td colspan="2" valign="top" align = "center">
												
						<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" 
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
					</td>
				</tr>
				
				<tr>
					<td colspan = "2" align="right">
						Go back to the <a href="index.jsp">analysis</a>
					</td>
					
					<td>
						&nbsp
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

