<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Update Your Groups</title>
    </head>
    <body>
        <center>


<!-- header/navigation -->
<%
// Updated 8/9/06 LQ to remove e-Lab dependence
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common_t.jsp" %>

<%
//start jsp by defining submit
String submit =  request.getParameter("submit");
String query = "";
HashMap eLabs = new HashMap();
String eLabNam="";
HashMap groupELabs = new HashMap();
int id = 0;  // research group id

%>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
<% 
// make an hash map of the names of all projects
                query = 
                    "SELECT id,name FROM project Order by id DESC";
                rs = s.executeQuery(query);
               // int elabId;
                String elabId;
                while (rs.next()) {
                    elabId = rs.getString(1);
                   // elabId = rs.getString("id");
//                    elabId = rs.getInt("id");
                     eLabNam = rs.getString(2);
                    // out.write(elabId + " " + eLabNam + "\n");
                     eLabs.put(elabId, eLabNam);
                    }
                
 %>

    		<p>
    		<table width=700 cellpadding=4>
				<tr>
            		<td bgcolor="#0a5ca6"> 
                		<font color=ffffff>
                    		<b>
                        		Update the e-Lab Assignment for your groups.
                    		</b>
                		</font> 
            		</td>
        		</tr> 
    		</table>
    		<p>
<%
        boolean done = false;   //set true when the database update is complete
        String group = request.getParameter("group");
