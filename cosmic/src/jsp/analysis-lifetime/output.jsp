<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Lifetime Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="lifetime-study-output" class="data, analysis-output">
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
	<img src="${results.outputDirURL}/plot.png"/>
</p>
<p>
	<e:rerun type="lifetime" analysis="${results.analysis}" label="Change"/> your parameters
</p>
<p><b>OR</b></p>
<p>To save this plot permanently, enter the new name you want.</p>
<p>Then click <b>Save Plot</b>.</p>
<p>
	<form name="SaveForm" action="../analysis/save.jsp"  method="post" target="saveWindow" onsubmit="window.open('',this.target,'width=500,height=200');" align="center">
		<e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
		<input type="hidden" name="metadata" value="transformation string Quarknet.Cosmic::LifetimeStudy"/>
		<input type="hidden" name="metadata" value="study string lifetime"/>
		<input type="hidden" name="metadata" value="type string plot"/>
		<input type="hidden" name="metadata" value="bins int ${results.analysis.parameters['freq_binValue']}"/>

		<input type="hidden" name="metadata" value="title string ${results.analysis.parameters['plot_title']}"/>
		<input type="hidden" name="metadata" value="caption string ${results.analysis.parameters['plot_caption']}"/>

		<input type="hidden" name="srcFile" value="plot.png"/>
		<input type="hidden" name="srcThumb" value="plot_thm.png"/>
		<input type="hidden" name="srcFileType" value="png"/>
		<input type="hidden" name="id" value="${results.id}"/>
		<input type="text" name="name"  size="20" maxlength="30"/>.png
		<input type="submit" name="submit" value="Save Plot"/>
	</form>
</p>



			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
