<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark process tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark-process-tutorial" class="data, tutorial">
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
					<td style="text-align: center;"><font color="#0a5ca6" size="+3">Tutorial for manual blessing of data files</font></td>
				</tr>
				<tr>
					<td style="text-align: left;">
						To manually "bless" a data file or a set of files, first select the DAQ# from the pull-down list:<br /><br />
						<div style="text-align: center;">
							<img src="../graphics/blessing_drop_down.png" name="Detector drop down" alt="Detector drop down"></img>
						</div>
						<br />					
						To display the list of potential files to be "blessed", click the Retrieve all box. The list will then appear though
						it may take a moment to generate the list; please be patient.<br /><br />
						From the candidates list, you can select individual files or "Bless all files" will attempt to verify the entire
						list. Shown are two files selected. The singles and trigger rate plots for the highlighted file are displayed.<br /><br />
						<div style="text-align: center;">							
							<img src="../graphics/files_to_bless.png" name="Good Example" alt="Good Example" width="700px"></img>
						</div><br /><br />
						From the Benchmark pull-down list, select the standard file you wish to compare to the candidate file:<br /><br />
						<div style="text-align: center;">
							<img src="../graphics/benchmark.png" name="Detector drop down" alt="Detector drop down"></img>
						</div>
						<br />					
						and now click "Check Selected Files" and the CR e-Lab will compare the rates and errors to see if passes.<br /><br />
						<div style="text-align: center;">
							<img src="../graphics/check_selected_files.png" name="Check Selected Files" alt="Check Selected Files"></img>
						</div>
						<br />							
						In this case, one file was "blessed" and the one file failed.<br /><br />
						<div style="text-align: center;">
							<img src="../graphics/blessing_results.png" name="Blessing results" alt="Blessing results"></img>
						</div>	
						<br />
						Using this manual method, large block or specific files can be reviewed and blessed.
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

