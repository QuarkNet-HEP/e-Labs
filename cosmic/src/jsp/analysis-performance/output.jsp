<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Performance Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="performance-study-output" class="data, analysis-output">
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
	<img src="${results.outputDirURL}/plot.png"/>
</p>
<p>
	Analysis run time: ${results.formattedRunTime}; estimated: ${results.formattedEstimatedRunTime}
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>
<p>
	<e:rerun type="performance" id="${results.id}" label="Change"/> your parameters	
</p>
<p><b>OR</b></p>
<p>To save this plot permanently, enter the new name you want.</p>
<p>Then click <b>Save Plot</b>.</p>
<p>
	<form name="SaveForm" action="../analysis/save.jsp"  method="post" target="saveWindow" onsubmit="window.open('',this.target,'width=500,height=200,resizable=1');" align="center">
		<e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
		<e:creationDateMetadata/>
		<input type="hidden" name="metadata" value="transformation string Quarknet.Cosmic::PerformanceStudy"/>
		<input type="hidden" name="metadata" value="study string performance"/>
		<input type="hidden" name="metadata" value="type string plot"/>
		<input type="hidden" name="metadata" value="bins float ${results.analysis.parameters['freq_binValue']}"/>
		<input type="hidden" name="metadata" value="channel string ${results.analysis.parameters['singlechannel_channel']}"/>

		<input type="hidden" name="metadata" value="title string ${results.analysis.parameters['plot_title']}"/>
		<input type="hidden" name="metadata" value="caption string ${results.analysis.parameters['plot_caption']}"/>

		<input type="hidden" name="srcFile" value="plot.png"/>
		<input type="hidden" name="srcThumb" value="plot_thm.png"/>
		<input type="hidden" name="srcSvg" value="plot.svg"/>
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
