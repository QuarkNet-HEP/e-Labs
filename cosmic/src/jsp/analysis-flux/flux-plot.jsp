<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>   
<%@ include file="../analysis/results.jsp" %>

<%
	TreeMap<String,String> uploadeddata = new TreeMap<String,String>();
	ResultSet rs = null;
	In and = new In();
	and.add(new Equals("project","cosmic"));
	and.add(new Equals("type", "uploadeddata"));
	and.add(new Equals("group", user.getGroup().getName()));
	rs = elab.getDataCatalogProvider().runQuery(and);
	if (rs != null) {
 		String[] filenames = rs.getLfnArray();
 		for (int i = 0; i < filenames.length; i++){
 			VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
			if (e != null && !e.getTupleValue("name").equals("")) {
				uploadeddata.put(filenames[i], (String) e.getTupleValue("name"));
			}
		}//end for loop

	}

request.setAttribute("list",uploadeddata);
%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Flux Plot</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body class="fluxPlot" style="text-align: center;">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<script type="text/javascript" src="../include/jquery/flot083/jquery.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.time.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.time.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.errorbars.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.symbol.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.selection.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.navigate.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.crosshair.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.stack.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.text.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.canvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.compiled.js"></script>
				<script type="text/javascript" src="../include/canvas2image.js"></script>
				<script type="text/javascript" src="../include/base64.js"></script>
				<script type="text/javascript" src="flux.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "flux-get-data.jsp?id=<%=id%>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoad
					});
				}); 				
				</script>
				<div class="demo-container">
					<div id="placeholder" class="demo-placeholder" style="float:left; width:650px; height:650px;"></div>
					<div id="overview" class="demo-placeholder" style="float:right;width:160px; height:150px;"></div>
					<div id="interactive" style="float:right;width:160px; height:325px;">
						<p><label><input id="enableTooltip" type="checkbox" checked="checked"></input>Enable tooltip</label></p>
						<p>
							<label><input id="enablePosition" type="checkbox" checked="checked"></input>Show mouse position:</label>
							<br /><span id="hoverdata" class="hoverdata"></span>
							<br /><span id="clickdata" class="clickdata"></span>
						</p>				
						<p>
							<label><input id="enableSteps" type="checkbox"></input>Enable Steps</label>
						</p>
						<p class="message"></p>
						<p class="click"></p>
					</div>
					<div id="placeholderLegend" style="float:left; width:650px;"></div>
				</div>

		 	</div>
		</div>

<p> 
		<select name="externalFiles" id="externalFiles" >
 			<option></option>
 			<c:choose>
  			<c:when test="${not empty list }">
 				<c:forEach items="${list}" var="filename">
		            <option value="${filename.key }">${filename.value }</option>
		        </c:forEach>
		     </c:when>			
 			</c:choose>
         </select>         
	<input type="button" id="superImpose" value="Plot External Data" onclick="return superImpose();"/>
	<div id="msg"></div>
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
<div style="text-align:center; width: 100%;">
	Filename <input type="text" name="chartName" id="chartName" value=""></input><input type="button" name="save" onclick='return saveChart(onOffPlot, "chartName", "chartMsg", "${results.id}");' value="Save"></input>    
	<div id="chartMsg"></div>  
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
	 
</div>
				
	<div id="footer"></div>		
	</body>
</html>