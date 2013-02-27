<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
        <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                <title>Shower Study - Save All Events</title>
                <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
                <link rel="stylesheet" type="text/css" href="../css/data.css"/>
                <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
                <script type="text/javascript" src="../include/elab.js"></script>
        </head>

        <body id="shower-study-save-all" class="data, analysis-output">
                <p>Saving all events... hold on...</p>
<%
String showerId  = request.getParameter("showerId");
request.setAttribute("id", showerId);
int resultsId = Integer.parseInt(request.getParameter("resultsId"));
File ecFile = new File((String) request.getParameter("eventCandidates"));
int csc = Integer.parseInt(request.getParameter("csc"));
int dir = Integer.parseInt(request.getParameter("dir"));
int eventStart = Integer.parseInt(request.getParameter("eventStart"));
String eventNum = request.getParameter("eventNum");
EventCandidates ec = EventCandidates.read(ecFile, csc, dir, eventStart, eventNum);
Collection rows = ec.getRows();
request.setAttribute("rows", rows);

request.setAttribute("showerId", showerId);
request.setAttribute("resultsId", resultsId);
AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
request.setAttribute("showerResults", showerResults);
Iterator<EventCandidates.Row> it = rows.iterator();
ElabAnalysis shower = results.getAnalysis();
while (it.hasNext())
{
        eventNum = Integer.toString(it.next().getEventNum());
        ecFile = new File(results.getOutputDir(), (String) shower.getParameter("eventCandidates"));
        String ecPath = ecFile.getAbsolutePath();
        %>
        <p>${ecPath}</p>
        <e:analysis name="analysis" type="I2U2.Cosmic::EventPlot">
            <e:trdefault name="eventNum" value="<%= eventNum %>"/>
            <e:trdefault name="eventCandidates" value="<%= ecPath %>"/>
            <e:trdefault name="geoDir" value="${shower.parameters.geoDir}"/>
            <e:trdefault name="geoFiles" value="${shower.parameters.geoFiles}"/>
            <e:trdefault name="extraFun_out" value="${shower.parameters.extraFun_out}"/>
            <e:trdefault name="plot_caption" value="${shower.parameters.plot_caption}"/>
            <e:trdefault name="plot_title" value="${shower.parameters.plot_title}"/>
            <e:trdefault name="plot_highX" value="${shower.parameters.plot_highX}"/>
            <e:trdefault name="plot_highY" value="${shower.parameters.plot_highY}"/>
            <e:trdefault name="plot_highZ" value="${shower.parameters.plot_highZ}"/>
            <e:trdefault name="plot_lowX" value="${shower.parameters.plot_lowX}"/>
            <e:trdefault name="plot_lowY" value="${shower.parameters.plot_lowY}"/>
            <e:trdefault name="plot_lowZ" value="${shower.parameters.plot_lowZ}"/>
            <e:trdefault name="plot_size" value="${shower.parameters.plot_size}"/>
            <e:trdefault name="plot_thumbnail_height" value="${shower.parameters.plot_thumbnail_height}"/>
            <e:trdefault name="plot_outfile_image_thumbnail" value="${shower.parameters.plot_outfile_image_thumbnail}"/>
            <e:trdefault name="plot_outfile_image" value="${shower.parameters.plot_outfile_image}"/>
            <e:trdefault name="plot_outfile_param" value="${shower.parameters.plot_outfile_param}"/>
            <e:trdefault name="plot_xlabel" value="${shower.parameters.plot_xlabel}"/>
            <e:trdefault name="plot_ylabel" value="${shower.parameters.plot_ylabel}"/>
            <e:trdefault name="plot_zlabel" value="${shower.parameters.plot_zlabel}"/>
            <e:trdefault name="plot_plot_type" value="${shower.parameters.plot_plot_type}"/>
            <e:trdefault name="zeroZeroZeroID" value="${shower.parameters.zeroZeroZeroID}"/>
        </e:analysis>

        <%

        %>
        <p><%=eventNum%></p>

<%
}
%>
</body>
</html>