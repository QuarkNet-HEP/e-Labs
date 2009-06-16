<%@ page import="java.util.*" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<link rel="stylesheet"  href="include/styletutT.css" type="text/css">
<html>
    <head>
        <title>Show Research Group Logbook for Teacher</title>
    </head>
    <body>

            <table width="800"><tr><td width="150">&nbsp;</td><td width="100" align="right"><IMG SRC="graphics/logbook_view_large.gif" align="middle" border="0"></td><td width="550"><font size="+2">Teachers: View Your <b>Private</b> Logbook<BR>on Student Research Groups.</font></td></tr></table>
            <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
// invoked with optional research_group_name
// if no research_group_name is passed, 
String role = (String)session.getAttribute("role");
if (!role.equals("teacher")) { 
    out.write("This page is only available to teachers");
    return;
    }
// it will display all or one keyword for a particular research group.
// If the ref_rg_name is not passed, then it will show a list of research groups that teacher has for this e-Lab and return.
// Each of these will link to this page with research_group_name passed without a keyword.
String query="";
String queryItems="";
String querySort="";
String queryWhere="";
String keyword_description="";
String keyword_text="";
String linksToEach="";
String linksToEachGroup="";
String keyword_loop="";
String keyword_id="";
String[] rgNames = new String[100];
String[] rgIds = new String[100];
String teacher_name="";
int countRgs=0;
String ref_rg_name = request.getParameter("ref_rg_name"); // this is the name we are referring to in the logbook
String research_group_name = groupName; // group name of the teacher whose logbook this is.
     // get project ID
                //eLab defined in common.jsp
     String project_id="";
     query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}
      
                // get group ID
                //groupName defined in common.jsp
     String research_group_id="";
     query="select research_group.id as rg_id,teacher.name as teacher_name from research_group,teacher where research_group.name=\'"+research_group_name+"\' and research_group.teacher_id =teacher.id;";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("rg_id");
       teacher_name=rs.getString("teacher_name");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group of teacher.<%=research_group_id%><BR><% return;}

      
	 query="select id,name from research_group,research_group_project where (role='user' OR role='upload') and research_group_project.project_id=" + project_id + " and research_group_project.research_group_id=research_group.id and research_group.teacher_id IN (select teacher_id from research_group where research_group.name=\'" + groupName +"\')  order by name;";
    // out.write(query);
     
         int r=0;
		 rs = s.executeQuery(query);
		 while (rs.next()){
		   String this_ref_rg_id=rs.getString("id");
		   String this_ref_rg_name=rs.getString("name");
		   linksToEachGroup=linksToEachGroup + "<tr><td><A HREF='showLogbookT.jsp?ref_rg_name="+this_ref_rg_name+"'>"+this_ref_rg_name+"</A></td></tr>";
            rgIds[r]=this_ref_rg_id;
            rgNames[r]=this_ref_rg_name;
            r++;
			}
          countRgs=r;
          // tack on the self-referential research group of the teacher used for general comments
          
            rgIds[r]=research_group_id;
            rgNames[r]="general";
            countRgs++;

     
     
     
     %>
     
            <table width="800" cellpadding="0" border="0" align="left"><tr><td valign="top" align="150">
    <table width="140">
    <tr><td valign="center" align="left"><b>Student Logbooks</b></td></tr>
    <tr><td valign="center" align="left"><A HREF="showLogbookKWforT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle"><font color="#1A8BC8">By Milestone</font></A></td></tr>
    <tr><td valign="center" align="left"><A HREF="showLogbookRGforT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle"><font color="#1A8BC8">By Group</font></A></td></tr>
    <tr><td><b>Your Logbook:<BR><A HREF="showLogbookT.jsp?ref_rg_name=general">general</A><br><BR>Select a Research Group</b> </td></tr><%=linksToEachGroup%>
    <tr><td valign="center" align="left"><A HREF="showLogbookT.jsp">All Groups</A></td></tr>

</table>

   
   		</td>
   		
   		<td align="left" width="20" valign="top"><IMG SRC="graphics/red_square.gif" border="0" width="2" height="475"></td>
   		
        <td valign="top" align="center">
                  
      <table>
      <tr><td align="right"><IMG SRC="graphics/logbook_pencil.gif" align="middle" border="0"></td><td align="left">Click to add/edit logbook entry.</td>
        </tr></table>

        <%
     
