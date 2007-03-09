<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page buffer="64kb" %>

<%@ include file="include/style.css" %>

<%!
public static void warn(JspWriter out, String error){
    try{
        out.write("<font color=red><b>" + error + "</b></font>");
    }
    catch(IOException e){
        ;
    }
}
%>

<!--
Liz Quigg - udated June 2006 to enforce taking pre-test
-->


<%
// Added an additional parameter to login call to support multiple projects- LQ-7/21/06
String project = request.getParameter("project");
if (project == null)  {
     project="cosmic";
     }
String prevPage = request.getParameter("prevPage");
boolean incorrectLogin = false;
// prevPage uses project in its calculation - LQ
if(prevPage == null){    //the page the user was previously requesting
    prevPage = "/" + project+ "/home.jsp";     //default redirect
}
%>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
String user = request.getParameter("user");
String pass = request.getParameter("pass");
if (user != null && pass != null){
    //database lookup of username/password
    rs = s.executeQuery("SELECT id, teacher_id, role, userarea, survey, first_time FROM research_group WHERE " +
                        "name='" + user + "' AND " +
                        "password='" + pass + "';");
    if(rs.next() == false){
        incorrectLogin = true;
    }
    else{
        String groupID = rs.getString("id");
        String teacherID = rs.getString("teacher_id");
        String role = rs.getString("role");
        String userArea = rs.getString("userarea");
        String survey = rs.getString("survey");
        boolean firstTime = rs.getBoolean("first_time");

        //setup derived variables
        String userDir = (String) System.getProperty("portal.users") + userArea;
        String userDirURL = "users/" + userArea;
       // Paul's query look wrong; it should be looking at research_group_project as well as research_group- LQ
       //ResultSet rs2 = s.executeQuery("SELECT project.name FROM project, research_group WHERE research_group.id='" + groupID + "';");
       // We need to see if the current research group is in the research_group_project table.
       // First we want to get the project id for the current project name.  LQ-7/21/06
       ResultSet rs2 = s.executeQuery("SELECT id from project where project.name='"+project+"';") ;
      
        if(rs2.next() == false){
            warn(out, "No such project exists");
            return;
        }
        else
        {
        String projectId = rs2.getString(1);  //  We need the  project id later.  LQ-7/21/06
        // Now look to see if this research goup - project pair is in the research_group_project table.

        rs2 = s.executeQuery("SELECT research_group_project.project_id FROM research_group_project WHERE research_group_project.project_id='" + projectId + " and research_group_project.research_group_id='" + groupID + "';");
      
        if( (rs2.next() == false) && !(role.equals("teacher"))  && !(role.equals("admin")) ){
            warn(out, "Your group is not associated with this project. Contact the person who entered your group into the database and tell them this.");
            return;
        }
        else{
           //  project = rs2.getString(1);  This is left over from Paul's query.  We already know the project name.  LQ-7/21/06

            //set some statistics
            String SQLstatement = 
                "INSERT INTO usage (research_group_id) " +
                "VALUES(" + groupID + ");";
            int i = s.executeUpdate(SQLstatement);
            if(i != 1){
                warn(out, "Weren't able to add statistics info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
            }

            //set attributes
            session.setAttribute("UserName", user);     //TODO
            session.setAttribute("login", user);
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
                                System.getProperty("port") + "/elab/"+ project + "/teacher.jsp"));
                } else {
                    response.sendRedirect(
                            response.encodeRedirectURL(
                                "http://" + System.getProperty("host") + 
                                System.getProperty("port") + "/elab"+prevPage));
                }
            } else if (firstTime || user.equals("guest")) {
                    //check if all the students have taken the test. 
                    int countStudents=0;
                    String countQuery="select count(*) from student,research_group_student,research_group_project,survey where research_group_student.research_group_id=" + groupID + " AND research_group_project.research_group_id=" + groupID + " AND research_group_student.student_id=student.id AND survey.student_id=student.id AND survey.project_id=" + projectId + " AND NOT(survey.presurvey);";
                    out.write("\n Query is "+countQuery);
                   // rs = s.executeQuery(countQuery);
                   //  if(rs.next()) {
                    //     countStudents=rs.getInt("count");

                    //  }
                      if (countStudents > 0) {
                            response.sendRedirect(
                            response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab/" +project + "/showStudents.jsp"));
                            }
                       else
                            {                
                            response.sendRedirect(
                            response.encodeRedirectURL(
                            "http://" + System.getProperty("host") + 
                            System.getProperty("port") + "/elab/" +project + "/first.jsp"));
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
}
%>
<html>
<head>
<title>Login to e-Lab Application</title>
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
                                            <TD><INPUT size="16" type="password" name="pass" tabindex="2"><INPUT type="hidden" name="project" value="cosmic"></TD>
                                        </TR>
                                        <TR>
                                            <TD></TD><TD><INPUT type="submit" name="login" class="button2" value='Login' tabindex=\ "3"></TD>
                                        </TR>
                                    </TABLE>
                                </FORM>
                    </td></tr></table>
                    <TR>
                        <td align="center" colspan=3><font align="center" face="ariel"><a href=login.jsp?prevPage=<%=prevPage%>&user=guest&pass=guest&project=cosmic>Login as guest</a></font></td>
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
