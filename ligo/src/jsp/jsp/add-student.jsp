<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ include file="common.jsp" %>

<html>
<head>
        <title>Add a New Student</title>
</head>
<body>
<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>


<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>


<p>
<table width=700 cellpadding=4>
    <tr>
        <td bgcolor="#0a5ca6"> 
            <font color=ffffff>
                <b>
                    Add a new student
                </b>
            </font> 
        </td>
    </tr> 
</table>
<p>

<%
//must be a teacher/leader to input a new group
if(!((String)session.getAttribute("role")).equals("teacher")){
    warn(out, "You must be logged in as a Teacher/Leader to add students.");
    out.write("<br><font size=2>User/Group: <i>" + user + "</i> does not have permission to add students.</font>");
    out.write("<br>Please <a href=logout.jsp>Logout</a> and then log back in with the teacher login to add students.");
    return;
}
String SQLstatement = "SELECT ";
%>
<table width="600" border="1">
    <form method="post" action="">
        <tr>
            <td>
                <center>
                    <table>
<%
                        String submitinfo = request.getParameter("submitinfo");
                        boolean error = false;  //set true only if there's an error somewhere in the entries before the database insertion
                        boolean done = false;   //set true when the database update is complete

                        out.write("<tr><td>Student Name</td><td>");
                        String student = request.getParameter("student");
                        if(student == null){
                            error = false;      //to prevent the "null" student from being added
                            out.write("<input type=\"text\" name=\"student\" value=\"\" size=\"20\" maxlength=\"30\"> e.g. Tom Jordan = tjordan\n");
                        }
                        else{
                            out.write(student);
                        }
                        out.write("</td></tr>");


                        //teacher and group name are from session variables
                        out.write("<tr><td>Teacher name</td><td>" + groupTeacher + "</td></tr>\n");
                        String group = request.getParameter("chooseGroup");
                        out.write("<tr><td>Group name</td><td>");
                        if (group == null) {
%>
                        <form name="groupChooser" method="post" action="">
                            <select name="chooseGroup">
<%
                                // We can do this because the user is teacher for sure,
                                // it is checked above.
                                String query =
                                    "SELECT id, name FROM research_group " +
                                    "WHERE teacher_id IN (SELECT teacher_id " +
                                    "FROM research_group WHERE name = \'" + user + "\') " +
                                    "ORDER BY id DESC";
                                rs = s.executeQuery(query);
                                while (rs.next()) {
                                    String gn = rs.getString("name");
                                    out.write("<option value=\"" + gn + "\">" + 
                                        gn + "</option>");
                                }
                                out.write("</td></tr>\n");
%>
                            </select>
<%
                        }
                        else {                     
                            if (group == "null") {
                                out.write("<font color=\"red\">You must select a group.</font>");
                                error = true;
                            } else {
                                out.write(group + "</td></tr>\n");
                            }
                        }

                        //if there were no errors, enter into the database
                        if(error == false && submitinfo != null ){
                            int group_id=-1;
                            boolean group_survey=false;
                            //grab the group id and survey boolean
                            rs = s.executeQuery("SELECT id,survey FROM research_group WHERE Upper(name)=Upper('" + group + "');");
                            if(rs.next() != false){
                                group_id = rs.getInt(1);
                                group_survey = rs.getBoolean(2);
                            }
                            else{
                                warn(out, "Your group doesn't seem to be in the database (this error should never happen...");
                                return;
                            }
                                
                            //check if this exact entry is alreay in the student table
                            String SQLtest = "SELECT id from student WHERE Upper(name)=Upper('" + student + "')";
                            rs = s.executeQuery(SQLtest);
                            if(rs.next() != false){
                                warn(out, student + " is already in the database. Please choose a different name.");
                                return;
                            }
                            
                            //add the student to the student table
                            int i=-1;
                            SQLstatement = "INSERT INTO student (name) VALUES('" + student + "');";
                            try{
                                i = s.executeUpdate(SQLstatement);
                            } catch (SQLException se){
                                warn(out, "There was some error entering your info into the student table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }
                            if(i == -1 || i == 0){
                                warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }


                            //add the student-researth_group pair to the research_group_student table
                            i=-1;
                            SQLstatement = "INSERT INTO research_group_student (research_group_id, student_id) " + 
                                            "SELECT '" + group_id + "', student.id FROM student " + 
                                            "WHERE student.name='" + student + "';";
                            try{
                                i = s.executeUpdate(SQLstatement);
                            } catch (SQLException se){
                                warn(out, "There was some error entering your info into the research_group_student table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }
                            if(i == -1 || i == 0){
                                warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }

                            //if this group is in a survey...
                            if(group_survey == true){
                                //insert student into the survey table
                                i=-1;
                                SQLstatement = "INSERT INTO survey (student_id, project_id) " + 
                                    "SELECT student.id, research_group_project.project_id FROM student, research_group_project " + 
                                    "WHERE student.name='" + student + "' AND research_group_project.research_group_id='" + group_id + "';";
                                try{
                                    i = s.executeUpdate(SQLstatement);
                                } catch (SQLException se){
                                    warn(out, "There was some error entering your info into the survey table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                    return;
                                }
                                if(i == -1 || i == 0){
                                    warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                    return;
                                }
                            }

                            //done entering info.
                            done = true;
                            out.write("<tr><td><font color=\"green\">You have successfully added your student!</font></td><td>");
                        }

%>

    					</table>
                    </center>
                </td>
            </tr>
            <tr>
                <table>
                    <tr>
                        <td align="center">
<%
                            if(done){
%>
                                <a href="logout.jsp">Done adding students (logout)</a>
                                <br>
                                <a href="addStudent.jsp">Add more students</a>
<%
                            }
                            else{
%>
                                <input type="submit" name="submitinfo" value="Submit">
<%
                            }
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
                        </td>
                    </tr>
                </table>
            </tr>
        </form>
    </table>
</center>
    </body>
</html>
