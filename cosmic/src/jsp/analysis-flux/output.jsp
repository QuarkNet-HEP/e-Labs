<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>

<% 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Flux Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="flux-study-output" class="data, analysis-output" onload="populateInputs()">
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
	<a href="../analysis-blessing/bless-plots-range.jsp?id=${results.id }">View blessing plots</a>
</p>
<p>
	<a href="../analysis-blessing/rate-pressure.jsp?id=${results.id }">View rate vs. pressure</a>
</p>

<%--<p>
	<a href="flux-plot.jsp?id=${results.id }&message=${message}">View interactive Flux plots</a> (Beta Version)<br />
</p>--%>

<p>
	<img src="${results.outputDirURL}/plot.png"/>
</p>
<p>
  Analysis run time: ${results.formattedRunTime} 
  <%-- estimated: ${results.formattedEstimatedRunTime} --%>
</p>
<p>
  Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
    width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>
<p>
  <e:rerun type="flux" id="${results.id}" label="Change"/> your parameters 
</p>

<% if (!user.isGuest()) { %>
<p><b>OR</b></p>
<p>To save this plot permanently, enter the new name you want.</p>
<p>Then click <b>Save Plot</b>.</p>
  <form name="SaveForm" action="../analysis/save.jsp"  method="post" target="saveWindow" onsubmit='return validatePlotName("newPlotName");' align="center" class="framed">
    <e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
    <e:creationDateMetadata/>
    <input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::FluxStudy"/>
    <input type="hidden" name="metadata" value="study string flux"/>
    <input type="hidden" name="metadata" value="type string plot"/>

    <input type="hidden" name="metadata" value="title string ${results.analysis.parameters['plot_title']}"/>
    <input type="hidden" name="metadata" value="caption string ${results.analysis.parameters['plot_caption']}"/>

    <input type="hidden" name="srcFile" value="plot.png"/>
    <input type="hidden" name="srcThumb" value="plot_thm.png"/>
    <input type="hidden" name="srcSvg" value="plot.svg"/>
    <input type="hidden" name="srcFileType" value="png"/>
    <input type="hidden" name="id" value="${results.id}"/>
    <div class="dropdown" style="text-align: left; width: 180px;">
      <input type="text" name="name" id="newPlotName" size="20" maxlength="30" />
      <%@ include file="../plots/view-saved-plot-names.jsp" %>
    </div>(View your saved plot names)<br />
    <input type="submit" name="submit" value="Save Plot"/>
  </form>
<% } %>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
