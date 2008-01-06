<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ include file="common.jsp" %>

<html>
<head>
<title>Raw Datafile Analysis</title>

    <!-- include css style file -->
    <%@ include file="include/style.css" %>
    <!-- header/navigation -->
    <%
    //be sure to set this before including the navbar
    String headerType = "Data";
    %>
    <%@ include file="include/navbar_common.jsp" %>
    <%-- navbar_common closes the <head> tag --%>

<body>
</center>
<br>

<table border="1">
    <tr>
        <td align="center">
            School
        </td>
        <td align="center">
            Start Date
        </td>
        <td align="center">
            End Date
        </td>
        <td align="center">
            Total Events
        </td>
        <td align="center">
            Gatewidth
        </td>
        <td align="center">
            Average hits per event
        </td>
        <td align="center">
            Valid GPS events
        </td>
        <td align="center">
            Invalid GPS events
        </td>
        <td align="center">
            No CPLD update
        </td>
    </tr>
<c:import url="rawanalyzeMultiple.xsl" var="stylesheet" />
<%
String[] lfn = request.getParameterValues("f");
if(lfn == null)
    return;
for(int i=0; i<lfn.length; i++){
    String fqpf = getPFN(lfn[i] + ".analyze");

    if(fqpf == null){
        out.println("<tr><td colspan=9>" + lfn[i] + 
            " has not been <a href=rawanalyzeOutput.jsp?filename=" + lfn[i] + 
            ">analyzed</a> yet.</td></tr>");
    }
    else{
        File f = new File(fqpf);
        if(f.exists()){
            //get metadata for lfn
            java.util.List meta = getMeta(lfn[i]);
            HashMap metaMap = new HashMap();
            for(Iterator metai=meta.iterator(); metai.hasNext(); ){
                Tuple t = (Tuple)metai.next();
                metaMap.put(t.getKey(), t.getValue());
            }

            String school = lfn[i]; //default if no metadata
            String startdate = "";
            String enddate = "";
            if(metaMap.size() > 0){
                school = (String)metaMap.get("school");
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("M/d/yy hh:mm a");
                sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
                startdate = sdf.format((Date)metaMap.get("startdate"));
                enddate = sdf.format((Date)metaMap.get("enddate"));
            }

            BufferedReader br = new BufferedReader(new FileReader(f));
            String str = null;
%>
            <tr>
                <td align="left">
                    <%=school%>
                </td>
                <td align="center">
                    <%=startdate%>
                </td>
                <td align="center">
                    <%=enddate%>
                </td>
                <x:transform xslt="${stylesheet}">
<%
                while((str = br.readLine()) != null){
                    out.println(str);
                }
%>
                </x:transform>
            </tr>
<%
        }
    }
}
%>
</table>

<p align="right">
<a href="javascript:history.go(-1)">Back</a> to the study
</p>

</body>
</html>
