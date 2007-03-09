<%@ page buffer="1000kb" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
Object o = pageContext.getAttribute("shower", PageContext.SESSION_SCOPE);
if(o == null){ 
    //TODO: fix (to some better page)
    response.sendRedirect("http://" + System.getProperty("host")+System.getProperty("port") + "/elab/search.jsp");
    return;
}
%>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />

<%
String outputDir = request.getParameter("outputDir");
String fullOutputDir = runDir + outputDir;
String eventNum = request.getParameter("eventNum");

//String thumbHeight = "150";

String plotName = "outsvg" + eventNum + ".svg";
String plotDataName = "outdata" + eventNum;                             //event specific plot datapoints
String pngPlotName = plotName.replaceAll("\\.svg", "\\.png");           //for metadata
String thumbPngPlotName = plotName.replaceAll("\\.svg", "_thm.png");    //for metadata
String fullSizeURL = runDirURL + outputDir + "/" + pngPlotName;         //for img src
String fullSizePath = fullOutputDir + "/" + pngPlotName;                //for svg2png
String thumbPath = fullOutputDir + "/" + thumbPngPlotName;              //for svg2png
//String thumbPathURL = runDirURL + outputDir + "/" + thumbPngPlotName;   //unused
%>

<html>
<body>
<center>
    <img src="<%=fullSizeURL%>">
    <br>
    Plot Datapoints:<br>
    <table cellspacing="0" cellpadding="2" border="0">
        <tr>
            <td align="center">
                East/West<br>(meters)
            </td>
            <td align="center">
                North/South<br>(meters)
            </td>
            <td align="center">
                Time<br>(nanosec)
            </td>
            <td align="center">
                Detector
            </td>
            <td align="center">
                Channel
            </td>
        </tr>
<%
String eventFile = shower.getEventFile();
File eFile = new File(fullOutputDir + "/" + eventFile);
BufferedReader br = new BufferedReader(new FileReader(eFile));

String str = null;
int count=1;
while((str = br.readLine()) != null){
    if(str.matches("^.*#.*")){
        continue;   //ignore comments in the file
    }
    String arr[] = str.split("\\s");
    String IDChan[] = arr[3].split("\\.");
    String x = arr[0];
    String y = arr[1];
    String z = arr[2];
    String id = IDChan[0];
    String chan = IDChan[1];
    //Alternating Row Colors (http://time-tripper.com/uipatterns/index.php?page=Alternating_Row_Colors)
    if(count%2 == 0){
        out.println("<tr bgcolor=\"#CCFFBB\">");
    }
    else{
        out.println("<tr>");
    }
%>
            <td align="center">
                <%=x%>
            </td>
            <td align="center">
                <%=y%>
            </td>
            <td align="center">
                <%=z%>
            </td>
            <td align="center">
                <%=id%>
            </td>
            <td align="center">
                <%=chan%>
            </td>
        </tr>
        <!-- <tr><td colspan="3"><%=str%></td></tr> -->
<%
    count++;
}
%>
    </table>
    <br>
</center>

<p align="center">To save this plot permanently, enter the new name you want.<br>
Then click <b>Save Plot</b>.<br>

<center>
<form name="SaveForm" ACTION="save.jsp"  method="post" target="saveWindow" onSubmit='return openPopup("",this.target,500,200);' align="center">
<%
    //Metadata section
    //there seems to be an unwritten rule to use lowercase for metadata...
    //pass any arguments to write as metadata in the "metadata" form variable as tuple strings
%>

<%
//set rawData List variable before calling common_metadata_to_save
java.util.List rawDataReference = shower.getRawData();
java.util.List rawData = new java.util.ArrayList(rawDataReference.size());
for(Iterator i=rawDataReference.iterator(); i.hasNext(); ){
    rawData.add(new String((String)i.next()));
}
%>

<%@ include file="include/common_metadata_to_save.jsp" %>

    <input type="hidden" name="beanName" value="shower">
    <input type="hidden" name="metadata" value="transformation string Quarknet.Cosmic::ShowerStudyNoThresh" >

    <input type="hidden" name="metadata" value="detectorcoincidence int <%=shower.getDetectorCoincidence() %>" >
    <input type="hidden" name="metadata" value="eventcoincidence int <%=shower.getEventCoincidence() %>" >
    <input type="hidden" name="metadata" value="eventnum int <%=shower.getEventNum() %>" >
    <input type="hidden" name="metadata" value="gate int <%=shower.getGate() %>" >
    <input type="hidden" name="metadata" value="radius int -1" >
    <input type="hidden" name="metadata" value="study string shower" >
    <input type="hidden" name="metadata" value="type string plot" >

    <input type="hidden" name="metadata" value="title string <%=shower.getPlot_title()%>" >
    <input type="hidden" name="metadata" value="caption string <%=shower.getPlot_caption()%>">

    <input type="hidden" name="outputDir" value="<%=outputDir%>" >
    <input type="hidden" name="pngFile" value="<%=pngPlotName%>" >
    <input type="hidden" name="pngThumb" value="<%=thumbPngPlotName%>" >
    <input type="text" name="permanentFile"  size="20" maxlength="30">.png
    <input type="hidden" name="fileType" value="png" >
    <input name="save" type="submit" value="Save Plot">
</form>
</center>

</body>
</html>
