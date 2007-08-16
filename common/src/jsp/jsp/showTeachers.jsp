<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Show Teachers for Test Results</title>
    </head>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Teacher";

%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="include/javascript.jsp" %>
    <body>
        <center>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
<%
           //groupName defined in common.jsp
     groupName=(String) session.getAttribute("login"); // this is added because common.jsp gives a null groupName with user admin.
     String role="";
     String query="select id,role from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       role=rs.getString("role");}
       
       if (!(role.equals("admin"))) {%> Problem with role for group <%=groupName%><BR>Only administrators have access to this.<% return;}
%>


    		<p>
    		<table width=700 cellpadding=4>
				<tr>
            		<td bgcolor="black"> 
                		<font face="arial" color="white" size="+1">
                    		<b>
                        		Teachers whose students took tests. Click <B>Show Tests Results</b>.
                    		</b>
                		</font> 
            		</td>
        		</tr> 
    		</table>
    		<p>

     <%

     query="select DISTINCT teacher.name as teacher_name,teacher.id as id from teacher,research_group,research_group_student where teacher.id=research_group.teacher_id and research_group.id=research_group_student.research_group_id and research_group_student.student_id in (select DISTINCT answer.student_id from answer);";
     rs = s.executeQuery(query);
%>
    <table width="500">
    <tr><th align="left">Teacher</th></tr>
<%   while(rs.next()){
       String name=rs.getString("teacher_name");
       String teacherID=rs.getString("id");
    %>
	<tr><td><%=name%></td><td><A HREF="surveyResultsbyID.jsp?teacher_id=<%=teacherID%>&type=presurvey">Pre-test Results</A></td><td><A HREF="surveyResultsbyID.jsp?teacher_id=<%=teacherID%>&type=postsurvey">Post-test Results</A></td></tr>
    <%
     } //while
     %>
  </table>
</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
  
