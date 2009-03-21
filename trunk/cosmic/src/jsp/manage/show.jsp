<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>

<%
String error = "";       //set to something if there's an error

DBObject dbobject = null;
String object = request.getParameter("object");
String objectId = request.getParameter("id");
if(object == null){
    error = "No object name specified. Don't know what kind of data we're listing!";
}
else if(objectId == null){
    error = "No object id specified. Don't know which object of type " + object + " we're showing!";
}
else{

    //the object we're showing
    try{
        dbobject = DBObject.findById(object, objectId);
    }
    catch (Exception e){
        error = e.getMessage();
    }
    if(dbobject == null && error.equals("")){
        error = "No " + object + " with id=" + objectId + " found in the database";
    }
}

%>


<html>
<head>
<title>Show Information</title>

<link rel="stylesheet" type="text/css" href="../include/style.css" />

<body>
<%=error%>
<br>

<%
if(dbobject != null){
    out.print("<!--DEBUG\n" + dbobject.toXML(true) + "-->\n");
    //toXML(false) doesnt show relationships
%>
    <c:import url="show.xsl" var="stylesheet" />
    <x:transform xslt="${stylesheet}">
        <%=dbobject.toXML(true)%>
    </x:transform>
<%
}
else{
    out.println("<font color=red>" + error + "</font><br>");
}
%>


</body>
</html>
