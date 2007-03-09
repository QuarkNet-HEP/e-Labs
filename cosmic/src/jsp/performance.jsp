<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="performance" scope="session" class="gov.fnal.elab.cosmic.beans.PerformanceBean" />

<%
String submit = request.getParameter("submit");
String dvName = request.getParameter("dvName");
//if a name is specified, setup the bean from the VDC
if(dvName != null){
    ElabTransformation loadOnly = new ElabTransformation("Quarknet.Cosmic::PerformanceStudy");
    loadOnly.loadDV("Quarknet.Cosmic.Users::" + dvName);
    performance.mapToBean(loadOnly.getDV());
    loadOnly.close();
}
//else, set the bean through user form input
else{
    //reset the bean only if the page is called for the first time
    if(submit == null){
        performance.reset();

        //default values (if different from the bean):
        performance.setPlot_title("Performance Study");
        performance.setPlot_outfile_param("plot_param");
        performance.setPlot_outfile_image("plot_svg");
        performance.setPlot_plot_type("7");
        performance.setPlot_xlabel("Time over Threshold (nanosec)");
        performance.setPlot_ylabel("Number of muons");
        performance.setFreq_binValue("60");
        performance.setPlot_plot_type("7");
        performance.setFreq_binType("0");
        performance.setFreq_binValue("60");
        performance.setFreq_col("5");
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
            for(Iterator i=performance.getRawData().iterator(); i.hasNext(); ){
                String s = (String)i.next();
                if(!set.contains(s)){
                    new_file_list.add(s);   //add file to new list if it's not selected for removal
                }
            }

            //set raw data as new updated list
            performance.setRawData(new_file_list);
        }
    }
%>

    <%-- Set every string that is *valid* as an empty string as an empty string --%>
    <%-- Note that this must be done here because setProperty * ignores empty strings --%>
    <%-- It's an unfortunate side-effect of using jsp:setProperty * --%>
    <c:if test="${param.submit == 'Analyze'}">
        <jsp:setProperty name="performance" property="plot_lowX" value="" />
        <jsp:setProperty name="performance" property="plot_lowY" value="" />
        <jsp:setProperty name="performance" property="plot_highX" value="" />
        <jsp:setProperty name="performance" property="plot_highY" value="" />
        <jsp:setProperty name="performance" property="plot_title" value="" />
        <jsp:setProperty name="performance" property="plot_caption" value="" />
    </c:if>
    <jsp:setProperty name="performance" property="*" />

<%
    //filenames to analyze
    String[] f = request.getParameterValues("f");
    if(f != null){
        java.util.List rawData = new ArrayList(1);  //initial size 1
        rawData = Arrays.asList(f); 
        performance.setRawData(rawData);
    }

    //set threshold data based off raw data names
    java.util.List rawData = performance.getRawData();
    if(rawData != null){
        java.util.List thresholdData = new ArrayList(rawData.size());
        String detectorIDs = "";
        for(ListIterator i=rawData.listIterator(); i.hasNext(); ){
            String s = (String)i.next();
            String detectorID = s.substring(0,s.indexOf("."));
            detectorIDs += detectorID + " ";
            thresholdData.add(s + ".thresh");
        }
        performance.setThresholdAll(thresholdData);
        performance.setDetector(detectorIDs.trim());
    }
%>

    <%-- variables which the user doesn't choose here, but are needed for the TR --%>
    <%-- NOTE: jsp will simply stop outputing with no error message if you misspell or miscapitalize names in setProperty. BE CAREFUL!! --%>

    <%-- none --%>
    
<%
}   //end bean setup
%>


<%-- redirect to output page if bean is valid and user has hit "submit" --%>
<c:if test="${performance.valid and param.submit == 'Analyze'}">
    <jsp:forward page="performanceOutput.jsp">
        <jsp:param name="plot_size" value="<%=request.getParameter("plot_size")%>" />
    </jsp:forward>
</c:if>


<html>
<head>
    <title>Choose performance parameters</title>

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
if(!performance.isRawDataValid()){
%>
    <p><font color="red">Filename missing!</font><br>
    Please <a href="search.jsp?t=split&f=analyze&s=performance">choose</a> at least one day to analyze.</p>
<%
    return;
}
%>


