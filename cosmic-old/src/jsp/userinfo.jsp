<%@ include file="common.jsp" %>
<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="org.hibernate.Session" %>
<%@ page import="org.hibernate.Hibernate" %>
<html>
<head>
    <title>Metadata Database stats</title>
</head>
<body>

<%
String pass = "junk";
UserBean ub = new UserBean();
java.util.List l = ub.findByPassword(pass);
for(Iterator i=l.iterator(); i.hasNext(); ){
    User u = (User)i.next();
    out.println("username: " + u.getUsername());
    out.println("<br>last name: " + u.getLastName());
    for(Iterator j=u.getProjects().iterator(); j.hasNext(); ){
        Project p = (Project)j.next();
        System.out.println("<br> project: " + p.getName());
    }
    u.setLastName("this is a last name 2");
    u.save();
}   

l = ub.findByPassword(pass);
for(Iterator i=l.iterator(); i.hasNext(); ){
    User u = (User)i.next();
    out.println("<br>username: " + u.getUsername());
    out.println("<br> new last name: " + u.getLastName());
}   
%>
</body>
</html>
