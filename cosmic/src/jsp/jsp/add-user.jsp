<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ include file="common.jsp" %>

<html>
<body>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<center>
<p>
<table width=700 cellpadding=4>
    <tr>
        <td bgcolor="#0a5ca6"> 
            <font color=ffffff>
                <b>
                    Add a new user
                </b>
            </font> 
        </td>
    </tr> 
</table>
<p>

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

                        out.write("<tr><td>Username</td><td>");
                        String newUser = request.getParameter("newUser");
                        if(newUser == null){
                            out.write("<input type=\"text\" name=\"newUser\" value=\"\" size=\"20\" maxlength=\"30\">\n");
                        }
                        else{
                            if(!newUser.matches("^[a-zA-Z0-9-_\\.]+$")){
                                warn(out, "Username must be alphanumeric (underscore, dash, and period characters are ok too)");
                                error = true;
                            }
                            else{
                                out.write(newUser);
                            }
                        }
                        out.write("</td></tr>");

                        String passwd1 = request.getParameter("passwd1");
                        String passwd2 = request.getParameter("passwd2");
                        if(passwd1 == null && passwd2 == null){
                            %>
                                <tr><td>Password</td><td><input type="password" name="passwd1" size="10" maxlength="10"></td></tr>
                                <tr><td>Verify Password</td><td><input type="password" name="passwd2" size="10" maxlength="10"></td></tr>
                                <%
                        }
                        else{
                            out.write("<tr><td>Password</td><td>");
                            if(passwd1 != null && passwd1.equals("")){
                                warn(out, "Please enter a password");
                                error = true;
                            }
                            else if(!passwd1.equals(passwd2)){
                                warn(out, "Your passwords do not match!");
                                error = true;
                            }
                            else if(passwd1.matches(".*[\"'\\(\\)*].*")){
                                warn(out, "Please do not enter a password with any characters: *\"()'");
                                error = true;
                            }
                            else{
                                //output *** for the newUser's password
                                out.write(passwd1.replaceAll(".", "\\*") + "</td></tr>");
                            }

                            out.write("<tr><td>Verification</td><td>");
                            if(passwd2 != null && passwd2.equals("")){
                                warn(out, "Please enter a password verification");
                                error = true;
                            }
                            else if(!passwd1.equals(passwd2)){
                                warn(out, "Your passwords do not match!");
                                error = true;
                            }
                            else if(passwd2.matches(".*[\"'\\(\\)*].*")){
                                warn(out, "Please do not enter a password with any characters: *\"()'");
                                error = true;
                            }
                            else{
                                //output *** for the newUser's password
                                out.write(passwd2.replaceAll(".", "\\*") + "</td></tr>");
                            }
                        }

                        out.write("<tr><td>Role</td><td>");
                        String role = request.getParameter("role");
                        if(role == null){
%>
                            <select name="role">
                                <option value="user">user</option>
                                <option value="admin">admin</option>
                                <option value="super">super</option>
                            </select>
<%
                        }
                        else{
                            if(!role.matches("^[a-zA-Z0-9]+$")){
                                warn(out, "A role must be alphanumeric");
                                error = true;
                            }
                            else{
                                out.write(role);
                            }
                        }
                        out.write("</td></tr>");

                        String teacher = request.getParameter("teacher");
                        if(teacher == null){
                            out.write("<tr><td><font size=\"2\">(Optional)</font> Associated Teacher name</td><td>");
                            out.write("<input type=\"text\" name=\"teacher\" value=\"\" size=\"20\" maxlength=\"30\"></td></tr>\n");
                        }
                        else{
                            if(teacher.equals("")){
                                ;
                            }
                            else{
                                out.write("<tr><td>Teacher name</td><td>");
                                if(!teacher.matches("^[a-zA-Z0-9-_\\.]+$")){
                                    warn(out, "Teacher's name must be alphanumeric<br> (underscore, dash, and period characters are ok too)");
                                    error = true;
                                }
                                else{
                                    out.write(teacher);
                                }
                                out.write("</td></tr>");
                            }
                        }

                        String userarea = request.getParameter("userarea");
                        if(userarea == null){
                            out.write("<tr><td><font size=\"2\">(Optional)</font> UserArea Directory<br><font size=\"2\">e.g. AY2004/IL/Chicago/UofC/Physics7/group2</font></td><td>");
                            out.write("<input type=\"text\" name=\"userarea\" value=\"\" size=\"20\" maxlength=\"30\"></td></tr>\n");
                        }
                        else{
                            if(userarea.equals("")){
                                ;
                            }
                            else{
                                out.write("<tr><td>UserArea</td><td>");
                                if(!userarea.matches("^[a-zA-Z0-9-_/]+$")){
                                    warn(out, "UserArea must be alphanumeric<br> (underscore, dash, and / characters are ok too)");
                                    error = true;
                                }
                                else{
                                    out.write(userarea);
                                }
                                out.write("</td></tr>");
                            }
                        }

                        String ay = request.getParameter("ay");
                        if(ay == null){
                            out.write("<tr><td><font size=\"2\">(Optional)</font> Acedemic Year<br><font size=\"2\">e.g. AY2004</font></td><td>");
                            out.write("<input type=\"text\" name=\"ay\" value=\"\" size=\"20\" maxlength=\"30\"></td></tr>\n");
                        }
                        else{
                            if(ay.equals("")){
                                ;
                            }
                            else{
                                out.write("<tr><td>Acedemic Year</td><td>");
                                if(!ay.matches("^AY[0-9]{4}$")){
                                    warn(out, "Acedemic year must be in the form:<br> \"AYyyyy\" where yyyy is the 4-digit year");
                                    error = true;
                                }
                                else{
                                    out.write(ay);
                                }
                                out.write("</td></tr>");
                            }
                        }

                        String survey = request.getParameter("survey");
                        if(survey == null){
                            out.write("<tr><td><font size=\"2\">(Optional)</font> In Survey<br><font size=\"2\">e.g. yes/no</font></td><td>");
                            out.write("<input type=\"text\" name=\"survey\" value=\"\" size=\"20\" maxlength=\"30\"></td></tr>\n");
                        }
                        else{
                            if(survey.equals("")){
                                //survey is a boolean in SQL so it needs a default
                                //survey = "no";
                            }
                            else{
                                out.write("<tr><td>In Survey</td><td>");
                                if(!survey.matches("^(yes)|(no)$")){
                                    warn(out, "In Survey must be either \"yes\" or \"no\".");
                                    error = true;
                                }
                                else{
                                    out.write(survey);
                                }
                                out.write("</td></tr>");
                            }
                        }


                        //if there were no errors, enter into the database
                        if(error == false && submitinfo != null ){
                            int teacher_id=-1;
                            if(!teacher.equals("")){
                                //check to see if the teacher_id is in the database
                                rs = s.executeQuery("SELECT id FROM teacher WHERE Upper(name)=Upper('" + teacher + "');");
                                if(rs.next() != false){
                                    teacher_id = rs.getInt(1);
                                }
                                else{
                                    warn(out, "The teacher you entered is not in the database");
                                    return;
                                }
                            }
                                
                            //check if this exact entry is alreay in the research_group table
                            String SQLtest = "SELECT id from research_group WHERE name='" + newUser + "'";
                                                //if(!(teacher_id == -1)){ SQLtest += " AND teacher_id = '" + teacher_id + "'"; }
                                                //if(!userarea.equals("")){ SQLtest += " AND userarea='" + userarea + "'"; }
                                                //if(!ay.equals("")){ SQLtest += " AND ay='" + ay + "'"; }
                                                //if(!survey.equals("")){ SQLtest += " AND survey='" + survey + "'"; }
                            rs = s.executeQuery(SQLtest);
                            if(rs.next() != false){
                                warn(out, "This user is already in the database. Please choose a different username.");
                                return;
                            }
                            
                            int i=-1;
                            String SQLstatement = "INSERT INTO research_group (name, password, role";
                                                if(!teacher.equals("")){ SQLstatement += ", teacher_id"; }
                                                if(!userarea.equals("")){ SQLstatement += ", userarea"; }
                                                if(!ay.equals("")){ SQLstatement += ", ay"; }
                                                if(!survey.equals("")){ SQLstatement += ", survey"; }
                                                if(!teacher.equals("")){ SQLstatement += ") SELECT "; }
                                                else{ SQLstatement += ") VALUES("; }
                                                SQLstatement += "'" + newUser + "', " +
                                                "'" + passwd1 + "', " +
                                                "'" + role + "'";
                                                if(!teacher.equals("")){ SQLstatement += ", id"; }
                                                if(!userarea.equals("")){ SQLstatement += ", '" + userarea + "'"; }
                                                if(!ay.equals("")){ SQLstatement += ", '" + ay + "'"; }
                                                if(!survey.equals("")){ SQLstatement += ", '" + survey + "'"; }
                                                if(!teacher.equals("")){ SQLstatement += " FROM teacher WHERE name='" + teacher + "'"; }
                                                else{ SQLstatement += ");"; }
                            s.executeQuery("SELECT * FROM research_group;");
                            try{
                                i = s.executeUpdate(SQLstatement);
                            } catch (SQLException se){
                                warn(out, "There was some error entering your info into the research_group table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }
                            if(i == -1){
                                warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                return;
                            }
                            if(i==0){
                                warn(out, "The teacher name you entered is not in the database.\n<br><font size=2 color=brown>DEBUG information: SQLstatement: " + SQLstatement);
                                return;
                            }

                            //done entering info.
                            done = true;
                            out.write("<tr><td><font color=\"green\">Your entry is now in the database!</font></td><td>");
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
                            <a href="data.html">Go back</a>
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
