<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page buffer="64kb" %>

<%@ include file="include/style.css" %>
<%@ include file="common.jsp" %>


<%
String prevPage = request.getParameter("prevPage");
boolean incorrectLogin = false;
if(prevPage == null){    //the page the user was previously requesting
    prevPage = "/cosmic/home.jsp";     //default redirect
}
%>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
String username = request.getParameter("user");
String pass = request.getParameter("pass");
if (username != null && pass != null){
    //database lookup of username/password
    rs = s.executeQuery("SELECT id, teacher_id, role, userarea, survey, first_time FROM research_group WHERE " +
                        "name='" + username + "' AND " +
                        "password='" + pass + "';");
    if(rs.next() == false){
        incorrectLogin = true;
    }
    else{
        String groupID = rs.getString("id");
        String teacherID = rs.getString("teacher_id");
        String role = rs.getString("role");
// BENC: something of a hack -- this variable is defined in common.jsp
        userArea = rs.getString("userarea");
        String survey = rs.getString("survey");
        boolean firstTime = rs.getBoolean("first_time");

        //setup derived variables
// BENC: as above, this one is defined in common.jsp
        userDir = (String) System.getProperty("portal.users") + userArea;
        String userDirURL = "users/" + userArea;
        ResultSet rs2 = s.executeQuery("SELECT project.name FROM project, research_group WHERE research_group.id='" + groupID + "';");
        if(rs2.next() == false){
            warn(out, "Your group is not associated with any project. Contact the person who entered your group into the database and tell them this.");
            return;
        }
        else{
            String project = rs2.getString(1);

            //set some statistics
            String SQLstatement = 
                "INSERT INTO usage (research_group_id) " +
                "VALUES(" + groupID + ");";
            int i = s.executeUpdate(SQLstatement);
            if(i != 1){
                warn(out, "Weren't able to add statistics info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
            }

            //set attributes
            session.setAttribute("UserName", username);     //TODO
            session.setAttribute("login", username);
            session.setAttribute("role", role);
            session.setAttribute("groupID", groupID);
            session.setAttribute("teacherID", teacherID);
            session.setAttribute("survey", survey);
            session.setAttribute("userDir", userDir);
            session.setAttribute("userDirURL", userDirURL);
            session.setAttribute("userArea", userArea);
            //7-21-04: using the postgres database to find the appName
            //String appName = (new File(home)).getName();
            session.setAttribute("appName", project);
            
            // I finally found the solution to the double login problem, and it's this
            // one line.  :)  Please don't remove.
            response.addCookie(new Cookie("JSESSIONID", session.getId()));

            if (role.equals("teacher")) {
                if (prevPage.endsWith("home.jsp")) {
                    response.sendRedirect(
                            response.encodeRedirectURL(
                                "http://" + System.getProperty("host") + 
                                System.getProperty("port") + "/elab/cosmic/teacher.jsp"));
                } else {
                    response.sendRedirect(
                            response.encodeRedirectURL(
                                "http://" + System.getProperty("host") + 
                                System.getProperty("port") + "/elab"+prevPage));
                }
            } else if (firstTime || username.equals("guest")) {
                    //check if all the students have taken the test. 
                    int countStudents=0;
                    rs = s.executeQuery("select count(*) from student,research_group_student,research_group_project,survey where research_group_student.research_group_id=" + groupID + " AND research_group_project.research_group_id=" + groupID + " AND research_group_student.student_id=student.id AND survey.student_id=student.id AND survey.project_id=1 AND NOT(survey.presurvey);");
                     if(rs.next()) {
                         countStudents=rs.getInt("count");

                      }
                      if (countStudents > 0) {
                            response.sendRedirect(
                            response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab/cosmic/showStudents.jsp"));
                            }
                       else
                            {                
                            response.sendRedirect(
                            response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab/cosmic/first.jsp"));
                            }
            } else {
                response.sendRedirect(
                        response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab"+prevPage));
            }
            return;
        }
    }
}
%>
<html>
<head>
<title>Login to Cosmic Application</title>
</head>

<BODY>
        <table bgcolor=000000 width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr bgcolor=000000>
            <td rowspan="2" bgcolor=000000>
                <img src="graphics/blast.jpg" width=57 height=68 border=0>
            </td>
        <td bgcolor=000000 align="left">
            <font color=FFFFFF face=arial size=+3>Cosmic Ray e-Lab</font>
        </td>
     </tr>
  </table><P>
<center>
<TABLE WIDTH=500 BGCOLOR=FFFFFF>
    <TR><TD>
    <TABLE  WIDTH=500 CELLPADDING=4>
       <TR>
       <TR>
           <TD align=center BGCOLOR=99cccc>
           <FONT FACE=ARIAL SIZE=+1><B>
Please log in to proceed. </B></font>
           </TD>
       <TR>
    </TABLE>
<%
        if(incorrectLogin){
            warn(out, "<P>Incorrect username or password.");
        }
%>
        <TABLE align = center BORDER=0 WIDTH=500 CELLPADDING=4 VALIGN=TOP>
            <TR>

                <TD align=center>
                    <table CELLPADDING=0 CELLSPACING=0  VALIGN=TOP><tr><td>
                                <br>
                                <FORM method="post">
                                    <TABLE border= 0 cellpadding=2 cellspacing=10>
                                        <TR>
                                            <TD align=right><FONT color="black" face="ariel">Username: </FONT></TD>
                                            <TD><input size="16" type="text" name="user" tabindex="1"></TD>
                                        </TR>
                                        <TR>
                                            <TD align=right><FONT color="black" face="ariel">Password: </FONT></TD>
                                            <TD><INPUT size="16" type="password" name="pass" tabindex="2"></TD>
                                        </TR>
                                        <TR>
                                            <TD></TD><TD><INPUT type="submit" name="login" class="button2" value='Login' tabindex=\ "3"></TD>
                                        </TR>
                                    </TABLE>
                                </FORM>
                    </td></tr></table>
                    <TR>
                        <td align="center" colspan=3><font align="center" face="ariel"><a href=login.jsp?prevPage=<%=prevPage%>&user=guest&pass=guest>Login as guest</a></font></td>
                    </TR>
                </td>
            </tr>
        </table>
</BODY>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</HTML>
