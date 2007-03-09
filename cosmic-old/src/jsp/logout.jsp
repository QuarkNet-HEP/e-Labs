<%@ page import="java.util.*" %>

<html>
<body>
<%
String login = (String)session.getAttribute("login");
String role = (String)session.getAttribute("role");
String prevPage = request.getParameter("prevPage");
session.invalidate();
if(login != null && role.equals("teacher")){
    response.sendRedirect("teacher.jsp");
}
else if (prevPage != null && !prevPage.equals("")) {
    response.sendRedirect("/elab" + prevPage);
}
else{
    response.sendRedirect("home.jsp");
}
%>
</body>
</html>
