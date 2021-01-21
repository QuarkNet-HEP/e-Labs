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
  //create the file for the dynamic charts
  String lifetimePlotJsonFile = results.getOutputDir() + "/LifetimePlotFlot";
  File[] pfns = null;
  String[] filenames = null;
  try {
    //this code is for admin to be able to see the graph
    File f = new File(lifetimePlotJsonFile);
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

        String fileName = results.getOutputDir()+"/lifetimeOut";
        File file = new File(fileName);
        String binValue = results.getAnalysis().getParameter("freq_binValue").toString();
        Double bV = Double.valueOf(binValue);
        String binType = results.getAnalysis().getParameter("freq_binType").toString();
        String freqCol = results.getAnalysis().getParameter("freq_col").toString();
        if (bV <= 0) {
          message = "Please enter a positive number for the bin width.";
        } else {
          LifetimePlotDataStream lpds = new LifetimePlotDataStream(elab, file, bV, binType, freqCol, results.getOutputDir());
        }
    }
  } catch (Exception e) {
      message = e.getMessage();
  } 

  String subject = URLEncoder.encode(elab.getName() + " Interactive Lifetime Plot Feedback");
  String body = URLEncoder.encode("Thank you for your interest and help!. Please complete the fields below with your feedback:\n\n" 
    + "First Name:\n\n"
    + "Last Name:\n\n"
    + "City:\n\n"
    + "State:\n\n"
    + "School:\n\n"
    + "Your feedback about the Lifetime Interactive Plots:\n");
  String mailURL = "mailto:e-labs@fnal.gov?Subject=" + subject + "&Body=" + body;
  request.setAttribute("message", message);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Lifetime Plot</title>
    <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../css/data.css"/>
    <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
    <link rel="stylesheet" type="text/css" href="../css/cosmic-plots.css" />
    <script type="text/javascript" src="../include/elab.js"></script>
  </head>
  <body class="lifetimePlot" style="text-align: center;">
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
        <script type="text/javascript" src="../include/jquery/flot083/d3.v3.min.js"></script>
        <script type="text/javascript" src="../include/jquery/flot083/excanvas.js"></script>
        <script type="text/javascript" src="../include/jquery/flot083/excanvas.min.js"></script>
        <script type="text/javascript" src="../include/jquery/flot083/excanvas.compiled.js"></script>
        <script type="text/javascript" src="../include/json/json.worker.js"></script>
        <script type="text/javascript" src="../include/json/json.async.js"></script>
        <script type="text/javascript" src="../include/canvas2image.js"></script>
        <script type="text/javascript" src="../include/base64.js"></script>
        <script type="text/javascript" src="../analysis/analysis-plot.js"></script>
        <script type="text/javascript" src="lifetime.js"></script>
        <script type="text/javascript">
        $(document).ready(function() {
          $.ajax({
            type: "GET",
            success: onDataLoad1
          });
        });   
        </script>
        
        <div><div style="text-align: center;">
          <a href="output.jsp?id=${results.id }">View static plot</a><br /><br />
          <div style="font-size: x-small;"><i>Send feedback to</i> <a href="<%= mailURL %>">e-labs@fnal.gov</a></div>
        </div></div>
        <c:choose>    
          <c:when test="${not empty message }">
            <div><div style="text-align: center;">${message }</div>
          </c:when>
          <c:otherwise>             
            <div class="graph-container" id="spinner" style="height: 600px;">
              <div id="placeholder" class="graph-placeholder" style="float:left; width:650px; height:550px;"></div>
              <div id="overview" class="graph-placeholder" style="float:right;width:160px; height:150px;"></div>
              <div id="interactive" style="float:right;width:160px; height:325px;">
                <p><label><input id="enableTooltip" type="checkbox" checked="checked"></input>Enable tooltip</label></p>
                <p>
                  <label><input id="enablePosition" type="checkbox" checked="checked"></input>Show mouse position:</label>
                </p>
                  <br /><span id="hoverdata" class="hoverdata"></span>
                  <br /><span id="clickdata" class="clickdata"></span>
                </p>        
                <p><div id="zoomoutbutton" style="float:left; width:80px; height:30px;"> </div>
                   <div id="resetbutton" style="float:right; width:80px; height:30px;"> </div></p>
                <p><div id="arrows" style="float:right; width:160px; height:100px;"><div id="arrowcontainer" style="position:relative;"></div></div></p>
                <p class="message"></p>
                <p class="click"></p>
              </div>
              <div id="placeholderLegend" class="legend-placeholder"></div>
            </div>
            <div style="text-align: center;">
              <div id="incdec">Number of Bins
                  <input type="number" name="binWidth" id="binWidth" step="1" min="10" style="width: 60px;"/>
              </div>
              <div class="slider">
                  <input id="range" type="range" step="1" min="10" style="width: 650px;"></input>
              </div>  
              <!--            
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
               -->
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
            </div>
          </c:otherwise>
        </c:choose> 
<% if (!user.isGuest()) { %>                
        <div style="text-align:center; width: 100%;">
          <p><b>OR</b></p>
          <p>To save this plot permanently, enter the new name you want.</p>
          <p>Then click <b>Save Plot</b>.</p>

          <div class="dropdown" style="text-align: left; width: 180px;">
            <input type="text" name="name" id="newPlotName" value="" size="20" maxlength="30"/>
            <%@ include file="../plots/view-saved-plot-names.jsp" %>
          </div>(View your saved plot names)<br />
          <input type="button" name="save" onclick='return validatePlotName("newPlotName"); return saveChart(onOffPlot, "name", "chartMsg", "${results.id}");' value="Save"></input>    

          <div id="chartMsg"></div>  
          <e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
          <e:creationDateMetadata/>
          <input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::LifetimeStudy"/>
          <input type="hidden" name="metadata" value="study string lifetime"/>
          <input type="hidden" name="metadata" value="type string plot"/>
          <input type="hidden" name="metadata" value="bins int ${results.analysis.parameters['freq_binValue']}"/>
          <input type="hidden" name="metadata" value="title string ${results.analysis.parameters['plot_title']}"/>
          <input type="hidden" name="metadata" value="caption string ${results.analysis.parameters['plot_caption']}"/>
          <input type="hidden" name="srcFile" value="plot.png"/>
          <input type="hidden" name="srcThumb" value="plot_thm.png"/>
          <input type="hidden" name="srcSvg" value="plot.svg"/>
          <input type="hidden" name="srcFileType" value="png"/>
          <input type="hidden" name="id" value="${results.id}"/>
          <input type="hidden" name="outputDir" id="outputDir" value="${results.outputDirURL}"/>             
        </div>
      </div>
<% } %>
  </div>        
  <div id="footer"></div>   
  </body>
</html>