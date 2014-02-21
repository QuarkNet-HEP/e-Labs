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
			
			<div id="content" style="margin-left:auto; margin-right:auto; width:80%;">
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
						We now only show data that are "blessed"; these files have passed a simple quality test.
						Data associated with your teacher will remain visible to you, blessed or not.<br /><br />
						Data Blessing checks the rates in each channel and the trigger rate for consistency. Blessing involves
						two stages in your workflow depending on whether you are uploading data with a new configuration or 
						with the same configuration.<br /><br /> 
						<div style="text-align: center;">
							<img src="../graphics/blessing-workflow.png" name="Workflow" alt="Workflow"></img>
						</div><br /><br />	
						These two stages use two methods for you to "bless" your data and make it available to e-Lab users. Each requires a benchmark file.<br /><br />					
						<ul>
							<li><strong>Manual blessing:</strong> In manual blessing, you have an opportunity to bless files that did not have a benchmark
							    when you uploaded them (Used in stage 1 as shown in the workflow above).</li><br />
							<li><strong>Automatic blessing:</strong> In automatic blessing, we compare your upload to a benchmark file you identify 
								(Used in stage 2 as shown in the workflow above).</li>
						</ul><br /><br />
						<strong>Choosing a Benchmark</strong><br /><br />
						<div style="text-align: center;">
							<img src="../graphics/benchmark-menu.jpg" name="Benchmark Menu" alt="Benchmark Menu"></img>
						</div><br />						
						To select a benchmark file, click on the Benchmark menu item and inspect the blessing plots for several existing uploads.
						After you inspect the plots, choose an appropriate file to label as benchmark. Read this 
						<a href="../analysis-blessing/benchmark-tutorial.jsp">tutorial</a> for more information.<br />
						You MUST change the benchmark file when you change the configuration (coincidence or geometry) of your detector.
						You can use the same benchmark over and over if you never change the coincidence or geometry of your detector.<br /><br />
						<strong>Manual Blessing</strong><br /><br />
						<div style="text-align: center;">
							<img src="../graphics/manual.jpg" name="Manual" alt="Manual"></img>
						</div><br />						
						You can use this method to bless files that you uploaded without automatic blessing. This method still 
						requires you to select a benchmark file or gives you an opportunity to bless data that had been compared to the 
						wrong benchmark at upload time.<br />
						Read the tutorial on <a href="../analysis-blessing/benchmark-process-tutorial.jsp">manual blessing</a><br /><br />
						<strong>Automatic Blessing</strong><br /><br />
						<div style="text-align: center;">
							<img src="../graphics/upload-menu.jpg" name="Automatic" alt="Automatic"></img>
						</div><br />
						On each data upload you will select a "benchmark" file to compare your data with. You
						define the benchmark files; they have consistent data rates and similar geometry and triggers
						to the subsequent upload files that you wish to compare them to. <br /><br />

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

