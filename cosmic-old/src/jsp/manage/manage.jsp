<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ include file="../common.jsp" %>

<%
String error = "";       //set to something if there's an error

DBObject dbobject = null;     //the object we're managing
String object = request.getParameter("object");
String action = request.getParameter("a");
String id = request.getParameter("id");
if(object == null){
    error = "No object name specified. Don't know what kind of data we're listing!";
}
else if(action == null){
    error = "Choose either new or edit as an action";
}
else if(action.equals("edit") && id == null){
    error = "Need an object id to edit";
}
else{
    try{
        if(action.equals("new")){
            dbobject = DBObject.newElabDBObject(object);
        }
        else if(action.equals("edit")){
            dbobject = DBObject.findById(object, id);
            if(dbobject == null){
                error = "Could not find id=" + id + " for object " + object;
            }
        }
        else{
            error = "Action should be 'new' or 'edit'";
        }
    }
    catch (Exception e){
        error = e.getMessage();
    }
}

//if an object is submitted
String submit = request.getParameter("submit");
if(submit != null && submit.equals("Submit") && error.equals("")){
    /*
     * Set the object from getParameters
     */
    dbobject.setFromParam(request);

    if(dbobject.isValid()){
        if(action.equals("new")){
            dbobject.save();
        }
        else{
            dbobject.update();
        }
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
    out.print("<!--DEBUG\n" + dbobject.toXML(false) + "-->\n");
    //toXML(false) doesnt show relationships
%>
    <c:choose>
        <c:when test="${param.submit == 'Submit'}">
            <c:import url="confirm.xsl" var="stylesheet" />
        </c:when>
        <c:when test="${param.a == 'edit'}">
            <c:import url="edit.xsl" var="stylesheet" />
        </c:when>
        <c:otherwise>
            <c:import url="create.xsl" var="stylesheet" />
        </c:otherwise>
    </c:choose>

    <%//TODO parameter passing for stylesheets edit/create%>
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
