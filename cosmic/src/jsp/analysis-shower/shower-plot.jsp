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
<%@ page import="gov.fnal.elab.util.URLEncoder" %>
<%
  String message = request.getParameter("message");

  ElabAnalysis analysis = results.getAnalysis();
  request.setAttribute("analysis", analysis);

  String showerId = request.getParameter("showerId");
  AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
  request.setAttribute("showerResults", showerResults);

  //EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot
  String eventDir = request.getParameter("eventDir");
  request.setAttribute("eventDir", eventDir);

 //create the file for the dynamic charts
  String showerPlotJsonFile = results.getOutputDir() + "/ShowerPlotFlot";
  try {
    //this code is for admin to be able to see the graph
    File f = new File(showerPlotJsonFile);
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
        String fileName = results.getOutputDir()+"/eventFile";
        File file = new File(fileName);
        ShowerPlotDataStream lpds = new ShowerPlotDataStream(elab, file, results.getOutputDir());
    }
  } catch (Exception e) {
      message = e.getMessage();
  } 

  String subject = URLEncoder.encode(elab.getName() + " Interactive Shower Plot Feedback");
  String body = URLEncoder.encode("Thank you for your interest and help!. Please complete the fields below with your feedback:\n\n" 
    + "First Name:\n\n"
    + "Last Name:\n\n"
    + "City:\n\n"
    + "State:\n\n"
    + "School:\n\n"
    + "Your feedback about the Shower Interactive Plots:\n");
  String mailURL = "mailto:e-labs@fnal.gov?Subject=" + subject + "&Body=" + body;
  request.setAttribute("message", message);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Shower Plot</title>
    <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../css/data.css"/>
    <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
    <link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
    <link rel="stylesheet" href="../include/CanvasXpress/css/canvasXpress.css" type="text/css"/>
    <script type="text/javascript" src="../include/elab.js"></script>
  </head>
  <body class="showerPlot" style="text-align: center;">
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
        <script type="text/javascript" src="../include/CanvasXpress/js/canvasXpress.min.js"></script>
        <script type="text/javascript" src="../include/json/json.worker.js"></script>
        <script type="text/javascript" src="../include/json/json.async.js"></script>
        <script type="text/javascript" src="../include/canvas2image.js"></script>
        <script type="text/javascript" src="../include/base64.js"></script>
        <script type="text/javascript" src="shower.js"></script>
        <script type="text/javascript">
        $(document).ready(function() {
          $.ajax({
            type: "GET",
            success: onDataLoad1
          });
        });   
        </script>
        
        <div><div style="text-align: center;">
          <a href="output.jsp?showerId=${showerResults.id}&id=${results.id }">View static plot</a><br /><br />
          <div style="font-size: x-small;"><i>Send feedback to</i> <a href="<%= mailURL %>">e-labs@fnal.gov</a></div>
        </div></div>
        <c:choose>    
          <c:when test="${not empty message }">
            <div><div style="text-align: center;">${message }</div>
          </c:when>
          <c:otherwise>          
         <div id="Scatter3D">
            <div class='desc'>
              <canvas id="placeholder" width='540' height='540'></canvas>
         </div></div><br />
              <p>
                Analysis run time: ${results.formattedRunTime}; estimated: ${results.formattedEstimatedRunTime}
              </p>
              <p>
                Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
                  width="800" height="600" toolbar="true">analysis directory</e:popup>
              </p>
              <p>
                <e:rerun type="lifetime" id="${results.id}" label="Change"/> your parameters  
              </p>
          </c:otherwise>
        </c:choose> 
<% if (!user.isGuest()) { %>                
        <div style="text-align:center; width: 100%;">
          <p><b>OR</b></p>
          <p>To save this plot permanently, enter the new name you want.</p>
          <p>Then click <b>Save Plot</b>.</p>

          <div id="chartMsg"></div>  
          <e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
          <e:creationDateMetadata/>
			    <input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::ShowerStudy"/>
			    <input type="hidden" name="metadata" value="study string shower"/>
			    <input type="hidden" name="metadata" value="type string plot"/>
			    <input type="hidden" name="metadata" value="detectorcoincidence int ${showerResults.analysis.parameters['detectorCoincidence']}"/>
			    <input type="hidden" name="metadata" value="eventcoincidence int ${showerResults.analysis.parameters['eventCoincidence']}"/>
			    <input type="hidden" name="metadata" value="eventnum int ${showerResults.analysis.parameters['eventNum']}"/>
			    <input type="hidden" name="metadata" value="gate int ${showerResults.analysis.parameters['gate']}"/>
			    <input type="hidden" name="metadata" value="radius int -1"/>
			
			    <input type="hidden" name="metadata" value="title string ${showerResults.analysis.parameters['plot_title']}"/>
			    <input type="hidden" name="metadata" value="caption string ${showerResults.analysis.parameters['plot_caption']}"/>
			
			    <input type="hidden" name="srcFile" value="plot.png"/>
			    <input type="hidden" name="srcThumb" value="plot_thm.png"/>
			    <input type="hidden" name="srcSvg" value="plot.svg"/>
			    <input type="hidden" name="srcFileType" value="png"/>
			    <!-- EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot -->
			    <input type="hidden" name="eventCandidates" value="eventCandidates" />
			    <input type="hidden" name="eventDir" value="${eventDir}" />
			    <input type="hidden" name="eventNum" value="${showerResults.analysis.parameters['eventNum']}" />
			    <input type="hidden" name="id" value="${showerResults.id}"/>
			    <input type="hidden" name="rundirid" value="${results.id}"/>
          <input type="hidden" name="outputDir" id="outputDir" value="${results.outputDirURL}"/>             
			    
			    <div class="dropdown" style="text-align: left; width: 180px;">
			      <input type="text" name="name" id="newPlotName" size="20" maxlength="30" />
			      <%@ include file="../plots/view-saved-plot-names.jsp" %>
			    </div>(View your saved plot names)<br />
			
			    <input type="submit" name="submit" value="Save Plot"/>
        </div>
      </div>
<% } %>
  </div>        
  <div id="footer"></div>   
  </body>
</html>