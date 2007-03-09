<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="lifetime" scope="session" class="gov.fnal.elab.cosmic.beans.LifetimeBean" />
<%
String submit = request.getParameter("submit");
String dvName = request.getParameter("dvName");
//if a name is speficied, setup the bean from the VDC
if(dvName != null){
    ElabTransformation loadOnly = new ElabTransformation("Quarknet.Cosmic::LifetimeStudy");
    loadOnly.loadDV("Quarknet.Cosmic.Users::" + dvName);
    lifetime.mapToBean(loadOnly.getDV());
    loadOnly.close();
}
//else, set the bean through user form input
else{
    //reset the bean only if the page is called for the first time
    if(submit == null){
        lifetime.reset();

        //default values (if different from the bean):
        lifetime.setExtraFun_maxX("10");
        lifetime.setExtraFun_minX(".1");
        lifetime.setExtraFun_rawFile("extraFun_rawFile");
        lifetime.setExtraFun_type("0");
        lifetime.setFreq_binValue("40");
        lifetime.setFreq_binType("0");
        lifetime.setFreq_col("3");
        lifetime.setFrequencyOut("frequencyOut");
        lifetime.setLifetime_coincidence("1");
        lifetime.setLifetime_energyCheck("1");
        lifetime.setLifetime_gatewidth("1e-5");
        lifetime.setLifetimeOut("lifetimeOut");
        lifetime.setPlot_title("Lifetime Study");
        lifetime.setPlot_xlabel("Decay Length (microsec)");
        lifetime.setPlot_ylabel("Number of Decays");
        lifetime.setPlot_outfile_param("plot_param");
        lifetime.setPlot_outfile_image("plot_svg");
        lifetime.setPlot_plot_type("3");
        lifetime.setSort_sortKey1("2");
        lifetime.setSort_sortKey2("3");
    }
    else if(submit.equals("remove")){
        //remove files the user selected for removal
        String[] f = request.getParameterValues("remfile");
        if(f != null){
            java.util.List remfiles = null;
            remfiles = Arrays.asList(f); 

            HashSet set = new HashSet();
            set.addAll(remfiles);

            //FIXME I can't seem to get ListIterator.remove() to work (throws UnsupportedOperationException)
            java.util.List new_file_list = new ArrayList();
            for(Iterator i=lifetime.getRawData().iterator(); i.hasNext(); ){
                String s = (String)i.next();
                if(!set.contains(s)){
                    new_file_list.add(s);   //add file to new list if it's not selected for removal
                }
            }

            //set raw data as new updated list
            lifetime.setRawData(new_file_list);
        }
    }
%>

    <%-- Set every string that is *vaild* as an empty string as an empty string (initially) --%>
    <%-- Note that this must be done here because setProperty * ignores empty strings --%>
    <%-- It's an unfortunate side-effect of using jsp:setProperty * --%>
    <c:if test="${param.submit == 'Analyze'}">
        <jsp:setProperty name="lifetime" property="extraFun_alpha_guess" value="" />
        <jsp:setProperty name="lifetime" property="extraFun_constant_guess" value="" />
        <jsp:setProperty name="lifetime" property="extraFun_lifetime_guess" value="" />
        <jsp:setProperty name="lifetime" property="extraFun_maxX" value="" />
        <jsp:setProperty name="lifetime" property="extraFun_minX" value="" />
        <jsp:setProperty name="lifetime" property="plot_lowX" value="" />
        <jsp:setProperty name="lifetime" property="plot_highX" value="" />
        <jsp:setProperty name="lifetime" property="plot_highY" value="" />
        <jsp:setProperty name="lifetime" property="plot_highY" value="" />
        <jsp:setProperty name="lifetime" property="plot_title" value="" />
        <jsp:setProperty name="lifetime" property="plot_caption" value="" />
    </c:if>
    <jsp:setProperty name="lifetime" property="*" />

<%
    //filenames to analyze
    String[] f = request.getParameterValues("f");
    if(f != null){
        java.util.List rawData = new ArrayList(1);  //initial size 1
        rawData = Arrays.asList(f); 
        lifetime.setRawData(rawData);
    }

    //set threshold and wire delay data based off raw data names
    java.util.List rawData = lifetime.getRawData();
    if(rawData != null){
        java.util.List thresholdData = new ArrayList(rawData.size());
        java.util.List wireDelay= new ArrayList(rawData.size());
        String detectorIDs = "";
        for(ListIterator i=rawData.listIterator(); i.hasNext(); ){
            String s = (String)i.next();
            String detectorID = s.substring(0,s.indexOf("."));
            thresholdData.add(dataDir + detectorID + "/" + s + ".thresh");
            wireDelay.add(s+".wd");
            detectorIDs += detectorID + " ";
        }
        lifetime.setThresholdAll(thresholdData);
        lifetime.setWireDelayData(wireDelay);
        lifetime.setDetector(detectorIDs.trim());
    }
%>

    <%-- variables which the user doesn't choose here, but are needed for the TR --%>
    <%-- NOTE: jsp will simply stop outputing with no error message if you misspell or miscapitalize names in setProperty. BE CAREFUL!! --%>
    <jsp:setProperty name="lifetime" property="geoDir" value="<%=dataDir%>" />
    
<%
}   //end bean setup
%>


