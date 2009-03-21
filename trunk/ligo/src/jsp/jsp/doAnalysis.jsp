<%@ include file="common.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<%
String html_title = (request.getParameter("html_title") == null) ? "Analyze" : request.getParameter("html_title");
%>
    <TITLE><%=html_title%></TITLE>
    <META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<%@ include file="include/javascript.jsp" %>
</HEAD>
<BODY>


<%
//type of analysis study the user chose:
String analyzeType = request.getParameter("type");
%>

<FONT face=ARIAL>
<CENTER>
<TABLE width="100%" cellpadding="0" cellspacing="0" align=center>

<!-- type/study specific checks on parameters, and TR setup -->
<%
String tr = null;
if(analyzeType == null){
%>
    <tr><td><b>Please <a href="search.jsp">choose</a> a study before running an analysis.</b></td></tr>
<%
    return;
}
else if(analyzeType.equals("shower")){
    tr = "Quarknet.Cosmic::ShowerStudyNoThresh";
    //tr = "Quarknet.Cosmic.Test::ShowerStudyPart1";
%>
    <%@ include file="include/doAnalysis_shower_checks.jsp" %>
<%
}
else if(analyzeType.equals("performance")){
    tr = "Quarknet.Cosmic::PerformanceStudyNoThresh";
%>
    <%@ include file="include/doAnalysis_performance_checks.jsp" %>
<%
}
else if(analyzeType.equals("flux")){
    tr = "Quarknet.Cosmic::FluxStudyNoThresh";
%>
    <%@ include file="include/doAnalysis_flux_checks.jsp" %>
<%
}
else if(analyzeType.equals("lifetime")){
    tr = "Quarknet.Cosmic::LifeTimeStudyNoThresh";
%>
    <%@ include file="include/doAnalysis_lifetime_checks.jsp" %>
<%
}
%>

<%
// Paul's analyze notes 7-12-04
// I decided not to make the VDL database connection a function and instead 
//  made it an include (because of the scratchplot file it creates and because
//  of the variables it needs from common.jsp)

//note this is all code that *should* be a method or Java Bean...

// The following variables should be setup before including analyze
boolean error = false;      //true only if there's an error in the DV creation
String scratchPlot = "";    //name of the temporary plot file to create
String thumbnail = ""; // name of the thumbnail of the plot we created.
%>

<%@ include file="include/doAnalysis_TR_call.jsp" %>


<%
if(!error){
    if(analyzeType == null){
%>
        <tr><td><b>Please <a href="search.jsp">choose</a> a study before running an analysis.</b></td></tr>
<%
        return;
    }
    else if(analyzeType.equals("shower")){
%>
        <%@ include file="include/doAnalysis_shower_metadata.jsp" %>
<%
    }
    else if(analyzeType.equals("performance")){
%>
        <%@ include file="include/doAnalysis_performance_metadata.jsp" %>
<%
    }
    else if(analyzeType.equals("flux")){
%>
        <%@ include file="include/doAnalysis_flux_metadata.jsp" %>
<%
    }
    else if(analyzeType.equals("lifetime")){
%>
        <%@ include file="include/doAnalysis_lifetime_metadata.jsp" %>
<%
    }
}
else{
    out.write("There was an error with the analysis call.\n");
}
%>

</TABLE>
<a href=# onclick="window.close()">Close</A>
</CENTER>
</FONT>
</BODY>
</HTML>
