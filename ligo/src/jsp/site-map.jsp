<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>e-Lab Teacher Site Map</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//Liz Quigg - updated June 2006 to include presurvey and postsurvey links
//be sure to set this before including the navbar
String headerType = "Teacher";
String project = (String)session.getAttribute("appName");
if (project==null) {project="ligo";}
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="include/javascript.jsp" %>
</HEAD>
<body bgcolor=FFFFFF  vlink=ff6600>
<center>
<TABLE WIDTH=800>
<TR><TD>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><td>&nbsp;</td></tr><TR><TD  bgcolor=black>
<FONT FACE=ARIAL COLOR=white SIZE=+1>
<B>Cosmic Site Map</B>
</TD></TR>
</TABLE>
<P>

<center>
<TABLE WIDTH=550>
<TR><TD VALIGN=TOP WIDTH=50%>
<FONT FACE=ARIAL SIZE=-1>
<B>Teacher Pages</B><P>
<A HREF="teacher.jsp">Teacher Page</A><BR>
<A HREF="notes.jsp">Classroom Notes</A><BR>
<a href="strategy.jsp">Teaching Strategies</a><br>
<a href="web_guide.jsp">Research Guidance</a><br>
<a href="activities.jsp">Sample Classroom Activities</a><br>
<A HREF="activities.jsp">Classroom Activities</A><BR>
<A HREF="strategy.jsp">Teaching Strategies</A><BR>
<A HREF="web_guide.jsp">Research Guidance</A><BR>
<A HREF="standards.jsp">Alignment with Standards</A><BR>

<%
String userIndex=(String)session.getAttribute("login");
//Login Check
if (userIndex != null ) {
%>
<%@ include file="common.jsp" %>
<A HREF="presurvey.jsp?type=pre&student_id=0">Pre</A>- and <A HREF="presurvey.jsp?type=post&student_id=0">Post</A> Tests.<BR>
Student Results for <A HREF="surveyResults.jsp?type=pre">Pre</A>- and <A HREF="surveyResults.jsp?type=post">Post</A>- tests.<BR>
<%
                                //must be a admin to see all teachers
                                if(((String)session.getAttribute("role")).equals("admin"))  {  %>
                                
                                
                                               <A HREF="showTeachers.jsp">Show Student Test Results for all Teachers</A><BR>

<% 
                                 }

}
%>
<A HREF="registration.jsp">General Registration</A><BR>
<A HREF="registerStudents.jsp">Student Research Group Registration</A><BR>
<A HREF="updateGroups.jsp">Update Student Research Groups</A><BR>
<A HREF="site-map.jsp">Site Map</A><BR>

</font></TD><TD VALIGN=TOP WIDTH=50%>
<FONT FACE=ARIAL SIZE=-1>
<B>Student Pages</B><P>
<A HREF="http://<%=System.getProperty("host")+System.getProperty("port")%>/elab/<%=project%>/home.jsp">Home</A><BR>
<A HREF="site-index.jsp">Site Index</A><BR><BR>
</font></TD></TR>
</TABLE>
</CENTER>

</BODY>
</HTML>
