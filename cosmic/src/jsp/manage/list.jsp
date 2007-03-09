<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>

<%
String error = "";       //set to something if there's an error

//a list of all DBObjects returned from the database of type object
java.util.List obj_list = null;

String action = request.getParameter("a");
if(action == null)
    action = "read";
String object = request.getParameter("object");
String start = request.getParameter("start");
String limit = request.getParameter("limit");
int startInt = 0;
int limitInt = 10;
    startInt = (start == null) ? 0 : Integer.parseInt(start);
    limitInt = (limit == null) ? 10 : Integer.parseInt(limit);
if(object == null){
    error = "No object name specified. Don't know what kind of data we're listing!";
}
else{
    try{
        obj_list = DBObject.findAll(object, startInt, limitInt);
    }
    catch (Exception e){
        error = e.getMessage();
    }
    if(obj_list == null && error.equals("")){
        error = "Couldn't find the object " + object + " in the database.";
    }
}

%>


<html>
<head>
<title>List</title>

<link rel="stylesheet" type="text/css" href="../include/style.css" />

<body>
<br>

<%
if(obj_list != null && error.equals("")){
    out.print("<!--DEBUG<![CDATA[" + DBObject.toXMLList(obj_list, true) + "]]-->\n");
    //toXML(true) includes relationships
%>
    <c:choose>
        <c:when test="${param.a == 'choose'}">
            <c:import url="list_choose.xsl" var="stylesheet" />
        </c:when>
        <c:otherwise>
            <c:import url="list.xsl" var="stylesheet" />
        </c:otherwise>
    </c:choose>

    <x:transform xslt="${stylesheet}">
        <x:param name="object" value="stuff" />
        <%=DBObject.toXMLList(obj_list, true)%>
    </x:transform>
    <a href="list.jsp?object=<%=object%>&start=<%=startInt-10%>&limit=<%=limitInt%>">previous</a>
    <a href="list.jsp?object=<%=object%>&start=<%=startInt+10%>&limit=<%=limitInt%>">next</a>
<%
}
else{
    out.println("<font color=red>" + error + "</font><br>");
}
%>


</body>
</html>