<%-- redirect to output page if bean is valid and user has hit "submit" --%>
<c:if test="${lifetime.valid and param.submit == 'Analyze'}">
    <jsp:forward page="lifetimeOutput.jsp">
        <jsp:param name="plot_size" value="<%=request.getParameter("plot_size")%>" />
    </jsp:forward>
</c:if>


<html>
<head>
    <title>Choose lifetime parameters</title>

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
if(!lifetime.isRawDataValid()){
%>
    <p><font color="red">Filename missing!</font><br>
    Please <a href="search.jsp?t=split&f=analyze&s=lifetime">choose</a> at least one day to analyze.</p>
<%
    return;
}
%>


<table id="instructions">
    <tr>
        <td height="26" bgcolor="#4382BB" align="left">
            <font color="000000">
                <b>
                    Calculate the lifetime of muons that stop in the detector. 
                </b>
            </font>    
        </td>
    </tr>
    <tr>
        <td height="26" bgcolor="#FFFFFF" align="center">
            <font color="000000">
                <a href="ltimetutorial.jsp" class="table">Understanding The Graph</a>
            </font>
        </td>
    </tr>
</table>

<%
//create a rawData variable before including analyzing_list
java.util.List rawDataReference = lifetime.getRawData();
java.util.List rawData = new java.util.ArrayList(rawDataReference.size());
for(Iterator i=rawDataReference.iterator(); i.hasNext(); ){
    rawData.add(new String((String)i.next()));
}
%>

<!-- form for analysys options. Put before analyzing_list since it includes form inputs -->
<form name="analysisform" 
    action="lifetime.jsp" 
    method="get" >

<%-- provides detectorIDs and validChans variables --%>
<%-- also provides rawDataString and detectorIDString vars --%>
<%@ include file="include/analyzing_list.jsp" %>

<!-- use files in other analyses -->
<font color="#d18ab1">Analyze these same files in study: 
<a href="flux.jsp?<%=filenames_str%>">flux</a>
<a href="shower.jsp?<%=filenames_str%>">shower</a>
<br>


<%-- Set default plot_caption --%>
<%
//set these only if we're not getting data from the form or a previous DV
if(submit == null && dvName == null){
    lifetime.setPlot_caption(rawDataString + "\n" + detectorIDString + "\n" + "Coincidence: 1\n");
}
%>


<P>
<TABLE BORDER=1 WIDTH=550 CELLPADDING=20 bgcolor="#F6F6FF">
    <c:if test="${!(empty lifetime.invalidKeys)}">
        <tr>
            <td>
                <c:forEach var="f" items="${lifetime.invalidKeys}">
                <font color="red">Invalid keys: </font><c:out value="${f}" /><br>
                </c:forEach>
            </td>
        </tr>
    </c:if>

