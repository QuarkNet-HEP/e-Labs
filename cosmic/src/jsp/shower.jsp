<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />

<%
boolean setNewEventNum = true;
HashMap id_to_name = new HashMap();     //detector id mapped to "school name, location"

String submit = request.getParameter("submit");
String dvName = request.getParameter("dvName");
//if a name is speficied, setup the bean from the VDC
if(dvName != null){
    ElabTransformation loadOnly = new ElabTransformation("Quarknet.Cosmic::ShowerStudy");
    loadOnly.loadDV("Quarknet.Cosmic.Users::" + dvName);
    shower.mapToBean(loadOnly.getDV());
    loadOnly.close();
}
//else, set the bean through user form input
else{
    //reset the bean only if the page is called for the first time
    if(submit == null){
        shower.reset();

        //default values (if different from the bean):
        shower.setPlot_title("Shower Study");
        shower.setPlot_xlabel("East/West (meters)");
        shower.setPlot_ylabel("North/South (meters)");
        shower.setPlot_zlabel("Time (nanosec)");
        shower.setSort_sortKey1("2");
        shower.setSort_sortKey2("3");
        shower.setPlot_outfile_param("plot_outfile_param");
        shower.setPlot_outfile_image("plot_outfile_svg");
        shower.setPlot_plot_type("2");
        //shower.setEventNum("1");  //see showerOutput.jsp
        shower.setGate("100");
        shower.setDetectorCoincidence("1");
        shower.setChannelCoincidence("2");
        shower.setEventCoincidence("2");
        shower.setEventFile("eventFile");
    }
    else if(submit.equals("Analyze")){
        //there's only 1 case when we DONT want to set the event number automatically:
        // - if the user previously set it AND did not change any parameters which change the eventCandidates file
        if(!shower.getEventNum().equals("")
                && request.getParameter("gate").equals(shower.getGate())
                && request.getParameter("channelCoincidence").equals(shower.getChannelCoincidence())
                && request.getParameter("eventCoincidence").equals(shower.getEventCoincidence())
                && request.getParameter("detectorCoincidence").equals(shower.getDetectorCoincidence())){
            setNewEventNum = false;
        }
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
            for(Iterator i=shower.getRawData().iterator(); i.hasNext(); ){
                String s = (String)i.next();
                if(!set.contains(s)){
                    new_file_list.add(s);   //add file to new list if it's not selected for removal
                }
            }

            //set raw data as new updated list
            shower.setRawData(new_file_list);
        }
    }
%>

    <%-- Set every string that is *vaild* as an empty string as an empty string --%>
    <%-- Note that this must be done here because setProperty * ignores empty strings --%>
    <%-- It's an unfortunate side-effect of using jsp:setProperty * --%>
    <c:if test="${param.submit == 'Analyze'}">
        <jsp:setProperty name="shower" property="plot_lowX" value="" />
        <jsp:setProperty name="shower" property="plot_highX" value="" />
        <jsp:setProperty name="shower" property="plot_highY" value="" />
        <jsp:setProperty name="shower" property="plot_highY" value="" />
        <jsp:setProperty name="shower" property="plot_title" value="" />
        <jsp:setProperty name="shower" property="plot_caption" value="" />
    </c:if>
    <jsp:setProperty name="shower" property="*" />

<%
    //get files to analyze if sent from a previous form
    String[] f = request.getParameterValues("f");
    if(f != null){
        java.util.List rawData = new ArrayList(1);  //initial size 1
        rawData = Arrays.asList(f); 
        shower.setRawData(rawData);
    }

    //set threshold and wire delay data based off raw data names
    java.util.List rawData = shower.getRawData();
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

        shower.setThresholdAll(thresholdData);
        shower.setWireDelayData(wireDelay);
        shower.setDetector(detectorIDs.trim());

        
    }
%>

    <%-- variables which the user doesn't choose here, but are needed for the TR --%>
    <%-- NOTE: jsp will simply stop outputing with no error message if you misspell or miscapitalize names in setProperty. BE CAREFUL!! --%>
    <jsp:setProperty name="shower" property="geoDir" value="<%=dataDir%>" />
    
