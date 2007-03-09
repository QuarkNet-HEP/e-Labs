<%@ page import="java.util.regex.*" %>
<%@ page import="java.util.Vector" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Update Your Groups</title>
    </head>
    <body>
        <center>


<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>

<%
//start jsp by defining submit
String submit =  request.getParameter("submit");
%>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

    		<p>
    		<table width=700 cellpadding=4>
				<tr>
            		<td bgcolor="#0a5ca6"> 
                		<font color=ffffff>
                    		<b>
                        		Update your groups
                    		</b>
                		</font> 
            		</td>
        		</tr> 
    		</table>
    		<p>
<%
        boolean done = false;   //set true when the database update is complete
        String group = request.getParameter("group");
        String project = request.getParameter("project");
        String ay = request.getParameter("ay");
        String role = request.getParameter("role");
        String survey = request.getParameter("survey");
        String detectorString = request.getParameter("detectorString");
        String[] detectorIDs = new String[100];
        String passwd1 = request.getParameter("passwd1");
        String passwd2 = request.getParameter("passwd2");
        String[] studentsToDelete = request.getParameterValues("deleteStudents");

        //must be a teacher/leader to input a new group
        if(!((String)session.getAttribute("role")).equals("teacher")){
            warn(out, "You must be logged in as a Teacher/Leader to update groups.");
            out.write("<br><font size=2>User/Group: <i>" + user + "</i> does not have permission to update a group.</font>");
            out.write("<br>Please <a href=logout.jsp>Logout</a> and then log back in with the teacher login to update a group");
            return;
        }

        if (submit != null && submit.equals("Update Group Information")) {
            if(group != null && project != null && ay != null && role != null && survey != null && passwd1 != null && passwd2 !=null){
                //add the new registration information to research_group
                int i=0;
                String SQLstatement = 
                    "UPDATE research_group SET password = \'" + passwd1 + "\', " +
                    "role = \'" + role + "\', ay = \'" + ay + "\', " +
                    "survey = \'" + (survey.equals("yes") ? "t" : "f") + "\' " +
                    "WHERE name = \'" + group + "\'";
                try{
                    i = s.executeUpdate(SQLstatement);
                } catch (SQLException se){
                    warn(out, "There was some error entering your info into the research_group table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                    return;
                }
                if(i != 1){
                    warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                    return;
                }
                //add the new group-detectorID pair(s) to research_group_detectorid (if there are any)
                if(detectorString != null && !detectorString.equals("")){
                    i=0;
                    SQLstatement = 
                        "DELETE FROM research_group_detectorid " +
                        "WHERE research_group_id = (" + 
                        "SELECT id FROM research_group WHERE research_group.name = \'" +
                        group + "\')";
                    i = s.executeUpdate(SQLstatement);
                    i = 0;
                    detectorIDs = detectorString.replaceAll("\\s", "").split(",", 100);
                    for(int j=0; j<detectorIDs.length; j++){
                        SQLstatement = 
                            "INSERT INTO research_group_detectorid (research_group_id, detectorid) " +
                            "SELECT id, '" + detectorIDs[j] + "' " +
                            "FROM research_group " +
                            "WHERE research_group.name='" + group + "';";
                        i = s.executeUpdate(SQLstatement);
                        if(i != 1){
                            warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                            return;
                        }
                    }
                }

                if (studentsToDelete != null && studentsToDelete.length != 0) {
                    String pairTable = 
                        "DELETE FROM research_group_student WHERE student_id = ";
                    String studentTable =
                        "DELETE FROM student WHERE id = ";
                   for (int j = 0; j < studentsToDelete.length; j++) {
                       s.executeUpdate(pairTable + studentsToDelete[j]);
                       s.executeUpdate(studentTable + studentsToDelete[j]);
                   }
                }

                //done entering info.
                done = true;
                out.write("<tr><td><font color=\"green\">" + group + " successfully updated!</font></td><td>");
            }
        }

        // Gather data for the user to modify.
        if (submit != null && submit.equals("Show Group Info")) {
            group = request.getParameter("chooseGroup");
            if (group != null && !group.equals("Choose Group")) {
                String query = 
                    "SELECT id, password, role, ay, survey " +
                    "FROM research_group WHERE name = \'" + group + "\'";
                rs = s.executeQuery(query);
                int id = 0;
                if (rs.next()) {
                    id = rs.getInt("id");
                    passwd1 = rs.getString("password");
                    passwd2 = passwd1;
                    ay = rs.getString("ay");
                    role = rs.getString("role");
                    if (rs.getBoolean("survey"))
                        survey = "yes";
                    else
                        survey = "no";
                } else {
                    passwd1 = "";
                    passwd1 = "";
                    ay = "";
                    role = "";
                    survey = "no";
                }

                
                // Get project information for this group.
                query = 
                    "SELECT name FROM project WHERE id IN (" +
                    "SELECT project_id FROM research_group_project " +
                    "WHERE research_group_id = " + id + ")";
                rs = s.executeQuery(query);
                if (rs.next()) {
                    project = rs.getString("name");
                } else {
                    project = "cosmic";
                }
                
                // Get detector string info for this group.
                query =
                    "SELECT detectorid FROM research_group_detectorid " +
                    "WHERE research_group_id = " + id;
                rs = s.executeQuery(query);
                detectorString = "";
                if (rs.next())
                    detectorString += rs.getString("detectorid");
                while (rs.next()) {
                    detectorString += "," + rs.getString("detectorid");
                }
            }
        }
%>
    	    <form name="myform" method="post" action="">
                <select name="chooseGroup">
                    <option value="null">Choose Group</option> 
<%
                    // We can do this because the user is teacher for sure,
                    // it is checked above.
                    String query =
                        "SELECT name, id FROM research_group " +
                        "WHERE teacher_id IN (SELECT teacher_id " +
                        "FROM research_group WHERE name = \'" + user + "\') ORDER BY name ASC";
                    rs = s.executeQuery(query);
                    while (rs.next()) {
                        String gn = rs.getString("name");
                        if (group != null && group.equals(gn))
                            out.write("<option value=\"" + gn + "\" selected>" + 
                                gn + "</option>");
                        else
                            out.write("<option value=\"" + gn + "\">" + gn + "</option>");
                    }
%>
                </select>
                <input type="submit" name="submit" value="Show Group Info">
                <br>
                <br>
<%
                if(group != null){
%>
    		    <table width="680" border="1" bgcolor="#F6F6FF" cellpadding=5>
    		        <tr>
    		        	<td align="center">
    						<center>
    						<table cellpadding=5>
<%

                                //any characters the filesystem cannot handle must be taken care of
                                    out.write("<tr><td align=\"right\">Group Name:</td><td>");
                                    if(group == null){
                                        out.write("<input type=text name=group value=\"\" size=30 maxlength=50>\n");
                                    }
                                    else{
                                        if(group.equals("")){
                                            warn(out, "Please enter a group name");
                                            return;
                                        }
                                        //Complain if the user enters non alpha-numeric characters for a group name
                                        Pattern p1 = Pattern.compile("^[a-zA-Z0-9_]+$");
                                        Matcher m1 = p1.matcher(group);
                                        if(!m1.matches()){
                                            warn(out, "Please enter a group name with ONLY alpha-numeric characters.\n<br>Your group: '" + group + "'");
                                            return;
                                        }
                                        out.write(group);
                                        out.write("<input type=\"hidden\" name=\"group\" value=\"" + group +"\">\n");
                                    }
                                    out.write("</td></tr>");

                                    out.write("<tr><td align=\"right\">Project:</td><td>");
                                    rs = s.executeQuery("SELECT name FROM project");
                                    out.write("<select name=\"project\">");
                                    while(rs.next()){
                                        out.write("<option value=\"" + rs.getString(1) + "\">" + rs.getString(1) + "</option>\n");
                                    }
                                    out.write("</select>\n");
                                    out.write("</td></tr>");

                                    out.write("<tr><td align=\"right\">Academic Year:</td><td>");
                                    String longyear = "2004-2005";
                                    if(ay != null){
                                        if(ay.equals("")){
                                            warn(out, "Please enter an Acedemic Year");
                                            return;
                                        }
                                        longyear = ay.substring(2, ay.length());
                                        longyear = longyear + "-" + (Integer.parseInt(longyear)+1);
%>
                                    <select name="ay">
                                        <option value="<%=ay%>"><%=longyear%></option>
                                        <option value="AY2004">2004-2005</option>
                                        <option value="AY2005">2005-2006</option>
                                        <option value="AY2006">2006-2007</option>
                                        <option value="AY2007">2007-2008</option>
                                    </select>
<%
                                    }
                                    else{
%>
                                        <option value="AY2004">2004-2005</option>
                                        <option value="AY2005">2005-2006</option>
                                        <option value="AY2006">2006-2007</option>
                                        <option value="AY2007">2007-2008</option>
                                    </select>
<%
                                    }
                                    out.write("</td></tr>");
                                    
                                    out.write("<tr><td align=\"right\">Role:</td><td>");
%>
                                    <select name="role" onchange="javascript: var roleIndex1=myform.role.selectedIndex;
                                    if (roleIndex1==1) {
                                        av1.visibility = 'show'; 
                                        av1.style.display = '';
                                    } else {
                                        av1.visibility = 'hide'; 
                                        av1.style.display = 'none';
                                    }
                                    ">
<%
                                    if(role != null){
                                        if(role.equals("")){
                                            warn(out, "Please enter a role");
                                            return;
                                        }
%>
                                        <option value="user" <%if (role.equals("user")) out.write("selected");%>>user</option>
                                        <option value="upload" <%if (role.equals("upload")) out.write("selected");%>>upload</option>
                                        <option value="teacher" <%if (role.equals("teacher")) out.write("selected");%>>teacher</option>
                                    </select>
<%
                                    }
                                    else{
%>
                                        <option value="user">user</option>
                                        <option value="upload">upload</option>
                                    </select>
<%
                                    }
                                    out.write("</td></tr>");

                                    //out.write("<tr><td colspan=2><DIV ID='av1' style=\"visibility:hide;display:none;\"><table align=center>");
                                    //out.write("DAQ ID(s)</td><td>");
                                    out.write("<tr><td align=\"right\">DAQ ID(s):</td><td>");
                                    if(detectorString != null && !detectorString.equals("")){
                                        if(!detectorString.matches("^[0-9]{1,4}(,\\s*[0-9]{1,4})*$")){
                                            warn(out, "Please enter a detector (or detectors) as a comma delimited list");
                                            return;
                                        }

                                        out.write("<input type=\"text\" name=\"detectorString\" value=\"" + detectorString + "\" size=30 maxlength=500>\n");
                                    }
                                    else{
                                        out.write("<input type=\"text\" name=\"detectorString\" value=\"\" size=30 maxlength=500>\n");
                                        out.write("<font size=\"2\">e.g. 180,181,182</font>");
                                    }
                                    //out.write("</table></DIV></td></tr>");
                                    out.write("</td></tr>");

                                    out.write("<tr><td align=\"right\">In survey:</td><td>");
                                    if(survey != null){
                                        if(survey.equals("yes")){
                                            out.write("<input type=\"radio\" name=\"survey\" value=\"no\">No");
                                            out.write("<input type=\"radio\" name=\"survey\" value=\"yes\" checked>Yes");
                                        }
                                        else if(survey.equals("no")){
                                            out.write("<input type=\"radio\" name=\"survey\" value=\"no\" checked>No");
                                            out.write("<input type=\"radio\" name=\"survey\" value=\"yes\">Yes");
                                        }
                                        else{
                                            warn(out, "Please enter if the group needs to take the pre and post surveys or not");
                                            return;
                                        }
                                    }
                                    else{
                                        out.write("<input type=\"radio\" name=\"survey\" value=\"no\" checked>No");
                                        out.write("<input type=\"radio\" name=\"survey\" value=\"yes\">Yes");
                                    }
                                    out.write("</td></tr>");

                                    //out.write("<tr><td>Password</td><td>");
                                    if(passwd1 == null && passwd2 == null){
%>
                                        <tr><td align="right">Password:</td><td><input type="password" name="passwd1" size="10" maxlength="10"></td></tr>
                                         <tr><td align="right">Verify Password:</td><td><input type="password" name="passwd2" size="10" maxlength="10"></td></tr>
<%
                                    }
                                    else{
                                        out.write("<tr><td>");
                                        if(passwd1 != null && passwd2 != null && !passwd1.equals(passwd2)){
                                            warn(out, "Your passwords do not match!");
                                            return;
                                        }
                                        
                                        if(passwd1 != null && passwd1.equals("")){
                                            warn(out, "Please enter a password");
                                            return;
                                        }

                                        if(passwd2 != null && passwd2.equals("")){
                                            warn(out, "Please enter a password verification");
                                            return;
                                        }

                                        if(passwd1.matches(".*[\"'\\(\\)*].*")){
                                            warn(out, "Please do not enter a password with any characters: *\"()'");
                                            return;
                                        }

                                        //output *** for the user's password
                                        out.write("<tr><td align=\"right\">Password:</td><td>" + "<input type=\"password\" name=\"passwd1\" value=\""+ passwd1 + "\" size=\"10\" maxlength\"10\">" + "</td></tr>");
                                        out.write("<tr><td align=\"right\">Verification:</td><td>" + "<input type=\"password\" name=\"passwd2\" value=\""+ passwd2 + "\" size=\"10\" maxlength\"10\">" + "</td></tr>");
                                    }
%>
                                <p>
    				            </td>
    				        </tr>
                            <tr>
                                <td>
                                    Students to delete from <%=group%>:
                                </td>
                                <td>
                                <table cellpadding=3>
<%
                                try {
                                    String studentsQuery = 
                                        "SELECT id, name FROM student WHERE id in (" +
                                        "SELECT student_id FROM research_group_student WHERE research_group_id = (" +
                                        "SELECT id FROM research_group WHERE name = \'" + group + "\'))";
                                    rs = s.executeQuery(studentsQuery);
                                    int i = 0;
                                    while (rs.next()) {
                                        if (i % 3 == 0) {
                                            if (i == 0)
                                                out.write("<tr><td>");
                                            else
                                                out.write("</td><tr><td>");
                                        } else
                                            out.write("</td><td>");
                                        out.write("<input type=checkbox name=deleteStudents value=" + rs.getInt("id") + ">");
                                        out.write(rs.getString("name"));
                                        i++;
                                    }
                                    out.write("</td></tr>");
                                } catch (Exception e) {
                                    out.write("<font color=\"red\">Problem retrieving your students.</font>");
                                    out.flush();
                                }
%>
                                </table>
                                </td>
                            </tr>
    				    </table>
    				</tr>
    		    </table>
                <br>
                <input type="submit" name="submit" value="Update Group Information">
    		</form>
<%
                                }
%>
		</center>
	</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
