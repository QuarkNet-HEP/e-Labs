<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="gov.fnal.elab.cosmic.db.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../common.jsp" %>
<%@ include file="manage_inc.jsp" %>

<%
java.util.List u_list = null;   //list of chosen user types
String type = request.getParameter("t");
if(type.equals("user")){
    u_list = User.findAll();
}
else if(type.equals("manager")){
    u_list = Manager.findAll();
}
else if(type.equals("teacher")){
    u_list = QuarkNetTeacher.findAll();
}

//action for this page
String action = request.getParameter("a");
if(action == null){
    action = "view";
}
%>

<html>
<head>
    <title>List Users</title>
</head>

<body>

<%=headerString("Users")%>
<hr>

<table width="100%" border="1">
<%
String lp = "";
String lid = "";
if(action.equals("choose_multiple")){
    lp = request.getParameter("lp"); //link to page
    lid = request.getParameter("lid");   //link id
%>
    <form action="<%=lp+".jsp"%>" method="post">
<%
}
for(Iterator i=u_list.iterator(); i.hasNext(); ){
    User u = (User)i.next();
    if(action.equals("choose_multiple")){
        out.println("<tr><td><input type=checkbox name=" + lid + " value=" + u.getId() + ">" + u.getUsername() + "</td></tr>");
    }
    else{
        out.println("<tr><td>" + u.getUsername() + "</td></tr>");
    }
}
if(action.equals("choose_multiple")){
    String[] pt = request.getParameterValues("pt");     //passthrough variables
    if(pt != null){
        for(int i=0; i<pt.length; i++){
            String[] nv = pt[i].split("=", 2);      //name-value
            out.println("<input type=hidden name=" + nv[0] + " value=" + nv[1] + ">");
        }
    }
%>
    <td><input type="submit" name="submit" value="Submit"></td>
    <td><input type="hidden" name="submitType" value="set_teacher"></td>
    </form>
<%
}
%>

</table>


<hr>

</body>
</html>
