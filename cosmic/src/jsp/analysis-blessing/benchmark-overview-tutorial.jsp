<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark Overview</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark-overview-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content" style="margin-left:auto; margin-right:auto; width:60%;">
			<table width="80%" cellpadding ="8">
				<tr>
					<td style="text-align: center;"><font color="#ad499d" size="+3">Overview of Data Blessing</font></td>
				</tr>
				<tr>
					<td>Other Blessing Tutorials: 
						<a href="../analysis-blessing/benchmark-tutorial.jsp">Benchmark</a> |
						<a href="../analysis-blessing/benchmark-process-tutorial.jsp">Blessing</a><br /><br />
					</td>
				</tr>
				<tr>
					<td style="text-align: left;">
						We now only show data that are "blessed"; these files have passed a simple quality screen.
						Only groups that share a teacher with the uploader can see files that do not pass this quality screening.<br /><br />
						Data Blessing checks the rates in each channel and the trigger rate for consistency. We have 
						introduced two methods for you to "bless" your data and make it available to e-Lab users.
						<ul>
							<li>In automatic blessing, we compare your upload to a benchmark file you identify.</li>
							<li>In manual blessing, you have an opportunity to bless files that did not have a benchmark
							    when you uploaded them.</li>
						</ul>
						We say more about each step below.<br /><br />
						<strong>Method 1 (automatic)</strong><br />
						This method involves these menu items.
						<div style="text-align: center;">
							<img src="../graphics/automatic.jpg" name="Automatic" alt="Automatic"></img>
						</div><br />
						On each data upload you will select a "benchmark" file to compare your data with. You
						define the benchmark files; they have consistent data rates and similar geometry and triggers
						to the subsequent upload files that you wish to compare them to. To select a benchmark file,
						click on the Benchmark menu item and inspect the blessing plots for several existing uploads.
						After you inspect the plots, choose an appropriate file to label as benchmark. Read this 
						<a href="../analysis-blessing/benchmark-tutorial.jsp">tutorial</a> for more information.<br /><br />
						You MUST change the benchmark file when you change the configuration (coincidence or geometry) of your detector.
						You can use the same benchmark over and over if you never change the coincidence or geometry of your detector.<br /><br />
						<strong>Method 2 (manual)</strong><br />
						<div style="text-align: center;">
							<img src="../graphics/manual.jpg" name="Manual" alt="Manual"></img>
						</div><br />						
						You can use this method to bless files that you elected to upload without automatic blessing. This method still 
						requires you to select a benchmark file or gives you an opportunity to bless data that had been compared to the 
						wrong benchmark at upload time.<br />
						Read the tutorial on <a href="../analysis-blessing/benchmark-process-tutorial.jsp">manual blessing</a><br />
					</td>
	 			</tr>
			</table>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

