<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.util.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Study Analysis Results - Delta T Histogram</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/interactive-cosmic-plots.css" />		
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-study-deltaT-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
			<div id="content">
			<script type="text/javascript" src="../include/elab.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.errorbars.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.symbol.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.selection.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.navigate.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.crosshair.min.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.stack.js"></script>
			<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.time.js"></script>
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
			<script type="text/javascript" src="show-deltaT.js"></script>
			<script type="text/javascript">	
			function ajax() {
				  return $.ajax({
					  	type: "GET",
	          			success: onDataLoad
			      });					
			}

  			var deferred = $.Deferred();
  
			$(document).ready(function() {	
				$.when(ajax())
			     .done(function (response) {
			    	    var feedback = document.getElementById("feedback");
			     });
			    return deferred.promise();
  			}); 	
							
			</script>			
			
<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	
	String showerId = request.getParameter("showerId");
	AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
	request.setAttribute("showerResults", showerResults);
	
	String[] deltaTIDs = (String[]) showerResults.getAttribute("deltaTIDs");
	String deltaTIDsString = "t"+deltaTIDs[0] + " - t"+deltaTIDs[1];
    //EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot
	String eventDir = request.getParameter("eventDir");
	request.setAttribute("eventDir", eventDir);	
	request.setAttribute("deltaTIDs", deltaTIDsString);
%>
	<div id="feedback"></div>
	<div class="graph-container-deltaT">
		<div id="chartDeltaT" style="text-align: center; width:420px; height:460px;">
			<div id="deltaTTitle<"><strong>Delta T Histogram</strong></div>
			<div id="deltaTChart" style="width:400px; height:450px; text-align: center;"></div>
			<div id="deltaTLegend" style="width: 400px;"></div>
		</div>
	</div>	
	<div class="deltaTDetails" id="deltaTDetails"> Advanced Controls
		<span class="deltaTControls" id="deltaTControls">
		<div id="refit" style="border: 1px dotted black;">
			<br />
			<div id="xrefit" style="width:245px;">
				<table id="xrefitTable">
					<tr>
						<td nowrap><strong>Refit X Values:</strong> </td>
						<td nowrap>
							Min X: <input type="text" size="3" id="minFitX" />
							Max X: <input type="text" size="3" id="maxFitX" />
							<input type="button" value="Refit X" id="maxFitXButton" onclick='javascript:redrawPlotFitX(minFitX.value, maxFitX.value);' />
						</td>
					</tr>
				</table>
			</div>	
			<div id="mean" style="font-size: x-small;"></div>
			<div id="stddev" style="font-size: x-small;"></div>
		</div>
		<div id="scale" style="border: 1px dotted black;">
			<br />
			<div id="xaxis" style="width:245px;">
				<table id="xaxisTable">
					<tr>
						<td nowrap><strong>X-axis scale:</strong> </td>
						<td nowrap>
							Min X: <input type="text" size="3" id="minX" /><input type="button" value="Set" id="minXButton" onclick='javascript:redrawPlotX(minX.value, "min");' />
							Max X: <input type="text" size="3" id="maxX" /><input type="button" value="Set" id="maxXButton" onclick='javascript:redrawPlotX(maxX.value, "max");' />
						</td>
					</tr>
				</table>
			</div>
			<br />
			<div id="yaxis" style="width:245px;">
				<table id="yaxisTable" >
					<tr>
						<td nowrap><strong>Y-axis scale:</strong> </td>
						<td nowrap> 
							Min Y: <input type="text" size="3" id="minY" /><input type="button" value="Set" id="YMinButton" onclick='javascript:redrawPlotY(minY.value, "min");' />
							Max Y: <input type="text" size="3" id="maxY" /><input type="button" value="Set" id="YMaxButton" onclick='javascript:redrawPlotY(maxY.value, "max");' />
						</td>
					</tr>
				</table>
			</div>	
		</div>	
		<div id="binning" style="border: 1px dotted black">			
			<br />
			<div id="incdec" style="width:245px;"><strong>Bin Width</strong>
		   		<input type="number" name="binWidthDeltaT" id="binWidthDeltaT" min="0.5" style="width: 60px;"/>
			</div>
			<div class="slider" style="width:245px;">
		    	<input id="rangeDeltaT" type="range" min="0.5" style="width: 240px;"></input>
		    </div>
		 </div>
		 <div id="resetDeltaT" style="border: 1px dotted black">			
			<br />
			<input type="button" value="Reset All" id="ResetAll" onclick='javascript:resetAll();' />
		 </div>
		</span>
	</div>
	<div>
	<br />
	<% if (!user.isGuest()) { %>		
			<div style="text-align:center; width: 100%;">
				<div class="dropdown" style="text-align: left; width: 180px;">
				<input type="text" name="plotName" id="plotName" value="">

				<%@ include file="../plots/view-saved-plot-names.jsp" %>
			</div><br />(View your saved names)<br />
			<input type="button" name="save" onclick='validatePlotName("plotName"); return saveDeltaTChart("plotName", "msg", ${showerResults.id});' value="Save Chart"></input>     

			<div id="msg">&nbsp;</div>  
	<% } %>
	</div>	

</div>
			</div>
			<!-- end content -->	
			<input type="hidden" name="outputDir" id="outputDir" value="${showerResults.outputDirURL}"/>
			<e:commonMetadataToSave rawData="${showerResults.analysis.parameters['rawData']}"/>
			<e:creationDateMetadata/>
			<input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::TimeOfFlight"/>
			<input type="hidden" name="metadata" value="study string timeofflight"/>
			<input type="hidden" name="metadata" value="type string plot"/>
			<input type="hidden" name="metadata" value="detectorcoincidence int ${showerResults.analysis.parameters['detectorCoincidence']}"/>
			<input type="hidden" name="metadata" value="eventcoincidence int ${showerResults.analysis.parameters['eventCoincidence']}"/>
			<input type="hidden" name="metadata" value="eventnum int ${showerResults.analysis.parameters['eventNum']}"/>
			<input type="hidden" name="metadata" value="gate int ${showerResults.analysis.parameters['gate']}"/>
			<input type="hidden" name="metadata" value="title string ${showerResults.analysis.parameters['plot_title']}"/>
			<input type="hidden" name="metadata" value="caption string ${showerResults.analysis.parameters['plot_caption']}"/>
			<input type="hidden" name="metadata" value="deltaTIDs string Delta T: ${deltaTIDs}" />
			<!-- EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot -->
			<input type="hidden" name="eventCandidates" value="eventCandidates" />
			<input type="hidden" name="eventDir" value="${eventDir}" />
			<input type="hidden" name="eventNum" value="${showerResults.analysis.parameters['eventNum']}" />
			<input type="hidden" name="id" value="${showerResults.id}"/>
			<input type="hidden" name="rundirid" value="${results.id}"/>
			
		</div>
		<!-- end container -->
	</body>
</html>
