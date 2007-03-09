<%@ page import="java.util.regex.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Add Users</title>
    </head>
    <body>
        <center>

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
                        		Input the information for your new group or teacher.
                    		</b>
                		</font> 
            		</td>
        		</tr> 
    		</table>
    		<p>

    		<table width="680" border="1">
    		    <form name="myform" method="post" action="">
    		        <tr>
    		        	<td>
    						<center>
    						<table>
<%
                                //must be a teacher/leader to input a new group
                                if(!((String)session.getAttribute("role")).equals("teacher")){
                                    warn(out, "You must be logged in as a Teacher/Leader to add groups.");
                                    out.write("<br><font size=2>User/Group: <i>" + user + "</i> does not have permission to add a group.</font>");
                                    out.write("<br>Please <a href=logout.jsp>Logout</a> and then log back in with the teacher login to add a new group");
                                    return;
                                }
                                boolean done = false;   //set true when the database update is complete

                                out.write("<tr><td>State</td><td>");
                                String state = request.getParameter("state");
                                if(state == null){
                                    rs = s.executeQuery("SELECT name,abbreviation from state");
                                    out.write("<select name=\"state\">");
                                    while(rs.next()){
                                        out.write("<option value=\"" + rs.getString(2) + "\">" + rs.getString(1) + "</option>\n");
                                    }
                                    out.write("</select>\n");
                                }
                                else{
                                    if(state.equals("")){
                                        warn(out, "Please enter a state");
                                        return;
                                    }
                                    out.write(state);
                                    out.write("<input type=\"hidden\" name=\"state\" value=\"" + state +"\">\n");
                                }
                                out.write("</td></tr>");
                                
                                String city = request.getParameter("city");
                                String cityNew = request.getParameter("cityNew");
                                if(state != null){
                                    out.write("<tr><td>City</td><td>");
                                    if(city == null && cityNew == null){
                                        rs = s.executeQuery("SELECT city.name FROM city,state WHERE city.state_id=state.id AND state.abbreviation='" + state + "';");
                                        out.write("<select name=\"city\">");
                                        while(rs.next()){
                                            out.write("<option value=\"" + rs.getString(1) + "\">" + rs.getString(1) + "</option>\n");
                                        }
                                        out.write("</select>\n");

                                        out.write("</td><td>OR enter a new city");
                                        out.write("<input type=text name=cityNew value=\"\" size=30 maxlength=50>\n");
                                        out.write("</td></tr>");
                                    }
                                    else{
                                        //user input a new city
                                        if(cityNew != null && !cityNew.equals("")){
                                            //only allow certain characters
                                            if(!cityNew.matches("[ a-zA-Z\\.-]+")){
                                                warn(out, "Please only use letters, spaces, periods, and dashes for your city.");
                                                return;
                                            }
                                            //see if the city is already in the database
                                            rs = s.executeQuery("SELECT city.name, state.name FROM city, state WHERE Upper(city.name)=Upper('" + cityNew + "') AND state.abbreviation='" + state + "';");
                                            if(rs.next() != false){
                                                warn(out, cityNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new city
                                            int i=0;
                                            i = s.executeUpdate("INSERT INTO city (name, state_id) SELECT '" + cityNew + "', id FROM state WHERE abbreviation='" + state + "';");
                                            if(i != 1){
                                                warn(out, "Weren't able to add a city to the database! " + i + " rows updated. Please alert the database admin.");
                                                return;
                                            }
                                            city = cityNew;
                                        }
                                        if(city == null || city.equals("")){
                                            warn(out, "Please enter a city");
                                            return;
                                        }
                                        out.write(city);
                                        out.write("<input type=\"hidden\" name=\"city\" value=\"" + city +"\">\n");
                                    }
                                    out.write("</td></tr>");
                                }
                                
                                        
                                String school = request.getParameter("school");
                                String schoolNew = request.getParameter("schoolNew");
                                if(city != null){
                                    out.write("<tr><td>School/Institution</td><td>");
                                    if(school == null && schoolNew == null){
                                       rs = s.executeQuery("SELECT school.name FROM school,city,state WHERE school.city_id=city.id AND city.state_id = state.id AND city.name='" + city + "' AND state.abbreviation='" + state + "';");
                                        out.write("<select name=\"school\">");
                                        while(rs.next()){
                                            out.write("<option value=\"" + rs.getString(1) + "\">" + rs.getString(1) + "</option>\n");
                                        }
                                        out.write("</select>\n");
                                        out.write("</td><td>OR enter a new school/institution");
                                        out.write("<input type=text name=schoolNew value=\"\" size=30 maxlength=50>\n");
                                        out.write("</td></tr>");
                                    }
                                    else{
                                        //user input a new school
                                        if(schoolNew != null && !schoolNew.equals("")){
                                            //only allow certain characters
                                            if(!schoolNew.matches("[ a-zA-Z\\.-]+")){
                                                warn(out, "Please only use letters, spaces, periods, and dashes for your school.");
                                                return;
                                            }
                                            //see if the school is already in the database
                                            rs = s.executeQuery("SELECT school.name, city.name, state.name FROM school, city, state WHERE Upper(school.name)=Upper('" + schoolNew + "') AND city.name='" + city + "' AND state.abbreviation='" + state + "';");
                                            if(rs.next() != false){
                                                warn(out, schoolNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new school
                                            int i=0;
                                            i = s.executeUpdate("INSERT INTO school (name, city_id) SELECT '" + schoolNew + "', id FROM city WHERE name='" + city + "';");
                                            if(i != 1){
                                                warn(out, "Weren't able to add a school to the database! " + i + " rows updated. Please alert the database admin.");
                                                return;
                                            }
                                            school = schoolNew;
                                        }
                                        if(school == null || school.equals("")){
                                            warn(out, "Please enter a school");
                                            return;
                                        }
                                        out.write(school);
                                        out.write("<input type=\"hidden\" name=\"school\" value=\"" + school +"\">\n");
                                    }
                                    out.write("</td></tr>");
                                }

                                String teacher = request.getParameter("teacher");
                                String teacherNew = request.getParameter("teacherNew");
                                String teacherEmail = request.getParameter("teacherEmail");
                                if(school != null){
                                    out.write("<tr><td>Teacher/Leader</td><td>");
                                    if(teacher == null && teacherNew == null){
                                        rs = s.executeQuery("SELECT teacher.name FROM teacher,school WHERE teacher.school_id=school.id AND school.name='" + school + "';");
                                        out.write("<select name=\"teacher\">");
                                        while(rs.next()){
                                            out.write("<option value=\"" + rs.getString(1) + "\">" + rs.getString(1) + "</option>\n");
                                        }
                                        out.write("</select>\n");
                                        out.write("</td><td>OR enter a new teacher/leader");
                                        out.write("<input type=text name=teacherNew value=\"\" size=30 maxlength=50>\n");
                                        out.write("</td></tr>");
                                        out.write("<tr><td>Teacher's/Leader's Email</td><td>");
                                        out.write("(if entering a new Teacher/Leader)</td><td><input type=text name=teacherEmail value=\"\" size=30 maxlength=50>\n");
                                        out.write("</td></tr>");
                                    }
                                    else{
                                        //user input a new teacher
                                        if(teacherNew != null && !teacherNew.equals("")){
                                            if(!teacherNew.matches("[ a-zA-Z\\.-_']+")){
                                                warn(out, "Please only use letters, spaces, periods, and dashes for your teacher.");
                                                return;
                                            }
                                            teacherNew = teacherNew.replaceAll("'", "\\\\'");
                                            //see if the teacher is already in the database
                                            rs = s.executeQuery("SELECT teacher.name, school.name, city.name, state.name FROM teacher, school, city, state WHERE Upper(teacher.name)=Upper('" + teacherNew + "') AND school.name='" + school + "' AND city.name='" + city + "' AND state.abbreviation='" + state + "';");
                                            if(rs.next() != false){
                                                warn(out, teacherNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new teacher
                                            int i=0;
                                            i = s.executeUpdate("INSERT INTO teacher (name, email, school_id) SELECT '" + teacherNew + "', '" + teacherEmail + "', id FROM school WHERE name='" + school + "';");
                                            if(i != 1){
                                                warn(out, "Weren't able to add a teacher to the database! " + i + " rows updated. Please alert the database admin.");
                                                return;
                                            }
                                            teacher = teacherNew;
                                        }
                                        if(teacher == null || teacher.equals("")){
                                            warn(out, "Please enter the teacher's name");
                                            return;
                                        }
                                        out.write(teacher);
                                        out.write("<input type=\"hidden\" name=\"teacher\" value=\"" + teacher +"\">\n");
                                        out.write("</td></tr>");
                                        //grab the teacher's email from the database (either JUST added, or is there already)
                                        rs = s.executeQuery("SELECT teacher.email FROM teacher, school, city, state WHERE Upper(teacher.name)=Upper('" + teacher + "') AND school.name='" + school + "' AND city.name='" + city + "' AND state.abbreviation='" + state + "';");
                                        if(rs.next() != false){
                                            teacherEmail = rs.getString(1);
                                        }
                                        else{
                                            warn(out, "Teacher/Leader: " + teacher + " doesn't seem to be in the database (this error should not happen...");
                                            return;
                                        }
                                        out.write("<tr><td>Teacher's/Leader's Email</td><td>");
                                        out.write(teacherEmail);
                                        out.write("<input type=\"hidden\" name=\"teacherEmail\" value=\"" + teacherEmail +"\">\n");
                                        out.write("</td></tr>");
                                    }
                                }

                                String group = request.getParameter("group");
                                String project = request.getParameter("project");
                                String ay = request.getParameter("ay");
                                String role = request.getParameter("role");
                                String survey = request.getParameter("survey");
                                String detectorString = request.getParameter("detectorString");
                                String[] detectorIDs = new String[100];
                                String passwd1 = request.getParameter("passwd1");
                                String passwd2 = request.getParameter("passwd2");
                                //any characters the filesystem cannot handle must be taken care of
                                if(teacher != null){
                                    out.write("<tr><td>Group Name</td><td>");
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

                                    out.write("<tr><td>Project</td><td>");
                                    if(project == null){
                                        rs = s.executeQuery("SELECT name FROM project");
                                        out.write("<select name=\"project\">");
                                        while(rs.next()){
                                            out.write("<option value=\"" + rs.getString(1) + "\">" + rs.getString(1) + "</option>\n");
                                        }
                                        out.write("</select>\n");
                                    }
                                    else{
                                        out.write(project);
                                        out.write("<input type=\"hidden\" name=\"project\" value=\"" + project +"\">\n");
                                    }
                                    out.write("</td></tr>");

                                    out.write("<tr><td>Academic Year</td><td>");
                                    out.write("<select name=\"ay\">");
                                    String longyear = "2004-2005";
                                    if(ay != null){
                                        if(ay.equals("")){
                                            warn(out, "Please enter an Academic Year");
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
                                    
                                    out.write("<tr><td>Role</td><td>");
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
                                        <option value="<%=role%>"><%=role%></option>
                                        <option value="user">user</option>
                                        <option value="upload">upload</option>
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
                                    out.write("<tr><td>DAQ Board ID(s)</td><td>");
                                    if(detectorString != null && !detectorString.equals("")){
                                        if(!detectorString.matches("^[0-9]{1,4}(,\\s*[0-9]{1,4})*$")){
                                            warn(out, "Please enter a detector (or detectors) as a comma delimited list");
                                            return;
                                        }

                                        //check to see is this detector-group pair is in the database
                                        detectorIDs = detectorString.replaceAll("\\s", "").split(",", 100);
                                        for(int j=0; j<detectorIDs.length; j++){
                                            String SQLstatement = "SELECT detectorid FROM research_group_detectorid,research_group WHERE Upper(research_group.name)=Upper('" + group + "') AND detectorid='" + detectorIDs[j] + "';";
                                            try{
                                                rs = s.executeQuery(SQLstatement);
                                            } catch (SQLException se){
                                                warn(out, "There was some error entering your info into the research_group table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                                return;
                                            }
                                            if(rs.next() != false){
                                                warn(out, rs.getString(1) + " is already associated with this group");
                                                return;
                                            }
                                        }

                                        out.write(detectorString);
                                    }
                                    else{
                                        out.write("<input type=\"text\" name=\"detectorString\" value=\"\" size=30 maxlength=500>\n");
                                        out.write("<font size=\"2\">e.g. 180,181,182</font>");
                                    }
                                    //out.write("</table></DIV></td></tr>");
                                    out.write("</td></tr>");

                                    out.write("<tr><td>In survey</td><td>");
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
                                        <tr><td>Password</td><td><input type="password" name="passwd1" size="10" maxlength="10"></td></tr>
                                        <tr><td>Verify Password</td><td><input type="password" name="passwd2" size="10" maxlength="10"></td></tr>
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
                                        out.write("<tr><td>Password</td><td>" + passwd1.replaceAll(".", "\\*") + "</td></tr>");
                                        out.write("<tr><td>Verification</td><td>" + passwd2.replaceAll(".", "\\*") + "</td></tr>");
                                    }
                                }

                                if(group != null && project != null && ay != null && role != null && survey != null && passwd1 != null && passwd2 !=null){
                                    //create any new directories that are needed
                                    boolean mkdir, isDirectory;
                                    // directory structure:
                                    // home + users + ay/state/city/school/teacher/group/
                                    String[] newDirsArray = new String[] {
                                        ay, 
                                        state, 
                                        city.replaceAll(" ", "_"), 
                                        school.replaceAll(" ", "_"), 
                                        teacher.replaceAll(" ", "_"), 
                                        group, 
                                        project};
                                    String currDir = home + "/cosmic/users/";
                                    File newDir;
                                    for(int i=0; i<7; i++){
                                        currDir = currDir + "/" + newDirsArray[i].replaceAll(" ", "_"); //replace spaces with underscores for the directory name
                                        newDir = new File(currDir);
                                        try{
                                            isDirectory = newDir.isDirectory();
                                        } catch(SecurityException e){
                                            warn(out, "Security permissions do not allow this directory (" + newDir + ") to be accessed");
                                            return;
                                        }
                                        if(!isDirectory){
                                            mkdir = newDir.mkdir();
                                            if(mkdir == false){
                                                warn(out, "Directory: " + newDir + " couldn't be created! (when trying to add the directory: " + newDirsArray[i] + ")");
                                                return;
                                            }
                                        }
                                        //else if we're adding the group...
                                        else if(i==5){
                                            warn(out, "The group directory: " + newDirsArray[i] + " already exists on the system.\n<br>Use the back button on your browser and enter a different group name.");
                                            return;
                                        }
                                    }
                                    //the newUserArea base dir is now totally setup
                                    String newUserArea = newDirsArray[0] + "/" + newDirsArray[1] + "/" + newDirsArray[2] + "/" + newDirsArray[3] + "/" + newDirsArray[4] + "/" + newDirsArray[5];

                                    //setup subdirectories
                                    String[] newSubdirsArray = new String[] {"plots", "posters", "scratch"};
                                    for(int i=0; i<3; i++){
                                        currDir = home + "/cosmic/users/" + newUserArea + "/" + project + "/" + newSubdirsArray[i];
                                        newDir = new File(currDir);
                                        try{
                                            isDirectory = newDir.isDirectory();
                                        } catch(SecurityException e){
                                            warn(out, "Security permissions do not allow this directory (" + newDir + ") to be accessed");
                                            return;
                                        }
                                        if(!isDirectory){
                                            mkdir = newDir.mkdir();
                                            if(mkdir == false){
                                                warn(out, "Directory: " + newDir + " couldn't be created! (when trying to add the directory: " + newSubdirsArray[i] + ")");
                                                return;
                                            }
                                        }
                                    }


                                    //check if this exact entry is alreay in the research_group table
                                    String SQLresearchID = "SELECT id from research_group WHERE " +
                                                        "name='" + group + "';"; //AND " +
                                                        //"userarea='" + newUserArea + "' AND " +
                                                        //"ay='" + ay + "';";
                                    rs = s.executeQuery(SQLresearchID);
                                    if(rs.next() != false){
                                        warn(out, "Your username/groupname is already taken. Please choose a different name.");
                                        return;
                                    }

                                    //add the new registration information to research_group
                                    int i=0;
                                    String SQLstatement = "INSERT INTO research_group (name, password, teacher_id, role, userarea, ay, survey) SELECT " +
                                                            "'" + group + "', " +
                                                            "'" + passwd1 + "', " +
                                                            "id, " +
                                                            "'" + role + "', " +
                                                            "'" + newUserArea + "', " + 
                                                            "'" + ay + "', " +
                                                            "'" + survey + "'" +
                                                            "FROM teacher WHERE name='" + teacher + "';";
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
                                    //add the new group-project pair to research_group_project
                                    i=0;
                                    SQLstatement = "INSERT INTO research_group_project " +
                                                    "SELECT research_group.id, project.id " +
                                                    "FROM research_group, project " + 
                                                    "WHERE research_group.name='" + group + "' AND project.name='" + project + "';";
                                    i = s.executeUpdate(SQLstatement);
                                    if(i != 1){
                                        warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                        return;
                                    }
                                    //add the new group-detectorID pair(s) to research_group_detectorid (if there are any)
                                    if(detectorString != null && !detectorString.equals("")){
                                        i=0;
                                        for(int j=0; j<detectorIDs.length; j++){
                                            SQLstatement = "INSERT INTO research_group_detectorid (research_group_id, detectorid) " +
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

                                    //done entering info.
                                    done = true;
                                    out.write("<tr><td><font color=\"green\">New group: " + group + " created successfully!</font></td><td>");
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
                                    if(survey.equals("yes")){
%>
                                        If you wish to add students to your group (who must complete the survey), return to the <a href="logout.jsp">Registration Page</a> and login with your new group name.<br>
<%
                                    }
                                    else if (role.equals("teacher")) {
%>
                                        You may add <a
                                        href="login.jsp?user=<%=group%>&pass=<%=passwd1%>">teachers or
                                        research groups</a> as the teacher
                                        <%=group%>.
<%
                                    }
                                    else{
%>
                                        <font color="red">Please <a href="logout.jsp">logout</a> and log back in (with your new name) before doing your analysis!
<%
                                    }
                                }
                                else{
%>
                                    <input type="submit" name="submitinfo" value="Submit">
<%
                                }
%>
    				            </td>
    				        </tr>
    				    </table>
    				</tr>
    		    </form>
    		</table>
		</center>
	</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
