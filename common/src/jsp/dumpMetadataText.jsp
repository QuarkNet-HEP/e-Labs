<%@ page import="java.io.*, java.util.*" %>
<%@ include file="common.jsp" %>
<html><body>
<%
//this file simply dumps the metadata lines/Tuples for a file into a space delimited list
String filename = (String)request.getParameter("filename");
if(filename != null){
    String pfn = getPFN(filename);
    out.println("pfn: " + pfn + "<br><br>");
    java.util.List list = getMeta(filename);
    for(Iterator i=list.iterator(); i.hasNext(); ){
        out.println(i.next() + "<br>");
    }
}
%>
</body>
</html>
