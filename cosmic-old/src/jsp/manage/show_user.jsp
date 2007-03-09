<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="gov.fnal.elab.cosmic.db.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../common.jsp" %>
<%@ include file="manage_inc.jsp" %>

<%
String this_username = request.getParameter("u");
User me = User.findByUsername(this_username);
//User me = User.findByUsernameAndPassword("paul", "junk");

String userType = "user";
if(me instanceof Manager){
    userType = "manager";
}
else if(me instanceof QuarkNetTeacher){
    userType = "qnteacher";
}

//get if user is required to take surveys
String surveyReq_str = "Not required to take the required surveys for a project.";
if(me.getIsSurveyRequired() == true){
    surveyReq_str = "Required to take the required surveys for a project.";
}

//get detectors
String detectors_str = "";
if(me.isInProject("cosmic")){
    detectors_str += "<td align=center>";
    Set managers = me.getManagers();
    if(managers != null){
        Set detectors = new HashSet();
        for(Iterator i=managers.iterator(); i.hasNext(); ){
            QuarkNetTeacher teacher = (QuarkNetTeacher)i.next();
            Set detectors_curr = teacher.getDetectors();
            if(detectors_curr != null){
                detectors.addAll(detectors_curr);
            }
        }
        detectors_str += formatGraySet(detectors);
    }
    detectors_str += "</td>";
}

//get projects
Set projects = new HashSet();
String projects_str = "";
if(me.getProjects() == null){
    projects.add("not in any projects");
}
else{
    for(Iterator i=me.getProjects().iterator(); i.hasNext();){
        Project p = (Project)i.next();
        projects.add(p.getName());
        projects_str += "&project=" + p.getId().toString();
    }
}

//get persons
String persons_str = "";
if(me.getPersons() != null){
    for(Iterator i=me.getPersons().iterator(); i.hasNext();){
        Person p = (Person)i.next();
        String first = (p.getFirstName() == null) ? "" : p.getFirstName();
        String last = (p.getLastName() == null) ? "" : p.getLastName();
        persons_str += first + " " + last + ", ";
    }
    if(persons_str.length() > 3){
        persons_str = persons_str.substring(0,persons_str.length()-3);
    }
}

//persons who have completed the required surveys
String completed_surveys_str = "Completed survey";

//get managed users
Set managed_users = new HashSet();
if(userType.equals("manager")){
    if(((Manager)me).getManagedUsers() != null){
        for(Iterator i=((Manager)me).getManagedUsers().iterator(); i.hasNext();){
            User u = (User)i.next();
            managed_users.add(u.getUsername());
        }
    }
}
%>


<html>
<head>
    <title>Show User Information</title>
</head>

<body>

<%=headerString("User Info")%>
<hr>

<table width="100%" border="1">
    <tr>
        <td rowspan="4">
            <font size="+1"><%=me.getUsername()%> (<%=me.getFirstName()%> <%=me.getLastName()%>)</font></br>
            email: <%=me.getEmail()%><br>
            <%=surveyReq_str%><br>
            <a href="admin_user.jsp?a=edit&t=<%=userType%>&u=<%=me.getUsername()%>">Edit my info/password</a>
        </td>
    </tr>
    <tr>
        <td align="center">
            My Projects: <%=formatGraySet(projects)%> <a href="choose_projects.jsp?lp=admin_user&lid=set&a=cm&pt=u=<%=me.getUsername()%><%=projects_str%>">(Edit list)</a>
        </td>
    </tr>
    <tr>
        <td align="center">
            My Detectors: TODO
        </td>
    </tr>
    <tr>
        <td align="center">
            14 logbook entries, 1 plots, 0 posters, 13 data files
        </td>
    </tr>

    <tr>
        <td colspan="2">
            Students part of my group: <%=persons_str%> <a href="admin_person?a=edit">(Edit list)</a>
        </td>
    </tr>

    <tr>
        <td colspan="2">
            <%=completed_surveys_str%>
        </td>
    </tr>

    <tr>
        <td colspan="2">
            Managed users: <%=formatGraySet(managed_users)%>
        </td>
    </tr>
</table>

<hr>

<a href="admin_user.jsp?a=new&t=user">Register new user (student group)</a> - <a href="admin_user.jsp?a=new&t=manager">Register new manager</a>
<br>

</body>
</html>
