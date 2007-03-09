<%@ page import="java.util.*" %>
<%@ page import="java.io.File" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ include file="common.jsp" %>
<%@ include file="dhtmlutil.jsp" %>
<%@ include file="elabutil.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:useBean id="flux" scope="session" class="gov.fnal.elab.cosmic.beans.FluxBean" />

<%
String submit = request.getParameter("submit");
String dvName = request.getParameter("dvName");
//if a name is speficied, setup the bean from the VDC
if(dvName != null){
    ElabTransformation loadOnly = new ElabTransformation("Quarknet.Cosmic::FluxStudy");
    loadOnly.loadDV("Quarknet.Cosmic.Users::" + dvName);
    flux.mapToBean(loadOnly.getDV());
    loadOnly.close();
}
//else, set the bean through user form input
else{
    //reset the bean only if the page is called for the first time
    if(submit == null){
        flux.reset();

        //default values (if different from the bean):
        flux.setPlot_title("Flux Study");
        flux.setPlot_xlabel("Time GMT (hours)");
        flux.setPlot_ylabel("Flux (events/m^2/60-seconds)");
        flux.setFlux_binWidth("600");
        flux.setPlot_plot_type("1");
        flux.setFluxOut("fluxOut");
        flux.setExtraFun_out("extraFun_out");
        flux.setPlot_outfile_param("plot_outfile_param");
        flux.setPlot_outfile_image("plot_svg");
        flux.setPlot_plot_type("1");
        flux.setSort_sortKey1("2");
        flux.setSort_sortKey2("3");
        flux.setSinglechannelOut("singleChannelOut");
        flux.setSinglechannel_channel("1");

    }
    else if(submit.equals("remove")){
        //remove files the user selected for removal
        String[] f = request.getParameterValues("remfile");
        if(f != null){
			flux.setRawData(removeAll(flux.getRawData(), f));
        }
    }
%>

    <%-- Set every string that is *vaild* as an empty string as an empty string --%>
    <%-- Note that this must be done here because setProperty * ignores empty strings --%>
    <%-- It's an unfortunate side-effect of using jsp:setProperty * --%>
    <c:if test="${param.submit == 'Analyze'}">
        <jsp:setProperty name="flux" property="plot_lowY" value="" />
        <jsp:setProperty name="flux" property="plot_highY" value="" />
        <jsp:setProperty name="flux" property="plot_title" value="" />
        <jsp:setProperty name="flux" property="plot_caption" value="" />
    </c:if>
    <jsp:setProperty name="flux" property="*" />

<%
    //set raw data from search form
    String[] f = request.getParameterValues("f");
    if(f != null){
        java.util.List rawData = new ArrayList(1);  //initial size 1
        rawData = Arrays.asList(f); 
        flux.setRawData(rawData);
    }

    //set threshold and wire delay data based off raw data names
    java.util.List rawData = flux.getRawData();
    if(rawData != null){
        java.util.List thresholdData = new ArrayList(rawData.size());
        java.util.List wireDelay= new ArrayList(rawData.size());
        java.util.List geoFiles = new ArrayList(rawData.size());
        String detectorIDs = "";
        for(ListIterator i=rawData.listIterator(); i.hasNext(); ){
            String s = (String)i.next();
            String detectorID = s.substring(0,s.indexOf("."));
            thresholdData.add(new File(new File(dataDir, detectorID), s + ".thresh").getAbsolutePath());
            wireDelay.add(s + ".wd");
            detectorIDs += detectorID + " ";
            geoFiles.add(new File(new File(dataDir, detectorID), detectorID + ".geo").getAbsolutePath());
        }
        flux.setThresholdAll(thresholdData);
        flux.setWireDelayData(wireDelay);
        flux.setDetector(detectorIDs.trim());
		flux.setFlux_geoDir(dataDir);
        flux.setFlux_geoFiles(geoFiles);
    }
}   //end bean setup
%>


<%-- redirect to output page if bean is valid and user has hit "submit" --%>
<c:if test="${flux.valid and param.submit == 'Analyze'}">
    <jsp:forward page="fluxOutput.jsp">
        <jsp:param name="plot_size" value="<%=request.getParameter("plot_size")%>" />
    </jsp:forward>
</c:if>