<table id="instructions">
    <tr>
        <td height="26" bgcolor="#4382BB" align="left">
            <font color="000000">
                <b>
                    Do you trust the detector? Analyze its performance before you use the data for other studies.
                </b>
            </font>
        </td>
    </tr>
    <tr>
        <td height="26" bgcolor="#FFFFFF" align="center">
            <font color="000000">
                <a href="dpstutorial.jsp" class="table">Understand The Graph</a>
            </font>
        </td>
    </tr>
</table>

<%
//create a rawData variable before including analyzing_list
java.util.List rawDataReference = performance.getRawData();
java.util.List rawData = new java.util.ArrayList(rawDataReference.size());
for(Iterator i=rawDataReference.iterator(); i.hasNext(); ){
    rawData.add(new String((String)i.next()));
}
%>

<!-- form for analysys options. Put before analyzing_list since it includes form inputs -->
<form name="analysisform" 
    action="performance.jsp" 
    method="get" >

<%-- provides detectorIDs and validChans variables --%>
<%-- also provides rawDataString and detectorIDString vars --%>
<%@ include file="include/analyzing_list.jsp" %>


<%-- Set default plot_caption and singlechannel_channel --%>
<%
//set these only if we're not getting data from the form or a previous DV
if(submit == null && dvName == null){
    int chan=0;
    String singleChannels = "";
    String singleChannelOuts = "";
    String freqOuts = "";
    if (validChans[0]){
        singleChannels += "1 ";
        singleChannelOuts += "singleOut1 ";
        freqOuts += "freqOut1 ";
    }
    if (validChans[1]){
        singleChannels += "2 ";
        singleChannelOuts += "singleOut2 ";
        freqOuts += "freqOut2 ";
    }
    if (validChans[2]){
        singleChannels += "3 ";
        singleChannelOuts += "singleOut3 ";
        freqOuts += "freqOut3 ";
    }
    if (validChans[3]){
        singleChannels += "4 ";
        singleChannelOuts += "singleOut4 ";
        freqOuts += "freqOut4 ";
    }
    performance.setSinglechannel_channel(singleChannels.trim());
    performance.setSinglechannelOut(singleChannelOuts.trim());
    performance.setFreqOut(freqOuts.trim());
    
    String[] channelList = (performance.getSinglechannel_channel()).split(" ");
    performance.setPlot_caption(rawDataString + "\n" + detectorIDString);
}
%>


<P>
<TABLE BORDER=1 WIDTH=550 CELLPADDING=20 bgcolor="#F6F6FF">
    <c:if test="${!(empty performance.invalidKeys)}">
        <tr>
            <td>
                <c:forEach var="f" items="${performance.invalidKeys}">
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
                                    <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::PerformanceStudyNoThresh','freq_binValue','Bin Width')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Number of Bins:
                                    </td>
                                    <td>
                                        <input type="text" name="freq_binValue" value="<%=performance.getFreq_binValue()%>" size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nChannel: ' + singlechannel_channel.value;}">
                                        <c:if test="${param.submit == 'Analyze' and !performance.freq_binValueValid}">
                                            <font size="-1" color="red">Use either a positive number or an expression (e.g. 60*60)</font>
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
                                <div id="controlpp1" style="visibility:hidden; display:none" onChange="{style='visibility:visible; display:'}">
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
                                    <td align="right" width="40%"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowX" value="<%=performance.getPlot_lowX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !performance.plot_lowXValid}">
                                            <font size="-1" color="red">Enter a positive number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highX" value="<%=performance.getPlot_highX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !performance.plot_highXValid}">
                                            <font size=-1>Enter a positive number</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowY','Y-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowY" value="<%=performance.getPlot_lowY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !performance.plot_lowYValid}">
                                        <font size="-1" color="red">Must be an integer</font>
                                        </c:if>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highY" value="<%=performance.getPlot_highY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !performance.plot_highYValid}">
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
                                        <input type="text" name="plot_title" value="<%=performance.getPlot_title()%>" size="40" maxlength="100">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">

                                        Figure caption: 

                                    </td>
                                    <td>
                                        <textarea name="plot_caption" rows="5" cols="30"><%=performance.getPlot_caption().replaceAll("\\\\n", "\n") %></textarea>
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
