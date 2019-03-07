<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ include file="../analysis/results.jsp" %>

<%
	String message = request.getParameter("message");
	//create the file for the dynamic charts
	String ratePressurePlot = results.getOutputDir() + "/RatePressureFlotPlot";
	File[] pfns = null;
	String[] filenames = null;
	try {
		//this code is for admin to be able to see the graph
		File f = new File(ratePressurePlot);
		if (!f.exists()) {
				String userParam = (String) request.getParameter("user");
				if (userParam == null) {
					userParam = (String) session.getAttribute("userParam");
				}
				session.setAttribute("userParam", userParam);
				ElabGroup auser = user;
				if (userParam != null) {
				    if (!user.isAdmin()) {
				    	throw new ElabJspException("You must be logged in as an administrator" 
				        	+ "to see the status of other users' analyses");
				    }
				    else {
				        auser = elab.getUserManagementProvider().getGroup(userParam);
				    }
				}
				ArrayList fileArray = (ArrayList) results.getAttribute("inputfiles");
				//Collections.sort(fileArray);
			
				if (fileArray != null) {
					pfns = new File[fileArray.size()];
					filenames = new String[fileArray.size()];
					for (int i = 0; i < fileArray.size(); i++) {
						if (!fileArray.get(i).equals("[]") && !fileArray.get(i).equals("")) {
							String temp = (String) fileArray.get(i);				
							String cleanname = temp.replace(" ","");
							String pfn = RawDataFileResolver.getDefault().resolve(elab, cleanname) + ".bless";
							pfns[i] = new File(pfn);
							filenames[i] = cleanname;
						}
					}			
					if (pfns.length > 0) {
						String binValue = results.getAnalysis().getParameter("flux_binWidth").toString();
					    Double bV = Double.valueOf(binValue);
						RatePressure rp = new RatePressure(elab,pfns,bV,filenames,results.getOutputDir());
					}
				}
		}
	} catch (Exception e) {
			message = e.getMessage();
	}	
	
	ArrayList<String> fileArray = (ArrayList<String>) results.getAttribute("inputfiles");
	//Collections.sort(fileArray);
	BlessPlotDisplay bpd = new BlessPlotDisplay();
	ArrayList<String> fileIcons = new ArrayList<String>();
	for (int i = 0; i < fileArray.size(); i++) {
		    String filename = fileArray.get(i);
		  	String iconLinks = bpd.getIcons(elab, filename);
		  	fileIcons.add(filename+" "+iconLinks);
	}
	  
	request.setAttribute("fileArray", fileArray);
	request.setAttribute("fileIcons", fileIcons);
	request.setAttribute("id", id);
	request.setAttribute("outputDir", results.getOutputDirURL());
	request.setAttribute("message", message);
	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Rate vs Pressure From Flux Study</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>		
		<link rel="stylesheet" type="text/css" href="../css/interactive-cosmic-plots.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="ratevspressure"  >
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			<script type="text/javascript" src="../include/elab.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.time.js"></script>
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
			<script type="text/javascript" src="../include/jquery/flot083/d3.v3.min.js"></script>
			<script type="text/javascript" src="../include/json/json.worker.js"></script>
			<script type="text/javascript" src="../include/json/json.async.js"></script>
			<script type="text/javascript" src="../include/canvas2image.js"></script>
			<script type="text/javascript" src="../include/base64.js"></script>
			<script type="text/javascript" src="../analysis/analysis-plot.js"></script>
			<script type="text/javascript" src="rate-pressure.js"></script>
		<script>
		$(document).ready(function() {
			$.ajax({
				type: "GET",
				success: onDataLoad
			});
		});

		</script>	
<h1>View rate vs pressure</h1>
<div style="text-align: center;"><a href="../analysis-flux/output.jsp?id=${id}">Go back to Flux Study</a>
	<c:choose>
		<c:when test="${empty message }">
			<div class="graph-container-rate-pressure">
				<div id="chartTrigger" style="text-align: center; width:700px; height:260px;">
					<div id="rate-pressure-title"><strong>Trigger with Pressure Correction</strong></div>
					<div id="trigPressChart" style="width:700px; height:250px; text-align: center;"></div>
					<div id="singleTrigPressChart" style="width:700px; height:250px; text-align: center;"></div>
					<div id="triggerChart" style="width:700px; height:250px; text-align: center;"></div>
					<div id="pressureChart" style="width:700px; height:250px; text-align: center;"></div>
				</div>
			</div>	
			<div style="text-align: center;">
				<p>
					Analysis run time: ${results.formattedRunTime}; estimated: ${results.formattedEstimatedRunTime}
				</p>
				<p>
					Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
						width="800" height="600" toolbar="true">analysis directory</e:popup>
				</p>
				<p>
					<e:rerun type="flux" id="${results.id}" label="Change"/> your parameters	
				</p>
			</div>
			<% if (!user.isGuest()) { %>		
					<div style="text-align:center; width: 100%;">
						<p>To save this plot permanently, enter the new name you want.</p>
						<p>Then click <b>Save Plot</b>.</p>
	
						<div class="dropdown" style="text-align: left; width: 180px;">
							<input type="text" name="newPlotName" id="newPlotName" value="" size="20" maxlength="30"/>
							<%@ include file="../plots/view-saved-plot-names.jsp" %>
						</div>(View your saved plot names)<br />
						<input type="button" name="save" onclick='validatePlotName("newPlotName"); return saveRatePressureChart("newPlotName", "chartMsg", "${results.id}");' value="Save"></input>    
					</div>

					<div id="chartMsg"></div>  
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
				</div>

	<% } %>	

	
		<!-- end container -->

		</c:when>
			<c:otherwise>
				<div>${message }</div>
			</c:otherwise>
		</c:choose>
		<c:if test="${not empty fileIcons}">
			<table>
				<tr><th>Files in charts</th></tr>
			<c:forEach items="${fileIcons }" var="file">
				<tr><td>${file }</td></tr>
			</c:forEach>
			</table>
		</c:if>
		</div>
		<input type="hidden" name="outputDir" id="outputDir" value="${outputDir}"/>	 					
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
