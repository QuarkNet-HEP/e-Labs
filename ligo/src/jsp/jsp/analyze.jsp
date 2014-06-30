<%@ include file="common.jsp" %>

<html>
<head>
	<title>Choose Raw Data Center</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- include css style file -->
    <%@ include file="include/style.css" %>
    <%@ include file="include/javascript.jsp" %>
    <!-- header/navigation -->
    <%
    //be sure to set this before including the navbar
    String headerType = "Data";
    %>
    <%@ include file="include/navbar_common.jsp" %>
    
<%
//type of analysis study the user chose:
String analyzeType = request.getParameter("type");

//get filenames for analysis
String[] rawData = request.getParameterValues("filename");
if(rawData == null || rawData.length == 0){
%>
    <br>
    <center>Please <a href="search.jsp?t=split&f=analyze&s=<%=analyzeType%>">choose</a> a data set to analyze.
<%
    return;
}

//include the specific type of instructions/search options based on the analyzeType
if(analyzeType == null){
%>
    <tr><td><b>Please <a href="search.jsp">choose</a> a study for your analysis.</b></td></tr>
<%
    return;
}
else if(analyzeType.equals("shower")){
%>
    <%@ include file="include/analyze_shower_instructions.html" %>
<%
}
else if(analyzeType.equals("performance")){
%>
    <%@ include file="include/analyze_performance_instructions.html" %>
<%
}
else if(analyzeType.equals("flux")){
%>
    <%@ include file="include/analyze_flux_instructions.html" %>
<%
}
else if(analyzeType.equals("lifetime")){
%>
    <%@ include file="include/analyze_lifetime_instructions.html" %>
<%
}
%>

<!-- provides detectorIDs and validChans variables -->
<%@ include file="include/analyze_youre_analyzing.jsp" %>


<!-- form for analysys options -->
<FORM name="analysisform" ACTION="doAnalysis.jsp?type=<%=analyzeType%>"  method="post" target="mypopup" onsubmit='return openPopup("",this.target,650, 750);' >
<%
//need to pass rawData filenames as hidden variables
for (int i=0; i<rawData.length; i++){
    String lfn = rawData[i];
%>
    <input type="hidden" name="thresholdAll" value="<%=lfn%>">
<%
}
%>

<%
//include the specific type of options/parameters based on the analyzeType
if(analyzeType == null){
%>
    <tr><td><b>Please <a href="search.jsp">choose</a> a study for your analysis.</b></td></tr>
<%
    return;
}
else if(analyzeType.equals("shower")){
%>
    <%@ include file="include/analyze_shower_options.jsp" %>
<%
}
else if(analyzeType.equals("performance")){
%>
    <%@ include file="include/analyze_performance_options.jsp" %>
<%
}
else if(analyzeType.equals("flux")){
%>
    <%@ include file="include/analyze_flux_options.jsp" %>
<%
}
else if(analyzeType.equals("lifetime")){
%>
    <%@ include file="include/analyze_lifetime_options.jsp" %>
<%
}
%>

<!-- end of analysis options form -->
</form>
</center>
</font>
</BODY>
</HTML>