<%
}//end bean setup
//create mapping from id to school name
java.util.List l = shower.getRawData();
if(l != null){
    for(ListIterator i=shower.getRawData().listIterator(); i.hasNext();) {
        String s = (String)i.next();

        HashMap metaMap = new HashMap();
        java.util.List meta = getMeta(s);
        if(meta != null){
            //create a metadata key-value hash
            for(Iterator metai=meta.iterator(); metai.hasNext(); ){
                Tuple t = (Tuple)metai.next();
                metaMap.put(t.getKey(), t.getValue());
            }
            //create the mapping in the id_to_name hash
            id_to_name.put((String)metaMap.get("detectorid"), 
                    metaMap.get("school") + ", " + metaMap.get("city") + 
                    " " + metaMap.get("state") + " (" + metaMap.get("detectorid") + ")");
        }
    }
}   
%>


<%-- redirect to output page if bean is valid and user has hit "submit" --%>
<c:if test="${shower.valid and param.submit == 'Analyze'}">
    <jsp:forward page="showerOutput.jsp">
        <jsp:param name="plot_size" value="<%=request.getParameter("plot_size")%>" />
    </jsp:forward>
</c:if>


<html>
<head>
    <title>Choose shower parameters</title>

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
if(!shower.isRawDataValid()){
%>
    <p><font color="red">Filename missing!</font><br>
    Please <a href="search.jsp?t=split&f=analyze&s=shower">choose</a> at least one day to analyze.</p>
<%
    return;
}
%>


<table id="instructions">
    <tr>
        <td height="26" bgcolor="#4382BB" align="left">
            <font color="000000">
                <b>
                    Look for showers in your data.
                </b>
            </font>
        </td>
    </tr>
    <tr>
        <td height="26" bgcolor="#FFFFFF" align="center">
            <font color="000000">
                <a href="eshtutorial.jsp" class="table">Understand The Graph</a>
            </font>
        </td>
    </tr>
</table>

<%
//create a rawData variable before including analyzing_list
java.util.List rawDataReference = shower.getRawData();
java.util.List rawData = new java.util.ArrayList(rawDataReference.size());
for(Iterator i=rawDataReference.iterator(); i.hasNext(); ){
    rawData.add(new String((String)i.next()));
}
%>

<!-- form for analysys options. Put before analyzing_list since it includes form inputs -->
<form name="analysisform" 
    action="shower.jsp" 
    method="get" >

<%-- provides detectorIDs and validChans variables --%>
<%-- also provides rawDataString and detectorIDString vars --%>
<%@ include file="include/analyzing_list.jsp" %>

<!-- use files in other analyses -->
<font color="#d18ab1">Analyze these same files in study: 
<a href="lifetime.jsp?<%=filenames_str%>">lifetime</a>
<a href="flux.jsp?<%=filenames_str%>">flux</a>
<br>


<%-- Set default plot_caption --%>
<%
//set these only if we're not getting data from the form or a previous DV
if(submit == null && dvName == null){
    String zeroID = (String)detectorIDs.iterator().next();
    shower.setPlot_caption(rawDataString + "\n" + detectorIDString + "\n" + 
            "Event Coincidence: 2\nDetector Coincidence: 1\nEvent Gate: 100\n" 
            + "Center of graph view: " + zeroID);
    shower.setZeroZeroZeroID(zeroID);
}
%>


<P>
<table border=1 cellpadding=20 bgcolor="#f6f6ff">
    <c:if test="${!(empty shower.invalidKeys)}">
        <tr>
            <td>
                <c:forEach var="f" items="${shower.invalidKeys}">
                <font color="red">Invalid keys: </font><c:out value="${f}" /><br>
                </c:forEach>
            </td>
        </tr>
    </c:if>

