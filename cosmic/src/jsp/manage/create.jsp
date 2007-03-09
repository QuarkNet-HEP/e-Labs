<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ include file="../common.jsp" %>

<%
String error = "";       //set to something if there's an error

DBObject dbobject = null;
String object = request.getParameter("object");
if(object == null){
    error = "No object name specified. Don't know what kind of object to create!";
}
else{

    //the object we're creating
    try{
        dbobject = DBObject.newElabDBObject(object);
    }
    catch (Exception e){
        error = e.getMessage();
    }
}

//if a new object is submitted
String submit = request.getParameter("submit");
if(submit != null && submit.equals("Submit")){
    dbobject.setFromParam(request);
    if(dbobject.isValid()){
        dbobject.save();
    }
    else{
        error = "Object not valid yet";
    }
}

%>


<html>
<head>
<title>Create new Elab Object</title>

<link rel="stylesheet" type="text/css" href="../include/style.css" />

    <!-- header/navigation -->
    <%
    //be sure to set this before including the navbar
    String headerType = "Data";
    %>
    <%@ include file="../include/navbar_common.jsp" %>
    <%-- navbar_common closes the <head> tag --%>

<body>
<br>

<%
if(dbobject != null && error.equals("")){
    //debugging
    out.print(dbobject.toXML(false));
    //toXML(false) doesnt show relationships
%>
    <c:choose>
        <c:when test="${param.submit == 'Submit'}">
            <c:import url="confirm.xsl" var="stylesheet" />
        </c:when>
        <c:otherwise>
            <c:import url="create.xsl" var="stylesheet" />
        </c:otherwise>
    </c:choose>

    <x:transform xslt="${stylesheet}">
        <%=dbobject.toXML(false)%>
    </x:transform>
<%
}
else{
    out.println("<font color=red>" + error + "</font><br>");
}
%>


</body>
</html>
