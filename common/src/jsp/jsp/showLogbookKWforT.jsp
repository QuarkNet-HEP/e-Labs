<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
<html>
    <head>
        <title>For Teachers: All Logbook entries for one milestone.</title>
    </head>
    <body>
            <table width="800"><tr><td width="150">&nbsp;</td><td align="right" width="100"><IMG SRC="graphics/logbook_view_large.gif" align="middle" border="0"></td><td width="550"><font size="+2">Teachers: View and Comment on<BR>Logbooks of Student Research Groups</font></td></tr></table>
 <center>


<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
String role = (String)session.getAttribute("role");
if (role.equals("student") || role.equals("upload")) { 
    out.write("This page is only available to teachers");
    return;
    }
// it will display all logs entries for one keyword for all research groups associated with the teacher logged in.

// Sample query - select research_group.name,to_char(log.date_entered,'MM/DD/YYY HH12:MI'), log.log_text
//                from log,research_group where log.keyword_id=17 and research_group.id=log.research_group_id 
//                where research_group.id in ( select id from research_group where teacher_id=2 and (role='user' or role='upload')   ) order by research_group_id,log.id;
// If the keyword is not passed, then it will default to keyword "general".
String query="";
String keyword_description="";
String keyword_text="";
String linksToEach="";
String linksToEachGroup="";
String keyword_loop="";
String keyword_id="";
String research_group_name = groupName;  // set in common.jsp
String keyColor="";
String keyword = request.getParameter("keyword");
String passed_log_id = request.getParameter("log_id");
String teacher_id="";
     // get project ID
                //eLab defined in common.jsp
     String project_id="";
     query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}
      
     if (keyword==null) { keyword="general";} // default to showing entries for "general" if no keyword is passed.

       %>
     
            <table width="800" cellpadding="0" border="0" align="left"><tr><td valign="top" align="150">
    <table width="140">
<tr><td><A HREF="showLogbookRGforT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">By Group</A> </td></tr>

    <tr><td valign="center" align="left"><A HREF="showLogbookT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">My Logbook</A></td></tr>
<tr><td><A HREF="showLogbookKWforT.jsp?keyword=general">general</A></td></tr>
    <tr><td><B>Select a Milestone:</b></td></tr>


<%

//provide access to all possible items to view logs on. 
     query="select id,keyword,description,section,section_id from keyword where keyword.project_id in (0,"+project_id+") order by section,section_id;";
      String current_section="";
    rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_loop=rs.getString("keyword");
       keyword_text=keyword_loop.replaceAll("_"," ");
       keyword_description=rs.getString("description");
       String this_section=(String)(rs.getString("section"));
       if (!keyword_loop.equals("general")){
                 if (!this_section.equals(current_section)) {
                  String section_text="";
                  char this_section_char = this_section.charAt(0);
                   switch( this_section_char ) {
                   case 'A': section_text="Research Basics";break;
                   case 'B': section_text="A: Get Started";break;
                   case 'C': section_text="B: Figure it Out";break;      
                   case 'D': section_text="C: Tell Others";break;    
                      }
                 linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td>"+section_text+"</td></tr>";
                   current_section=this_section;
                 }
                   
                 keyColor="";
                if (keyword.equals(keyword_loop)) { keyColor="color=\"#AA3366\"";}
                linksToEach=linksToEach + "<tr><td><A HREF='showLogbookKWforT.jsp?keyword=" + keyword_loop + "'><FONT  "+keyColor+">" + keyword_text + "</font></A></td></tr>";}
                  
      }
     
 
    %>
    <%=linksToEach%>
    
       



</table>

   
   		</td>
   		
   		<td align="left" width="20" valign="top"><IMG SRC="graphics/blue_square.gif" border="0" width="2" height="475"></td>
   		
        <td valign="top" align="center">
        
             <div style="border-style:dotted; border-width:1px;">
     <table width="600">
       <tr><td align="left" colspan="4"><font  SIZE="+1" FACE="Comic Sans MS">Instructions</font></td></tr>

             <table>
        <tr><td align="right">&nbsp;</td><td align="left">Click <b>Read more</b> to read full log entry and reset "new log" status.</td>
        </tr>      <tr><td align="right"><IMG SRC="graphics/logbook_pencil.gif" align="center" border="0"></td><td align="left">Button to add and view comments on a logbook entry.</td>
        </tr>

        <tr><td colspan="2">&nbsp;</td></tr>
        <tr><td align="right" colspan="2"><font size="-2">Log Status: New log entries are marked as <IMG SRC="graphics/new_flag.gif" border=0 align="center"> <font color="#AA3366">New log entry</font>. Number of your comments (<font color="#AA3366"> number unread by students. </FONT>)</font></font> </td></tr>

</table></div>

        <%


// Always pass keyword, not id so we can pick off the description
//   String keyword_description="";
   keyword_id="";
     // first make sure a keyword was passed in the call
     query="select id,keyword,description from keyword where project_id in (0,"+project_id+") and keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");}
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}

    
// Get teacher_id of this user.
   query="select teacher_id from research_group where research_group.name=\'" + groupName +"\';";
    
     rs = s.executeQuery(query);
     if (rs.next()){
       teacher_id=rs.getString("teacher_id");}
       if (teacher_id.equals("")) {%> Problem with id for teacher.<BR><% return;}
    %>
    
    
    
    
    
    <h2>All logbook entries for your research groups<br>
    for "<%=keyword_description%>"</h2>      