<tr>
    <td colspan="1" valign="top">
        Enter the analysis parameters and click Analyze to create a shower plot.
        <p>
        <p>
        <center>
            <table width="100%" align="center">
                <input name="compute_location" type="hidden" value="locally">
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
                                        <a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','zeroZeroZeroID','Center of graph view')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Center of graph view:</td>
                                    <td width="40%" align="left">
                                        <select name="zeroZeroZeroID" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nEvent Coincidence: ' + eventCoincidence.value + '\nDetector Coincidence:' + detectorCoincidence.value + '\nEvent Gate: ' + gate.value + '\nCenter of graph view: ' + zeroZeroZeroID.value}">
                                            <%
                                            for(Iterator i=detectorIDs.iterator(); i.hasNext(); ){
                                                String detector = (String)i.next();
                                                String name = (String)id_to_name.get(detector);
                                                if(shower.getZeroZeroZeroID().equals(detector)){
                                            %>
                                                    <option value=<%=detector%> selected><%=name%></option>
                                            <%
                                                }
                                                else{
                                            %>
                                                    <option value=<%=detector%>><%=name%></option>
                                            <%
                                                }
                                            }
                                            %>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','gate','Event Gate')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Event Gate (ns):
                                    </td>
                                    <td>
                                        <input type="text" name="gate" value="<%=shower.getGate() %>" size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nEvent Coincidence: ' + eventCoincidence.value + '\nDetector Coincidence: ' + detectorCoincidence.value + '\nEvent Gate: ' + gate.value + '\nCenter of graph view: ' + zeroZeroZeroID.value}">
                                        <c:if test="${param.submit == 'Analyze' and !shower.gateValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        Detector Coincidence:
                                    </td>
                                    <td>
                                        <input type="text" name="detectorCoincidence"  value="<%=shower.getDetectorCoincidence() %>"  size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nEvent Coincidence: ' + eventCoincidence.value + '\nDetector Coincidence: ' + detectorCoincidence.value + '\nEvent Gate: ' + gate.value + '\nCenter of graph view: ' + zeroZeroZeroID.value}">
                                        <c:if test="${param.submit == 'Analyze' and !shower.detectorCoincidenceValid}">
                                            <font size="-1" color="red">Must be a positive integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        Channel Coincidence:
                                    </td>
                                    <td>
                                        <input type="text" name="channelCoincidence"  value="<%=shower.getChannelCoincidence() %>"  size="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.channelCoincidenceValid}">
                                            <font size="-1" color="red">Must be a positive integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::ShowerStudyNoThresh','coincidence','Coincidence Level')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Event Coincidence Level:
                                    </td>
                                    <td>
                                        <input type="text" name="eventCoincidence"  value="<%=shower.getEventCoincidence() %>"  size="8" onChange="{plot_caption.value='<%=rawDataString%>\n<%=detectorIDString%>\nEvent Coincidence: ' + eventCoincidence.value + '\nDetector Coincidence: ' + detectorCoincidence.value + '\nEvent Gate: ' + gate.value + '\nCenter of graph view: ' + zeroZeroZeroID.value}">
                                        <c:if test="${param.submit == 'Analyze' and !shower.eventCoincidenceValid}">
                                            <font size="-1" color="red">Must be an integer</font>
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
                            <c:when test="${param.submit == 'change'}">
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
                            <c:when test="${param.submit == 'change'}">
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
                            <c:when test="${param.submit == 'change'}">
                                <div id='plotParam0' style="visibility:visible; display:">
                            </c:when>
                            <c:otherwise>
                                <div id='plotParam0' style="visibility:hidden; display:none;">
                            </c:otherwise>
                        </c:choose>
                            <table width="100%" align="center">
                                <tr>
                                    <td align="right" width="40%">
                                        <a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowX','X-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowX" value="<%=shower.getPlot_lowX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_lowXValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highX','X-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        X-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highX" value="<%=shower.getPlot_highX() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_highXValid}">
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
                                        <input type="text" name="plot_lowY" value="<%=shower.getPlot_lowY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_lowYValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highY','Y-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Y-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highY" value="<%=shower.getPlot_highY() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_highYValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <a href="javascript:describe('Quarknet.Cosmic::Plot','plot_lowZ','Z-min')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Z-min: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_lowZ" value="<%=shower.getPlot_lowZ() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_lowZValid}">
                                            <font size="-1" color="red">Must be an integer</font>
                                        </c:if>

                                    </td>
                                </tr>
                                <tr>
                                    <td align="right"><a href="javascript:describe('Quarknet.Cosmic::Plot','plot_highZ','Z-max')"><IMG SRC="graphics/question.gif" border="0"></a>
                                        Z-max: 
                                    </td>
                                    <td>
                                        <input type="text" name="plot_highZ" value="<%=shower.getPlot_highZ() %>" size="8" maxlength="8">
                                        <c:if test="${param.submit == 'Analyze' and !shower.plot_highZValid}">
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
                                        <input type="text" name="plot_title" value="<%=shower.getPlot_title()%>" size="40" maxlength="100">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">

                                        Figure caption: 

                                    </td>
                                    <td>
                                        <textarea name="plot_caption" rows="5" cols="30"><%=shower.getPlot_caption().replaceAll("\\\\n", "\n") %></textarea>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </center>

        <div align="center">
<%
            if(setNewEventNum){
%>
                <input name="setNewEventNum" type="hidden" value="1">
<%
            }
%>
            <input name="submit" type="submit" value="Analyze">
        </div>
    </td>
</tr>
</table>
<!-- end of analysis options form -->
</form>

</body>
</html>
