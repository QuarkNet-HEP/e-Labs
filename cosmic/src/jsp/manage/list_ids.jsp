<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ page contentType="text/html" %>

<%
/*
 * A test/benchmarking page
 */

String error = "";       //set to something if there's an error

//a list of all DBObjects returned from the database of type object
java.util.List obj_list = null;

String object = request.getParameter("object");
String start = request.getParameter("start");
String limit = request.getParameter("limit");
int startInt = (start == null) ? 1 : Integer.parseInt(start);
int limitInt = (limit == null) ? 10 : Integer.parseInt(limit);
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
    out.println("Total IDs: " + obj_list.size() + "<br>");
    for(Iterator i=obj_list.iterator(); i.hasNext(); ){
        DBObject obj = (DBObject)i.next();
        out.println(obj.getId() + "<br>");
    }
}
else if(!error.equals("")){
    out.println("<font color=red>" + error + "</font><br>");
}
else{
    out.println("<font color=red>No objects found</font>");
}
%>


</body>
</html>