<P>
      
      <table width="600" cellspacing="5">
      <%
    // look for any previous log entries for this keyword and all research groups
      query="select research_group.name as rg_name,to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered, log.log_text as log_text,log.id as log_id,log.new_log as new from log,research_group where log.keyword_id="+keyword_id+" and research_group.id=log.research_group_id and research_group.id in (select id from research_group where teacher_id="+teacher_id+" and (role='user' or role='upload')) order by research_group.name,log.id DESC;";
   //  out.write(query);
     Statement sInner = null;
     ResultSet innerRs = null;

     int itemCount=0;
     boolean showFullLog=false;
     String current_rg_name="";
     String elipsis="";
     String linkText="";
     rs = s.executeQuery(query);
     while (rs.next()){
          String dateText=rs.getString("date_entered");
          String log_text=rs.getString("log_text");
          String log_id=rs.getString("log_id");
          showFullLog=false;
          if (log_id.equals(passed_log_id)) {
            showFullLog=true;
            elipsis="";
            linkText="";
          }
          else
          {
          elipsis=" . . .";
          }
          
          String log_text_truncated;
          if (showFullLog)
              log_text_truncated = log_text;
          else
            log_text_truncated = log_text.replaceAll("\\<(.|\\n)*?\\>","");
          int maxChars=log_text_truncated.length();
          if (maxChars > 50  && !showFullLog) {maxChars=50;}
          log_text_truncated = log_text_truncated.substring(0,maxChars);
          String rg_name=rs.getString("rg_name");
          String new_log=rs.getString("new");
          String comment_count="";
          String comment_new="";
          String comment_info="";
          sInner = conn.createStatement();
//  Do a query for this log entry to see if there are any unread comments on it and if it has comments on it.
          String innerQuery="select count(id) as comment_count from comment where  log_id="+log_id+";";
       //   out.write("\r\r"+innerQuery);
          innerRs = sInner.executeQuery(innerQuery);
          if (innerRs.next()){
              comment_count=innerRs.getString("comment_count");
              }
          innerQuery="select count(comment.id) as comment_new from comment where comment.new_comment='t' and log_id="+log_id+";";
        //  out.write(innerQuery);
          innerRs = sInner.executeQuery(innerQuery);
          if (innerRs.next()){
                comment_new=innerRs.getString("comment_new");
              }
         if ( new_log!=null && new_log.equals("t") && !showFullLog) {
             comment_info=comment_info+"<BR><IMG SRC=\'graphics/new_flag.gif\' border=0 align=\'center\'> <FONT color=\"#AA3366\" size=\"-2\"><b>New log entry</b></font>";
              }
          if (!comment_count.equals("") && !comment_count.equals("0") ) {
              if (comment_new.equals("0")) {
              comment_info=comment_info+"<BR><FONT size=-2>comments: "+comment_count+"</font>";
              }
              else
              {
              if (comment_count.equals("")) {comment_count="0";}
              comment_info=comment_info+"<BR><FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) " +"</font>";
              }
             // out.write("New comments="+comment_new);
              }
            if (!showFullLog)
            {
            linkText="<A HREF=\"showLogbookKWforT.jsp?research_group_name="+rg_name+"&keyword="+keyword+"&log_id="+log_id+"\">Read more</A>";
            }




              
          itemCount++;
          if (!(current_rg_name.equals(rg_name))) {
              current_rg_name=rg_name;
              if (itemCount>1) {
                  %></table><P>
                  <% 
                  }
          %>
          <table cellpadding="5">
          <tr align="center"><td colspan="2"><font  size=+1>Group: "<%=rg_name%>"</font> </td></tr><%
          
          }
           %>
         <tr><td valign="top" width="175" align="right"><A HREF="logCommentEntry.jsp?log_id=<%=log_id%>&keyword=<%=keyword%>&research_group_name=<%=rg_name%>&path=KW"><IMG SRC="graphics/logbook_pencil.gif" border="0" align="top"</A> <%=dateText%><%=comment_info%></td><td width="400" valign="top">
         <e:whitespaceAdjust text="<%=log_text_truncated%>"/><%=elipsis%><%=linkText%></td></tr>
          <%
          
             if (showFullLog)
            {

              innerQuery="UPDATE log SET new_log=\'f\'  WHERE id=" + log_id + ";";
          innerQuery="UPDATE log SET new_log=\'f\'  WHERE id=" + log_id + ";";
          int k=0;
          try{
                k = sInner.executeUpdate(innerQuery);
             } 
             catch (SQLException se){
                 warn(out, "There was some error updating your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              } // try-catch for updating survey table
              if(k != 1){
                  warn(out, "Weren't able to update your info to the database! " + k + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                  return;
               } //!k=1 test 

             }

          
          
          
          
          }
          if (itemCount==0) {
          %>
          
          <tr align="center"><td colspan="2"><font  size=+1>No entries for this milestone.</font></td></tr>
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