<html>
<head>
    <title>Choose flux parameters</title>

    <!-- include css style file -->
    <%@ include file="include/style.css" %>
    <%@ include file="include/javascript.jsp" %>
    <!-- header/navigation -->
    <%
    //be sure to set this before including the navbar
    String headerType = "Data";
    %>
    <%@ include file="include/navbar_common.jsp" %>
    <%-- navbar_common closes the <head> tag --%>

<%
if(!flux.isRawDataValid()){
%>
    <p><font color="red">Filename missing!</font><br>
    Please <a href="search.jsp?t=split&f=analyze&s=flux">choose</a> at least one day to analyze.</p>
<%
    return;
}
%>


<table id="instructions">
    <tr>
        <td height="26" bgcolor="#4382BB" align="left">
            <font color="000000">
                <b>
                    Calculate the flux for your data file. Remember, flux = particles / time / area
                </b>
            </font>
        </td>
    </tr>
    <tr>
        <td height="26" bgcolor="#FFFFFF" align="center">
            <font color="000000">
                <a href="fluxtutorial.jsp" class="table">Understand The Graph</a>
            </font>
        </td>
    </tr>
</table>

<%
//create a rawData variable before including analyzing_list
java.util.List rawDataReference = flux.getRawData();
java.util.List rawData = new java.util.ArrayList(rawDataReference);
%>

<!-- form for analysys options. Put before analyzing_list since it includes form inputs -->
<form name="analysisform" 
    action="flux.jsp" 
    method="get" >

<%-- provides detectorIDs and validChans variables --%>
<%-- also provides rawDataString and detectorIDString vars --%>
<%@ include file="include/analyzing_list.jsp" %>

<!-- use files in other analyses -->
<font color="#d18ab1">Analyze these same files in study: 
<a href="lifetime.jsp?<%=filenames_str%>">lifetime</a>
<a href="shower.jsp?<%=filenames_str%>">shower</a>
<br>


<%-- Set default plot_caption and singlechannel_channel --%>
<%
//set these only if we're not getting data from the form or a previous DV; we also need to reset the lowx and highx if files are removed
if((submit == null && dvName == null) || (submit != null && submit.equals("remove"))){
    int chan=0;
    if (validChans[3] ){flux.setSinglechannel_channel("4");}
    if (validChans[2] ){flux.setSinglechannel_channel("3");}
    if (validChans[1] ){flux.setSinglechannel_channel("2");}
    if (validChans[0] ){flux.setSinglechannel_channel("1");}
    flux.setPlot_caption(rawDataString + "\n" + detectorIDString + "\nChannel: " + flux.getSinglechannel_channel());
    String start = new String();
    String end = new String();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MM/dd/yyyy H:mm");
    start = sdf.format(startdate);
    end = sdf.format(enddate);
    flux.setPlot_lowX(start);
    flux.setPlot_highX(end);
}
%>


