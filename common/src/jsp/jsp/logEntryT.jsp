<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Enter Logbook</title>
    </head>
<link rel="stylesheet"  href="include/styletutT.css" type="text/css">
    <body >
        <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
// called from showLogbookT.jsp where research_group_id is group id of teacher
//  ref_rg_id is id of student research group for which teacher is adding log entry.

//start jsp by defining submit
String role = (String)session.getAttribute("role");
if (!role.equals("teacher")) { 
    out.write("This page is only available to teachers.");
    return;
    }
String submit =  request.getParameter("button");
String log_id =  request.getParameter("log_id");
String log_text =  request.getParameter("log_text");
String img_src =  request.getParameter("img_src");
if (img_src == null) img_src = "";
String count =  request.getParameter("count");
if (count == null) count = "0";
String research_group_id =  request.getParameter("research_group_id");
String ref_rg_id =  request.getParameter("ref_rg_id");
String ref_rg_name =  "";
String buttonText="Add Your Logbook Entry";
String query="";


if (research_group_id==null) {
     // get group ID
                //groupName defined in common.jsp
     research_group_id="";
     query="select id from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=groupName%><BR><% return;}
    }
 if (ref_rg_id==null) 
     // this is not optional; we have to know which student group it is.
    {%> No student research group passed.<BR><% return;}
    else
    {
    // get name of student research group
                //groupName defined in common.jsp
     if (ref_rg_id.equals(research_group_id)) { 
     ref_rg_name="General Notes";
     }
     else
     {
     ref_rg_name="";
      query="select name from research_group where id=\'"+ref_rg_id+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       ref_rg_name=rs.getString("name");}
       
       if (ref_rg_name.equals("")) {%> Problem with ID for student research group,<BR><% return;}
    }
    }
   
    
    
    
    
 String project_id =  request.getParameter("project_id");
 if (project_id==null) {
     // get project ID
                //eLab defined in common.jsp
     project_id="";
     query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}
    }
    %>
    
     <table width="800" align="center"><tr><td align="right"><IMG SRC="graphics/logbook_large.gif" align="middle" border="0"></td><td><font size="+2" FACE="arial MS" align="left">Your <b>Private</b> logbook entries for  
      "<%=ref_rg_name%>"</font></td></tr></table>
      <%
    String currentEntries="";

    if (log_id==null) {log_id="";}
    // look for any previous log entries for this keyword
     query="select log.id as cur_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered,log.log_text as cur_text from log where project_id="+project_id+" and research_group_id="+research_group_id+ " and ref_rg_id="+ref_rg_id+" and role=\'"+role+"\' order by cur_id;";
     rs = s.executeQuery(query);
     boolean first=true;
     while (rs.next()){
       String curLogId=rs.getString("cur_id");
       if (!(curLogId.equals(log_id))) {
          String curDate=rs.getString("date_entered");
          String curText=rs.getString("cur_text");
          if (first) {first=false;
           currentEntries=currentEntries+"<tr><th align='center' colspan='2'><FONT FACE='arial MS'>Your Current Entries</font></th></tr>";
          
          }
          currentEntries=currentEntries+"<tr><td valign='top' width='150' align='right'><FONT FACE='arial MS'>"+curDate+"<FONT></td><td width='450'><FONT FACE='arial MS'>"+curText+"</FONT></td></tr>";
       }
   }
    
   if (submit!=null && !log_text.equals("")) {  
   // need to update or insert an entry yet
      String log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">" + log_text + "</div>";
 
      String parsed[] = img_src.split(",");
      for (int i = 0; i < parsed.length; i++)
      {
        log_enter = log_enter.replaceAll("\\(--Image "+i+"--\\)", parsed[i]);
      }     
      log_enter=log_enter.replaceAll("'","''");
      if (log_id == "") {
      //we have to insert a new row into table
         int i=0;
         query="INSERT INTO log (project_id, research_group_id, ref_rg_id, role,log_text) VALUES ("+project_id + "," + research_group_id + "," + ref_rg_id + ",\'" + role+"\','"  + log_enter + "\');";
           try{
                i = s.executeUpdate(query);
              } catch (SQLException se){
                 warn(out, "There was some error entering your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              }
              if(i != 1){
                 warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                    return;
              }
      // get the log_id of the entry you just entered
      query="select log.id as id from log where research_group_id="+research_group_id+" and project_id="+project_id+" and ref_rg_id="+ref_rg_id+" and role=\'"+role+"\' order by log.id DESC;";
       rs = s.executeQuery(query);
      if (rs.next()){
       log_id=rs.getString("id");}
       if (log_id.equals("")) {%> Problem with ID for log entered.<BR><% return;}
  %>
     <h2><font FACE="arial MS" >Your log was successfully entered. You can edit it and update it.<BR>Click <font color="#1A8BC8">Show Logbook</font> to access all entries in your logbook.</font></h2>
 <%
            
      }
      else if  (!log_text.equals(""))
      {
      //we need to update row with id=log_id 
           query="UPDATE log SET log_text=\'"+log_enter + "\' WHERE id=" + log_id + ";";
          int k=0;
          try{
                k = s.executeUpdate(query);
             } 
             catch (SQLException se){
                 warn(out, "There was some error entering your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              } // try-catch for updating survey table
              if(k != 1){
                  warn(out, "Weren't able to add your info to the database! " + k + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                  return;
               } //!k=1 test 
  %>
     <h2><font FACE="arial MS">Your log was successfully updated. You can edit it some more and update it.<BR>Click <font color="red">Show Logbook</font> to access all entries in your logbook.</font></h2>
 <%
            

      }
      buttonText="Update Our Logbook Entry";
      log_enter=log_enter.replaceAll("''","'");
      %><table border=1><tr><td align="left"><%=log_enter%></td></tr></table>
<%
    
   }
   if (log_text==null) {log_text="";}
   %>
   <P>
              <form method=get name="log">
              <table  width=400>
              <tr><th><font  FACE="arial MS">Your New Log Book Entry</FONT></th></th>
              <tr><td colspan="2">
             <% if (log_id != "") { %>
            	<input type="hidden" name="log_id" value="<%=log_id%>">
             <% } %>
             	<input type="hidden" name="project_id" value="<%=project_id%>">
             	<input type="hidden" name="research_group_id" value="<%=research_group_id%>">
             	<input type="hidden" name="ref_rg_id" value="<%=ref_rg_id%>">
             	<input type="hidden" name="role" value="<%=role%>">
             	<textarea name="log_text" cols="80" rows="10"><%=log_text%></textarea>
              </td></tr>
            <tr><td align='left'><INPUT type='button' name="plot" onClick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;" value="Insert a plot"></td>
            <td align="right"><INPUT type="submit" name="button" value="<%=buttonText%>"></td></tr>
            </table>
            <input type="hidden" name="img_src" value="<%=img_src%>">
            <input type="hidden" name="count" value="<%=count%>">
            </form>
            
   <BR>
<table>
	<tr>
		<td valign="center" align="center">
<a href="showLogbookT.jsp"><font FACE="arial MS" size="+1"><img src="graphics/logbook_view.gif" border="0" align="middle"> Show Logbook</font></a>
		</td>
	</tr>
</table>
<P>
<%
   if (!currentEntries.equals("")) {
   %>
    <HR width="400" color="#F76540" size=3>
    <table width="600" cellspacing="5" cellpadding="5">
    <%=currentEntries%>
    </table>



    <%
    }
    %>
 
 
 
 
 
 
 
 
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