<tr>
    <td colspan="1" valign="top" width="65%">
        Click <b>Analyze</b> to use the default parameters.
        Control the analysis by expanding the options below.</i> 
        <p>
        <p>
        <center>
            <table width="100%" align="center">
                <tr>
                    <td align="left"> 
                        <div id="controlap0" style="visibility:hidden; display:none">
                            <a href="javascript:void(0);" onclick="HideShow('analyzeParam0');HideShow('controlap0');HideShow('controlap1')">
                                <img src="graphics/Tright.gif" alt="" border="0"></a>
                            <strong>Analysis Controls</strong> 
                        </div>
                        <div id="controlap1" style="visibility:visible; display:">
                            <a href="javascript:void(0);" onclick="HideShow('analyzeParam0');HideShow('controlap1');HideShow('controlap0')">
                                <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            <strong>Analysis Controls</strong> 
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id='analyzeParam0' style="visibility:visible;display:">
                            <table width="100%" align="center">
                                <tr>
                                    <td width="40%" align="right">
                                        <a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_coincidence','Coincidence Level')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Coincidence level: 
                                    </td>
                                    <td>
                                        <select name="lifetime_coincidence" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nCoincidence: ' + lifetime_coincidence.value;}">
                                            <c:choose>
                                                <c:when test="${lifetime.lifetime_coincidence == 1}">
                                                    <option value="1" selected>
                                                    1
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="1">
                                                    1
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.lifetime_coincidence == 2}">
                                                    <option value="2" selected>
                                                    2
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="2">
                                                    2
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.lifetime_coincidence == 3}">
                                                    <option value="3" selected>
                                                    3
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="3">
                                                    3
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.lifetime_coincidence == 4}">
                                                    <option value="4" selected>
                                                    4
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="4">
                                                    4
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_energyCheck','Check Energy of Second Pulse')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Check energy of 2<sup>nd</sup> pulse: 
                                    </td>
                                    <td>
                                        <select name="lifetime_energyCheck">
                                            <c:choose>
                                                <c:when test="${lifetime.lifetime_energyCheck == 1}">
                                                    <option value="1" selected>
                                                    yes
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="1">
                                                    yes
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                            <c:when test="${lifetime.lifetime_energyCheck == 0}">
                                                    <option value="0" selected>
                                                    no
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="0">
                                                    no
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','lifetime_gatewidth','Gate width (seconds)')"><IMG SRC="graphics/question.gif" border="0"></a>

                                        Gate width (seconds): 

                                    </td>
                                    <td>
                                        <input type="text" name="lifetime_gatewidth" value="<%=lifetime.getLifetime_gatewidth()%>" size="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.lifetime_gatewidthValid}">
                                            <font size="-1" color="red">Must be an integer or number of the form (1e-5)</font>
                                        </c:if>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id="controlpp0" style="visibility:hidden; display:none">
                            </c:when>
                            <c:otherwise>
                                <div id="controlpp0" style="visibility:visible; display:">
                            </c:otherwise>
                        </c:choose>
                            <a href="javascript:void(0);" onclick="HideShow('plotParam0');HideShow('controlpp0');HideShow('controlpp1')">
                                <img src="graphics/Tright.gif" alt="" border="0"></a>
                            <strong>Plot Controls</strong> 
                            <br>
                        </div>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id="controlpp1" style="visibility:visible; display:">
                            </c:when>
                            <c:otherwise>
                                <div id="controlpp1" style="visibility:hidden; display:none">
                            </c:otherwise>
                        </c:choose>
                            <a href="javascript:void(0);" onclick="HideShow('plotParam0');HideShow('controlpp1');HideShow('controlpp0')">
                                <img src="graphics/Tdown.gif" alt="" border="0"></a>
                            <strong>Plot Controls</strong> 
                            <br>
                        </div>
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
                                    <td align="right" width="40%">
                                        <a href="javascript: describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','freq_binValue','Number of Bins')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Number of Bins: 

                                    </td>
                                    <td>
                                        <input type="text" name="freq_binValue" value="<%=lifetime.getFreq_binValue() %>" size="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.freq_binValueValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" width="40%">
                                        <a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowX" value="<%=lifetime.getPlot_lowX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.plot_lowXValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highX" value="<%=lifetime.getPlot_highX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.plot_highXValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowY','Y-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowY" value="<%=lifetime.getPlot_lowY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.plot_lowYValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highY" value="<%=lifetime.getPlot_highY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.plot_highYValid}">
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
                                        <input type="text" name="plot_title" value="<%=lifetime.getPlot_title()%>" size="40" maxlength="100">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">

                                        Figure caption: 

                                    </td>
                                    <td>
                                        <textarea name="plot_caption" rows="5" cols="30"><%=lifetime.getPlot_caption().replaceAll("\\\\n", "\n") %></textarea>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id="controlfp0" style="visibility:hidden; display:none">
                            </c:when>
                            <c:otherwise>
                                <div id="controlfp0" style="visibility:visible; display:">
                            </c:otherwise>
                        </c:choose>
                            <a href="javascript:void(0);" onclick="HideShow('fitParam0');HideShow('controlfp0');HideShow('controlfp1')">
                                <img src="graphics/Tright.gif" alt="" border="0"></a>

                            <strong>Fit Controls</strong>
                            <br>
                        </div>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id="controlfp1" style="visibility:visible; display:">
                            </c:when>
                            <c:otherwise>
                                <div id="controlfp1" style="visibility:hidden; display:none">
                            </c:otherwise>
                        </c:choose>
                            <a href="javascript:void(0);" onclick="HideShow('fitParam0');HideShow('controlfp1');HideShow('controlfp0')">
                                <img src="graphics/Tdown.gif" alt="" border="0">
                            </a>
                            <strong>Fit Controls</strong>
                            <br>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <c:choose>
                            <c:when test="${param.submit == 'Change'}">
                                <div id='fitParam0' style="visibility:visible; display:">
                            </c:when>
                            <c:otherwise>
                                <div id='fitParam0' style="visibility:hidden; display:none;">
                            </c:otherwise>
                        </c:choose>
                            <table width="100%" align="center"> 
                                <tr>
                                    <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_turnedOn','Fitting Turned On')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Fitting Turned On:
                                    </td>
                                    <td>
                                        <select name="extraFun_turnedOn">
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_turnedOn == 1}">
                                                    <option value="1" selected>
                                                    yes
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="1">
                                                    yes
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_turnedOn == 0}">
                                                    <option value="0" selected>
                                                    no
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="0">
                                                    no
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_minX','X-min of fit')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-min of fit: 
                                    </td>
                                    <td>
                                        <input type="text" name="extraFun_minX" value="<%=lifetime.getExtraFun_minX()%>" size="8" maxlength="10">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.extraFun_minXValid}">
                                            <font size="-1" color="red">Must be a decimal number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_maxX','X-max of fit')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-max of fit: 
                                    </td>
                                    <td>
                                        <input type="text" name="extraFun_maxX" value="<%=lifetime.getExtraFun_maxX()%>" size="8" maxlength="10">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.extraFun_maxXValid}">
                                            <font size="-1" color="red">Must be a decimal number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_alpha_variate','Fit Y-intercept')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Fit Y-intercept:
                                        <select name="extraFun_alpha_variate">
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_alpha_variate == 'yes'}">
                                                    <option value="yes" selected>
                                                    yes
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="yes">
                                                    yes
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_alpha_variate == 'no'}">
                                                    <option value="no" selected>
                                                    no
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="no">
                                                    no
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                    <td>
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_alpha_guess','Alpha')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Alpha: 
                                        <input type="text" name="extraFun_alpha_guess" value="<%=lifetime.getExtraFun_alpha_guess()%>" size="8" maxlength="">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.extraFun_alpha_guessValid}">
                                            <font size="-1" color="red">Must be a decimal number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_lifetime_variate','Fit Lifetime')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Fit Lifetime:
                                        <select name="extraFun_lifetime_variate">
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_lifetime_variate == 'yes'}">
                                                    <option value="yes" selected>
                                                    yes
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="yes">
                                                    yes
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_alpha_variate == 'no'}">
                                                    <option value="no" selected>
                                                    no
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="no">
                                                    no
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                    <td>
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_lifetime_guess','Lifetime')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Lifetime: 
                                        <input type="text" name="extraFun_lifetime_guess" value="<%=lifetime.getExtraFun_lifetime_guess()%>" size="8" maxlength="">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.extraFun_lifetime_guessValid}">
                                            <font size="-1" color="red">Must be a decimal number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_constant_variate','Fit Background')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Fit Background:
                                        <select name="extraFun_constant_variate">
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_constant_variate == 'yes'}">
                                                    <option value="yes" selected>
                                                    yes
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="yes">
                                                    yes
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:choose>
                                                <c:when test="${lifetime.extraFun_constant_variate == 'no'}">
                                                    <option value="no" selected>
                                                    no
                                                    </option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="no">
                                                    no
                                                    </option>
                                                </c:otherwise>
                                            </c:choose>
                                        </select>
                                    </td>
                                    <td>
                                        <a href="javascript:describe('Quarknet.Cosmic::LifeTimeStudyNoThresh','extraFun_constant_guess','Background')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Background: 
                                        <input type="text" name="extraFun_constant_guess" value="<%=lifetime.getExtraFun_constant_guess()%>" size="8" maxlength="">
                                        <c:if test="${param.submit == 'Analyze' and !lifetime.extraFun_constant_guessValid}">
                                            <font size="-1" color="red">Must be a decimal number</font>
                                        </c:if>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
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