<P>
<TABLE BORDER=1 WIDTH=550 CELLPADDING=20 bgcolor="#F6F6FF">
    <c:if test="${!(empty flux.invalidKeys)}">
        <tr>
            <td>
                <c:forEach var="f" items="${flux.invalidKeys}">
                <font color="red">Invalid keys: </font><c:out value="${f}" /><br>
                </c:forEach>
            </td>
        </tr>
    </c:if>

    <tr>
        <td colspan="1" valign="top" width="65%">
            Click 
            <b>
                Analyze 
            </b>
            to use the default parameters. 
            Control the analysis by expanding the options below.</i> 
        <p>
        <p>
        <center>
            <table width="100%" align="center">
                <tr>
                    <td align="left"> 
                    	<% visibilitySwitcher(out, "controlap", "analyzeParam0", "Analysis Controls", true); %>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id='analyzeParam0' style="visibility:visible;display:">
                            <table width="100%" align="center">
                                <tr>
                                    <td align="right" width="40%" valign="bottom"><a href="javascript: describe('Quarknet.Cosmic::SingleChannel','channel','Channel Number')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Channel Number:
                                    </td>
                                    <td>
                                        <select name="singlechannel_channel" onChange="plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nChannel: ' + singlechannel_channel.value;">
                                            <c:choose>
                                                <c:when test="${flux.singlechannel_channel == 1}">
                                                    <option value="1" selected>
                                                    1
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <%
                                                    if(validChans[0]){
                                                    %>
                                                        <option value="1">
                                                        1
                                                        </option>
                                                    <%
                                                    }
                                                    %>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${flux.singlechannel_channel == 2}">
                                                    <option value="2" selected>
                                                    2
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <%
                                                    if(validChans[1]){
                                                    %>
                                                        <option value="2">
                                                        2
                                                        </option>
                                                    <%
                                                    }
                                                    %>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${flux.singlechannel_channel == 3}">
                                                    <option value="3" selected>
                                                    3
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <%
                                                    if(validChans[2]){
                                                    %>
                                                        <option value="3">
                                                        3
                                                        </option>
                                                    <%
                                                    }
                                                    %>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${flux.singlechannel_channel == 4}">
                                                    <option value="4" selected>
                                                    4
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <%
                                                    if(validChans[3]){
                                                    %>
                                                        <option value="4">
                                                        4
                                                        </option>
                                                    <%
                                                    }
                                                    %>
                                                </c:otherwise>
                                            </c:choose>
                                        </select> 
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                    	<% visibilitySwitcher(out, "controlpp", "plotParam0", "Plot Controls", "Change".equals(submit)); %>
                    </td>
                </tr>
                <tr>
                    <td>
                        <p>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id='plotParam0' style="visibility:visible; display:">
                            </c:when>
                            <c:otherwise>
                                <div id='plotParam0' style="visibility:hidden; display:none;">
                            </c:otherwise>
                        </c:choose>
                            <table width="100%" align="center">
                                <tr>
                                    <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::FluxStudyNoThresh','flux_binWidth','Bin Width')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Bin Width (seconds):
                                    </td>
                                    <td>
                                        <input type="text" name="flux_binWidth" value="<%=flux.getFlux_binWidth()%>" size="8" onChange="{plot_ylabel.value='Flux (events/m^2/' + flux_binWidth.value + ') seconds';}" >
                                        <c:if test="${param.submit == 'Analyze' and !flux.flux_binWidthValid}">
                                            <font size="-1" color="red">Use either a positive number or an expression (e.g. 60*60)</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowX" value="<%=flux.getPlot_lowX() %>" size="19" maxlength="19">
                                        <c:choose>
                                            <c:when test="${param.submit == 'Analyze' and !flux.plot_lowXValid}">
                                                <font size="-1" color="red">Use format: mm/dd/yyyy hh:mm</font>
                                            </c:when>
                                            <c:otherwise>
                                                <font size=-1>e.g. 10/28/2004 3:00</font>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highX" value="<%=flux.getPlot_highX() %>" size="19" maxlength="19">
                                        <c:choose>
                                            <c:when test="${param.submit == 'Analyze' and !flux.plot_highXValid}">
                                                <font size="-1" color="red">Use format: mm/dd/yyyy hh:mm</font>
                                            </c:when>
                                            <c:otherwise>
                                                <font size=-1>e.g. 10/29/2004 18:00</font>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowY','Y-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowY" value="<%=flux.getPlot_lowY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !flux.plot_lowYValid}">
                                        <font size="-1" color="red">Must be an integer</font>
                                        </c:if>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highY" value="<%=flux.getPlot_highY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !flux.plot_highYValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" width="40%">
                                        Plot Size: 
                                    </td>
                                    <td>
                                        <select name="plot_size">
                                            <c:choose>
                                                <c:when test="${param.plot_size == 300}">
                                                    <option value="300" selected>
                                                    Small
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="300">
                                                    Small
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${param.plot_size == 600 || empty param.plot_size}">
                                                    <option value="600" selected>
                                                    Medium
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="600">
                                                    Medium
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${param.plot_size == 800}">
                                                    <option value="800" selected>
                                                    Large
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="800">
                                                    Large
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">

                                        Plot Title: 

                                    </td>
                                    <td>
                                        <input type="text" name="plot_title" value="<%=flux.getPlot_title()%>" size="40" maxlength="100">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">

                                        Figure caption: 

                                    </td>
                                    <td>
                                        <textarea name="plot_caption" rows="5" cols="30"><%=flux.getPlot_caption().replaceAll("\\\\n", "\n") %></textarea>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <jsp:include page="workflowControls.jsp"/>
            </table>
        </center>

            <div align="center">
                <input name="submit" type="submit" value="Analyze">
            </div>
        </td>
    </tr>
</table>
<!-- end of analysis options form -->
</form>

</body>
</html>