//        String project = request.getParameter("project");
        String project = "";
        String role = request.getParameter("role");
        String[] eLabsForGroup = request.getParameterValues("eLabsForGroup");
        id=0;
        //must be a teacher/leader to input a new group
        if(!((String)session.getAttribute("role")).equals("teacher")){
            warn(out, "You must be logged in as a Teacher/Leader to update groups.");
            out.write("<br><font size=2>User/Group: <i>" + user + "</i> does not have permission to update a group.</font>");
            out.write("<br>Please <a href=logout.jsp>Logout</a> and then log back in with the teacher login to update a group");
            return;
        }

        if (submit != null && submit.equals("Update e-Lab Assignments")) {
            group = request.getParameter("chooseGroup");
            if(group != null){
                //add the new e-Lab information to research_group
                // get the name associated with ids
                query = 
                    "SELECT id,userarea " +
                    "FROM research_group WHERE name = \'" + group + "\'";
                rs = s.executeQuery(query);
                String userarea="";
                if (rs.next()) {
                    id = rs.getInt("id");
                    userarea = rs.getString("userarea");
                    }

                if (eLabsForGroup != null && eLabsForGroup.length != 0) {
                  for (int j = 0; j < eLabsForGroup.length; j++) {
                   //out.write("new eLabs are:"+ eLabsForGroup[j]+"\n");
                   //                    elabId=Integer.parseInt(eLabsForGroup[j]);
                    elabId=eLabsForGroup[j];
                    project=(String) eLabs.get(elabId);
                 // Check if directory is already made; if not, make it and all the subdirectories                
                                     boolean mkdir, isDirectory;
                                    // directory structure:
                               
                                    String currDir = home + "/" + project + "/users/"+userarea+"/"+project;
                                 
                                    File newDir = new File(currDir);
                                    // Try making it.  If it fails, this means we already have it.
                                    
                                    mkdir=newDir.mkdir();
                                  //  out.write("Trying to make directory: "+ currDir + "with result "+mkdir +"\n");
                                    if(mkdir == true){
                                    
                                    //  out.write("Made directory: "+ currDir +"\n");
                                    // make subdirectories
                                       String[] newSubdirsArray = new String[] {"plots", "posters", "scratch"};
                                    for(int i=0; i<3; i++){
                                        currDir = home + "/" +project+"/users/" + userarea + "/" + project + "/" + newSubdirsArray[i];
                                       //  out.write("currDir = " + currDir+ "\n");
                                       newDir = new File(currDir);
                                        try{
                                            isDirectory = newDir.isDirectory();
                                        } catch(SecurityException e)
                                        {
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
                                  
                                    
                                    
                                    
                              } //test on need to make new directories
  

    
                           // check if this research group has an entry in the research_group_project table for this project.
                             int elabInt = Integer.parseInt(elabId);
                             query="select project_id from research_group_project where research_group_id="+id+" and project_id=" + elabInt +";";
                                 rs = s.executeQuery(query);
               
                                                          // Add entry to research_group_project table is no entry for this project.
                             if (!(rs.next()))
                              {
                               query="insert into research_group_project (research_group_id, project_id) " +
                                   " values("+id + ", " + elabInt + ");";
                               int iUpdate = s.executeUpdate(query); 
                               
                               
                              // Make sure all the students associated with this research_group have entries in the research_group_survey table if survey is true
                            query = "select survey from research_group where id="+id+";";
                            rs = s.executeQuery(query);
                            if (rs.next())
                            {
                              String survey=rs.getString("survey");
                             // out.write("survey is "+survey + "\n");
                              if (survey != null && survey.equals("t"))
                                {
                                  Statement sInner = conn.createStatement();
                                  query="select student_id from research_group_student where research_group_student.research_group_id="+id+";";
                                  rs = s.executeQuery(query);
                                  while (rs.next())
                                  {
                                    int studentId=rs.getInt("student_id");
                                    String innerQuery="insert into survey(student_id, project_id) values(" + studentId +","+ elabInt + " );";
                                    sInner.executeUpdate(innerQuery); 
                                  }
                            
                               }
                             }

                               
                           }  // test for research group having entry in research_group_project table

                    
                    
                      }  // for statement
                    } // test for elabs being passed
                        

                //done entering info.
                done = true;
                out.write("<tr><td><font color=\"green\">" + group + " successfully updated!</font></td><td>");
            } // test for group being chosen
        }  // check submit == Update e-Lab Assignments

        // Gather data for the user to modify.
        if (submit != null && submit.equals("Show Group Info")) {
            group = request.getParameter("chooseGroup");
            if (group != null && !group.equals("Choose Group")) {
                query = 
                    "SELECT id " +
                    "FROM research_group WHERE name = \'" + group + "\'";
                rs = s.executeQuery(query);
                if (rs.next()) {
                    id = rs.getInt("id");
                    }
          }
        }
%>
    	    <form name="myform" method="post" action="">
              <select name="chooseGroup">
                    <option value="null">Choose Group</option> 
<%
              // show group names with this teacher_id
                    // We can do this because the user is teacher for sure,
                    // it is checked above.
                    query =
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
                                    out.write("<tr><td align=\"right\">Group Name:</td><td>"+group+"</td></tr>");
%>                                <p>
    				            </td>
    				        </tr>
                            <tr>
                                <td>
                                    e-Labs for <%=group%>:
                                </td>
                                <td>
                                <table cellpadding=3>
<%
                             // make an hash map of the names of all projects this research group is registered for.
                             
                               query = 
                              "SELECT project.name as elabGroup from project,research_group_project where research_group_project.project_id=project.id and research_group_project.research_group_id=" + id + ";";
                                rs = s.executeQuery(query);
                             String elabGroup;  // the name of each eLab that this research group is registered for
                             while (rs.next()) {
                                elabGroup = rs.getString("elabGroup");
                                groupELabs.put(elabGroup, "checked");
                               // out.write("Setting "+elabGroup+" as "+ groupELabs.get(elabGroup)+"\n");
                              }
                               String projectQuery="";
                               try {
                                   projectQuery = 
                                        "SELECT id, name FROM project;";
                                    rs = s.executeQuery(projectQuery);
                                    int i = 0;
                                    while (rs.next()) {
                                        if (i % 3 == 0) {
                                            if (i == 0)
                                                out.write("<tr><td>");
                                            else
                                                out.write("</td><tr><td>");
                                        } else
                                            out.write("</td><td>");
                                            String eLabOfGroupName=rs.getString("name");
                                            //out.write("Name of project =" + eLabOfGroupName+"\n");
                                            String eLabSelected=(String) groupELabs.get(eLabOfGroupName); //see if the group is registered for this elab to set "selected" checkbox.
                                            if (eLabSelected==null) eLabSelected="";
                                            out.write("<input type=checkbox name=\"eLabsForGroup\" value=" + rs.getInt("id") + " "+eLabSelected+">");
                                             out.write(rs.getString("name"));
                                             i++;
                                    }
                                    out.write("</td></tr>");
                                } catch (Exception e) {
                                    out.write("<font color=\"red\">Problem retrieving your projects ( e-Labs) using query</font><BR>"+ projectQuery );
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
                <input type="submit" name="submit" value="Update e-Lab Assignments">
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