// old position of code to get research_group_id    
     
     String ref_rg_id="";
     
    if (!(ref_rg_name==null)&&(!ref_rg_name.equals("general")))
    {
    // get group ID
                //groupName defined in common.jsp
     query="select id from research_group where name=\'"+ ref_rg_name +"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       ref_rg_id=rs.getString("id");}
       
       if (ref_rg_id.equals("")) {%> Problem with ID for student research group <%=research_group_id%><BR><% return;}
   }
   else
   {

       if (!(ref_rg_name==null) && ref_rg_name.equals("general")) {
          ref_rg_id=research_group_id; // general references for teachers will be self referential.
          }
       else 
         {
            ref_rg_name="";// note - display all entries
         }
  
  }


    if (ref_rg_name.equals("")) {
     %>
    <h2>For all groups for teacher  "<%=teacher_name%>"</h2>
     <%
     querySort=" order by log.ref_rg_id,log_id DESC;";
     queryWhere=" where log.project_id=" + project_id + " and  log.research_group_id="+research_group_id +" and log.research_group_id=research_group.id and log.role=\'teacher\'";


     }
     else
     {
       if (ref_rg_name.equals("general"))
         {
         %>
          <h2>General notes for teacher "<%=teacher_name%>"
         </h2>
        <%
         }
         else
        {
        %>
        <h2>For group "<%=ref_rg_name%>" for teacher "<%=teacher_name%>"
        </h2>
        <%
                }





      querySort=" order by log_id DESC;";
     queryWhere="  where log.project_id=" + project_id + " and  log.research_group_id="+research_group_id + " and log.research_group_id=research_group.id and log.ref_rg_id = " + ref_rg_id + " and log.role=\'teacher\'";

      }
      %>
      
<P>
      <table width="600" cellspacing="5">
      <%
    // look for any previous log entries for this keyword
     queryItems="select log.id as log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered,log_text,log.ref_rg_id as ref_rg_id from log,research_group";
     query=queryItems+queryWhere+querySort;


     int itemCount=0;
     String current_ref_rg_id="";
     rs = s.executeQuery(query);
     while (rs.next()){
          String dateText=rs.getString("date_entered");
          String log_text=rs.getString("log_text");
          String log_id=rs.getString("log_id");
          ref_rg_id=rs.getString("ref_rg_id");
          itemCount++;
          if (!(current_ref_rg_id.equals(ref_rg_id))) {
              current_ref_rg_id=ref_rg_id;
              if (itemCount>1) {
                  %></table><P>
                  <% 
                  }
              ref_rg_name="";
              boolean search=true;
              int j=0;
              while ((search) && (j<countRgs))
              {
              if (current_ref_rg_id.equals(rgIds[j]))
              { ref_rg_name=rgNames[j];
                search=false;
               }
               j++;
              }
                  
                  
                  
                  
                  
                  
          %>
          <table cellpadding="5">
          <tr align="center"><td colspan="2"><font  size=+1><%=ref_rg_name%></font><A HREF="logEntryT.jsp?research_group_id=<%=research_group_id%>&ref_rg_id=<%=ref_rg_id%>"><IMG SRC="graphics/logbook_pencil.gif" border="0" align="top"</A></td></tr><%
          
          }
          
          %>
         <tr><td valign="top" width="175" align="right"><%=dateText%></td><td width="400" valign="top"><e:whitespaceAdjust text="<%= log_text %>"/></td></tr>
          <%
          }
          if (itemCount==0) {
  
          %>
          
          <tr align="center"><td colspan="2"><font  size=+1>No entries.</font>           <%
          if (!(ref_rg_id.equals(""))) {
  
          %>
<A HREF="logEntryT.jsp?research_group_id=<%=research_group_id%>&ref_rg_id=<%=ref_rg_id%>"><IMG SRC="graphics/logbook_pencil.gif" border="0" align="top"</A>
         <%
         }
         else
                  
         {
          %>
         <BR><font  size=+1>Select a research group on the left.</font>
         <%
         }
         %>
  
         </td></tr>
         <%
           }

         %>

    </table>
    
     
    
</td></tr></table>


  		
   		
   		
   		</center>
	</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
