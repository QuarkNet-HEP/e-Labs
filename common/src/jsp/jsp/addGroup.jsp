<%@ page import="java.util.regex.*" %>
<%@ page import="java.util.Calendar.*" %>
<%@ page import="java.util.GregorianCalendar.*" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<jsp:include page="../include/elab.jsp"/>
<%@ include file="../login/teacher-login-required.jsp" %>
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

    		<h1>Input the information for your new group or teacher.</h1>

    		<table width="740" border="1">
    		    <form name="myform" method="post" action="">
    		        <tr>
    		        	<td>
    						<center>
    						<table>
    						<th><td colspan="3">States includes states from the U.S., provinces from Canada, and countries.  When registering countries other than Canada and the U.S., use the country name for state and these three letter
    						<e:popup href="../jsp/abbrev.jsp" target="abbrev" width="400" height="700">abbreviations</e:popup>.</td></th>
<%
                                //must be a teacher/leader to input a new group
                                boolean done = false;   //set true when the database update is complete

                                out.write("<tr><td>State or Country</td><td>");
                                String state = request.getParameter("state");
                                String stateNew = request.getParameter("stateNew");
                                String stateType = request.getParameter("stateType");
                                String stateAbbrev = request.getParameter("stateAbbrev");
                                String state_id = request.getParameter("state_id");
                                String city_id = request.getParameter("city_id");
                                String school = request.getParameter("school");
                                String schoolNew = request.getParameter("schoolNew");
                                String school_id = request.getParameter("school_id");
                                String group = request.getParameter("group");
                                String project = request.getParameter("project");
                                String ay = request.getParameter("ay");
                                String role = request.getParameter("role");
                                String survey = request.getParameter("survey");
                                String detectorString = request.getParameter("detectorString");
                                String[] detectorIDs = new String[100];
                                String passwd1 = request.getParameter("passwd1");
                                String passwd2 = request.getParameter("passwd2");
                                //Allowing entry of a new state in form
                                 if (state == null && stateNew==null){
                                    rs = s.executeQuery("SELECT name,abbreviation from state order by type,name;;");
                                   out.write("<select name=\"state\">");
                                    while(rs.next()){
                                        out.write("<option value=\"" + rs.getString(2) + "\">" + rs.getString(1) + "</option>\n");
                                         }
                                    out.write("</select>\n");

                                        out.write("</td><td align=\"top\"> OR enter a new state/country, abbreviation and state type.");
                                        out.write("<input type=text name=stateNew value=\"\" size=30 maxlength=50> <input type=text name=stateAbbrev value=\"\" size=5 maxlength=3>\n");
                                        out.write("<select name=\"stateType\"><option value=\"0\" selected>Select type</option>\n<option value=\"2\">Province</option>\n<option value=\"3\">Country</option></select>\n");
                                        out.write("</td></tr>");

                                  }
                                else
                                   {
                                    //allow user to input a new state
                                     boolean displayStateEntry=false;
                                     if(stateNew != null && !stateNew.equals("")){
                                            //only allow certain characters
                                          if(!stateNew.matches("[ a-zA-Z\\.-]+")){
                                                warn(out, "Please only use letters, spaces, periods, and dashes for your city.\n");
                                                displayStateEntry=true;
                                             }
                                            //see if the state is already in the database
                                          // String qq1 = "SELECT state.name FROM state WHERE Upper(state.name)=Upper('" + stateNew + "');";
                                          // out.write("query1="+qq1);
                                           rs = s.executeQuery("SELECT state.name FROM state WHERE Upper(state.name)=Upper('" + stateNew + "');");
                                           if(rs.next() != false){
                                                warn(out, stateNew + " is already in the pull-down list.\n");
                                                displayStateEntry=true;
                                            }
                                           // Make sure they entered an abbreviation for the new state of country
                                           if(stateAbbrev==null || stateAbbrev.equals("")){
                                             warn(out, "Please enter an abbreviation for the state/country.\n");
                                                displayStateEntry=true;
                                             }
                                           // Make sure they entered an abbreviation for the new state of country
                                           if(stateType==null || stateType.equals("0")){
                                             warn(out, "Please enter a state type for the state/country.\n");
                                                displayStateEntry=true;
                                             }
                                            //see if the abbreviation is already in the database
                                           // String qq2="SELECT state.abbreviation FROM state WHERE Upper(state.abbreviation)=Upper('" + stateAbbrev + "');";
                                          //  out.write(qq2);
                                            rs = s.executeQuery("SELECT state.abbreviation FROM state WHERE Upper(state.abbreviation)=Upper('" + stateAbbrev + "');");
                                           if(rs.next() != false){
                                                warn(out, "State abbreviation " + stateAbbrev + " is already in the pull-down list.\n");
                                                displayStateEntry=true;
                                            }
                                            if (displayStateEntry)
                                            {                                        
                                              out.write("</td><td align=\"top\">Enter a new state/country, abbreviation, and state type.");
                                              out.write("<input type=text name=stateNew value=\""+stateNew+"\" size=30 maxlength=50> <input type=text name=stateAbbrev value=\""+stateAbbrev+"\" size=5 maxlength=3>\n");
                                              out.write("<select name=\"stateType\">");
                                              out.write("<option value=\"0\"");
                                              if (stateType.equals("0")) out.write(" selected");
                                              out.write(">Select type</option>\n");
                                              out.write("<option value=\"2\"");
                                              if (stateType.equals("2")) out.write(" selected");
                                              out.write(">Province</option>\n");
                                              out.write("<option value=\"3\"");
                                              if (stateType.equals("3")) out.write(" selected");
                                              out.write(">Country</option>\n");
                                               out.write("</select>\n");
                                              out.write("<input type=\"submit\" name=\"submitinfo\" value=\"Submit\">");
                                              out.write("</td></tr>");
 
                                              return;
                                              }
                                            //else add the new state
                                            int i=0;
                                            String insertQuery= "INSERT INTO state (name,abbreviation,type) VALUES ( Upper('" + stateNew + "') ,Upper('"+stateAbbrev+"'),"+stateType+");";
                                            i = s.executeUpdate(insertQuery);
                                           if(i != 1){
                                                warn(out, "Weren't able to add a state/country to the database! " + i + " rows updated. Please alert the database admin.");
                                                return;
                                           }
                                            state = stateAbbrev;  // the state abbrevation is what gets passed.
                                        }
                                   if(state==null || state.equals("")){
                                        warn(out, "Please enter a state/country.");
                                        return;
                                   }
                                    out.write(state);
                                    out.write("<input type=\"hidden\" name=\"state\" value=\"" + state +"\">\n");
                                 }
 
 
                               
                                String city = request.getParameter("city");
                                String cityNew = request.getParameter("cityNew");
                                if(state != null){
                                
                                    //  LQ added passing state_id once we one. Aug. 10, 2006
                                  if (state_id==null)  // get state_id if it has not been passed.
                                 {
                                         rs = s.executeQuery("SELECT id FROM state WHERE state.abbreviation='" + state + "';");
                                         if (rs.next()){
                                              state_id=rs.getString(1);
                                         
                                         }
                                         }
                                          out.write("<input type=\"hidden\" name=\"state_id\" value=\"" + state_id + "\">\n");
                                 
                                 
                                    out.write("<tr><td>City</td><td>");
                                    if(city == null && cityNew == null){
                                        rs = s.executeQuery("SELECT city.name FROM city,state WHERE city.state_id=state.id AND state.id='" + state_id + "';");
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
                                            rs = s.executeQuery("SELECT city.name, state.name FROM city, state WHERE Upper(city.name)=Upper('" + cityNew + "') AND city.state_id='" + state_id + "' and city.state_id=state.id;");
                                            if(rs.next() != false){
                                                warn(out, cityNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new city
                                            int i=0;
                                            i = s.executeUpdate("INSERT INTO city (name, state_id) VALUES ( '" + cityNew + "', '"+state_id+"');");
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
                                
                                                                // get city_id if it has no been passed
                                
                                     //  LQ added passing city_id once we one. Aug. 10, 2006
                                 if (city_id==null)  // get city_id if it has not been passed.
                                 {
                                         rs = s.executeQuery("SELECT id FROM city WHERE city.name='"+city + "' and city.state_id='" + state_id + "';");
                                         if (rs.next()){
                                              city_id=rs.getString(1);
                                         
                                             }
                                         }
                                           out.write("<input type=\"hidden\" name=\"city_id\" value=\"" + city_id + "\">\n");
                                    }
                                    out.write("</td></tr>");
                                }
                              
                                
                                
                                
                                        
                                if(city != null){
                                

                                    out.write("<tr><td>School/Institution</td><td>");
                                    if(school == null && schoolNew == null){
                                        // rs = s.executeQuery("SELECT school.name FROM school,city WHERE school.city_id=city.id AND city.name='" + city + "' AND state.abbreviation='" + state + "';");
                                        String schoolQuery="select school.name from school where school.city_id =(select city.id  from city where city.name='" + city + "' AND city.id in ";
                                        schoolQuery=schoolQuery+ "(select id from city where city.state_id= (select id from state where abbreviation='" + state + "')));";
                                       // rs = s.executeQuery("select school.name from school where school.city_id =(select city.id  from city where city.name='" + city + "' 
                                       // AND city.id in (select id from city where city.state_id= (select id from state where abbreviation='" + state + "')));");
                                       rs = s.executeQuery(schoolQuery);
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
                                            if(!schoolNew.matches("[ a-zA-Z0-9\\.-]+")){
                                                warn(out, "Please only use letters, spaces, periods, and dashes for your school.");
                                                return;
                                            }
                                            //see if the school is already in the database
                                            String schoolQuery2 = "SELECT school.name, city.name FROM school,city,state WHERE Upper(school.name)=Upper('" + schoolNew + "') AND school.city_id='" + city_id;
                                            schoolQuery2=schoolQuery2+"' AND school.city_id=city.id and city.state_id=state.id;";
                                            
                                            
                                            rs = s.executeQuery(schoolQuery2);
                                            if(rs.next() != false){
                                                warn(out, schoolNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new school
                                            int i=0;
                                            i = s.executeUpdate("INSERT INTO school (name, city_id) VALUES( '" + schoolNew + "', '" + city_id + "');");
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
                                     //  LQ added passing school_id once we one. Aug. 10, 2006
                                       if (school_id==null)  // get school_id if it has not been passed.
                                       {
                                         rs = s.executeQuery("SELECT school.id FROM school,city WHERE school.name='"+school + "' and school.city_id='" + city_id + "';");
                                         if (rs.next()){
                                              school_id=rs.getString(1);
                                         
                                           }
                                        }
                                          out.write("<input type=\"hidden\" name=\"school_id\" value=\"" + school_id + "\">\n");
  
  
                                    }
                                   out.write("</td></tr>");
                                }

                                 String teacher = request.getParameter("teacher");
                                String teacherNew = request.getParameter("teacherNew");
                                String teacherEmail = request.getParameter("teacherEmail");
                                int teacherId = -1;
                                if(school != null){
                                    out.write("<tr><td>Teacher/Leader</td><td>");
                                    if(teacher == null && teacherNew == null){
                                        rs = s.executeQuery("SELECT teacher.name FROM teacher WHERE teacher.school_id='"+ school_id + "';");
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
                                            String teacherQuery = "SELECT teacher.name, school.name, city.name, state.name FROM teacher, school, city, state WHERE Upper(teacher.name)=Upper('" + teacherNew + "')";
                                            teacherQuery = teacherQuery + " AND school.name='" + school + "' AND city.name='" + city + "' AND state.abbreviation='" + state;
                                            teacherQuery=teacherQuery + "' and teacher.school_id=school.id and school.city_id=city.id and city.state_id=state.id;";
                                            
                                            rs = s.executeQuery(teacherQuery);
                                            if(rs.next() != false){
                                                warn(out, teacherNew + " is already in the pull-down list");
                                                return;
                                            }

                                            //else add the new teacher
                                            int i=0;
                                            rs = s.executeQuery("INSERT INTO teacher (name, email, school_id) VALUES ('" + teacherNew + "', '" + teacherEmail + "',  '" + school_id +"') RETURNING id;");
                                            if(rs.next()) {
                                            	teacherId = rs.getInt(1);
                                            }
                                            else {
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
                                        rs = s.executeQuery("SELECT teacher.email, teacher.id FROM teacher, school, city WHERE Upper(teacher.name)=Upper('" + teacher + "') AND school.name='" + school + "' AND city.id='" + city_id + "';");
                                        if(rs.next() != false){
                                        	teacherId = rs.getInt(2);
                                            teacherEmail = rs.getString(1);
                                        }
                                        else{
                                            warn(out, "Teacher/Leader: " + teacher + " doesn't seem to be in the database (this error should not hsection_id,typeen...");
                                            return;
                                        }
                                        out.write("<tr><td>Teacher's/Leader's Email</td><td>");
                                        out.write(teacherEmail);
                                        out.write("<input type=\"hidden\" name=\"teacherEmail\" value=\"" + teacherEmail +"\">\n");
                                        out.write("</td></tr>");
                                    }
                                }
                                //any characters the filesystem cannot handle must be taken care of
                                if(teacher != null){
                                    out.write("<tr><td>Group Name</td><td>");
                                    if(group == null){
                                        out.write("<input type=text name=group value=\"\" size=30 maxlength=50>\n");
                                    }
                                    else{
                                        if(group.equals("")){
                                            warn(out, "Please go back and enter a group name");
                                            return;
                                        }
                                       //Complain if the user enters non alpha-numeric characters for a group name
                                        Pattern p1 = Pattern.compile("^[a-zA-Z0-9_]+$");
                                        Matcher m1 = p1.matcher(group);
                                        if(!m1.matches()){
                                            warn(out, "Please go back and enter a group name with ONLY alpha-numeric characters.\n<br>Your group: '" + group + "'");
                                            return;
                                        }
                                   //check if this exact entry is alreay in the research_group table
                                    String SQLresearchID = "SELECT id from research_group WHERE " +
                                                        "name='" + group + "';"; //AND " +
                                                        //"userarea='" + newUserArea + "' AND " +
                                                        //"ay='" + ay + "';";
                                    rs = s.executeQuery(SQLresearchID);
                                    if(rs.next() != false){
                                        warn(out, "Your username/groupname is already taken. Please go back and choose a different name.");
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
                                       out.write("<option value=\"" + elabName + "\">" + elabName + "</option>\n");
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
                                    
                                     // Generated a default academic year. LQ - 7-24-06
                                     Calendar calendar = new GregorianCalendar();
                                     int year = calendar.get(Calendar.YEAR);
                                     if (calendar.get(Calendar.MONTH) < 7) {
                                          year=year-1;
                                          }
                                     String longyear = year + "-" + (year+1);
                                     
                                    if(ay != null){
                                        if(ay.equals("")){
                                            warn(out, "Please enter an Academic Year");
                                            return;
                                        }
                                        longyear = ay.substring(2, ay.length());
                                        longyear = longyear + "-" + (Integer.parseInt(longyear)+1);
                                        %>

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
              
                                       <option value="AY<%=year%>"><%=longyear%></option>
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
                                            warn(out, "Please go back and enter a role");
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
                                            warn(out, "Please go back and enter a detector (or detectors) as a comma delimited list");
                                            return;
                                        }

                                        //check to see is this detector-group pair is in the database
                                        detectorIDs = detectorString.replaceAll("\\s", "").split(",", 100);
                                        for(int j=0; j<detectorIDs.length; j++){
                                            String SQLstatement = "SELECT detectorid FROM research_group_detectorid,research_group WHERE Upper(research_group.name)=Upper('" + group + "') ";
                                            SQLstatement = SQLstatement + "AND detectorid='" + detectorIDs[j] + "';";
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
                                            warn(out, "Go back - Your passwords do not match!");
                                            return;
                                        }
                                        
                                        if(passwd1 != null && passwd1.equals("")){
                                            warn(out, "Please go back and enter a password");
 %>
                                        <tr><td>Password</td><td><input type="password" name="passwd1" size="10" maxlength="10"></td></tr>
                                        <tr><td>Verify Password</td><td><input type="password" name="passwd2" size="10" maxlength="10"></td></tr>
<%
                                           return;
                                        }

                                        if(passwd2 != null && passwd2.equals("")){
                                            warn(out, "Please go back and enter a password verification");
 %>
                                        <tr><td>Password</td><td><input type="password" name="passwd1" size="10" maxlength="10"></td></tr>
                                        <tr><td>Verify Password</td><td><input type="password" name="passwd2" size="10" maxlength="10"></td></tr>
<%
                                           return;
                                        }

                                        if(passwd1.matches(".*[\"'\\(\\)*].*")){
                                            warn(out, "Please go back and do not enter a password with any characters: *\"()'");
                                            return;
                                        }

                                        //output *** for the user's password
                                        out.write("<tr><td>Password</td><td>" + passwd1.replaceAll(".", "\\*") + "</td></tr>");
                                        out.write("<tr><td>Verification</td><td>" + passwd2.replaceAll(".", "\\*") + "</td></tr>");
                                    }
                                }
                                   
                                   if(group != null && project != null && ay != null && role != null && survey != null && passwd1 != null && passwd2 !=null){
                                    //create any new directories that are needed 
                                    // Why are these directories set up before the test to see if the name and password is taken? LQ 7/25/06
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
                                    String currDir = home + "/" + project + "/users"; 
                                    File newDir;
                                    for(int i=0; i<7; i++){
                                        currDir = currDir + "/" + newDirsArray[i].replaceAll(" ", "_"); //replace spaces with underscores for the directory name
                                        //out.write("currDir = " + currDir+ "\n");
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

                                    //setup subdirectories - Note that users is actually a symlink to  users -> /export/d1/quarknet/portal/users
                                    // Each e-Lab will need a similar symlink.
                                                                       
                                    String[] newSubdirsArray = new String[] {"plots", "posters", "scratch"};
                                    for(int i=0; i<3; i++){
                                        currDir = home + "/" +project+"/users/" + newUserArea + "/" + project + "/" + newSubdirsArray[i];
                                       //  out.write("currDir = " + currDir+ "\n");
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
                                    // moved code to check that research_group does not already exist from here to earlier part  LQ
  

 
                                    //add the new registration information to research_group
                                    int i=0;
                                    int researchGroupId = -1;
                                    String SQLstatement = "INSERT INTO research_group (name, password, teacher_id, role, userarea, ay, survey) SELECT " +
                                                            "'" + group + "', " +
                                                            "'" + passwd1 + "', " +
                                                            "id, " +
                                                            "'" + role + "', " +
                                                            "'" + newUserArea + "', " + 
                                                            "'" + ay + "', " +
                                                            "'" + survey + "'" +
                                                            "FROM teacher WHERE teacher.id ='" + teacherId + "' RETURNING research_group.id;";
                                    try{
                                        rs = s.executeQuery(SQLstatement);
                                    } catch (SQLException se){
                                        warn(out, "There was some error entering your info into the research_group table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                        return;
                                    }
                                    if(rs.next()){
                                    	researchGroupId = rs.getInt(1);
                                    }
                                    else {
                                        warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + SQLstatement);
                                        return;
                                    }
                                    //add the new group-project pair to research_group_project
                                    i=0;
                                    SQLstatement = "INSERT INTO research_group_project " +
                                                    "SELECT '" + researchGroupId + "', project.id " +
                                                    "FROM project " + 
                                                    "WHERE project.name='" + project + "';";
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
                                                "VALUES ('" + detectorIDs[j] + "', '" + researchGroupId + "');";
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
                                        If you wish to add students to your group (who must complete the survey), return to the <a href="../login/logout.jsp">Registration Page</a> and login with your new group name.<br>
<%
                                    }
                                    else if (role.equals("teacher")) {
%>
                                        You may add <a
                                        href="../login/login.jsp?user=<%=group%>&pass=<%=passwd1%>&project=<%=project%>">teachers or
                                        research groups</a> as a teacher with logon group 
                                        <%=group%>.
<%
                                    }
                                    else{
%>
                                        <font color="red">Please <a href="../login/logout.jsp">logout</a> and log back in (with your new name) before doing your analysis!
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
