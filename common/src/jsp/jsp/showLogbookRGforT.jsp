<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
<html>
    <head>
        <title>For Teachers: Show Logbooks of Student Research Group</title>
    </head>
    <body>
           
            <table width="800"><tr><td width="150">&nbsp;</td><td align="right" width="100"><IMG SRC="graphics/logbook_view_large.gif" align="middle" border="0"></td><td width="550"><font size="+2">Teachers: View and Comment on<BR>Logbooks of Student Research Groups</font></td></tr></table>
 <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
// invoked with optional research_group_name and keyword
// if no research_group_name is passed, 
String role = (String)session.getAttribute("role");
if (!role.equals("teacher")) { 
    out.write("This page is only available to teachers");
    return;
    }
// it will display all or one keyword for a particular research group.
// If the research_group_name is not passed, then it will show a list of research groups that teacher has for this e-Lab and return.
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
String research_group_name = request.getParameter("research_group_name");
String passed_log_id = request.getParameter("log_id");
String current_section="";
String keyColor="";
String typeConstraint=" AND keyword.type in ('SW','S')";
     if (!(research_group_name==null)) {
            if ( research_group_name.startsWith("pd_")||research_group_name.startsWith("PD_")) {typeConstraint=" AND keyword.type in ('SW','W')";}
         }
      String keyword = request.getParameter("keyword");
   if (keyword==null) {keyword="";} // note - display all entries
     // get project ID
                //eLab defined in common.jsp
     String project_id="";
     query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}
      
	 query="select id,name from research_group,research_group_project where (role='user' or role='upload') and research_group_project.project_id=" + project_id + " and research_group_project.research_group_id=research_group.id and research_group.teacher_id IN (select teacher_id from research_group where research_group.name=\'" + groupName +"\');";
     //out.write(query);
     

		 rs = s.executeQuery(query);
		 while (rs.next()){
		   String rg_name=rs.getString("name");
		   linksToEachGroup=linksToEachGroup + "<tr><td><A HREF='showLogbookRGforT.jsp?research_group_name="+rg_name+"'>"+rg_name+"</A></td></tr>";
			}


     
     
     
     %>
     
            <table width="800" cellpadding="0" border="0" align="left"><tr><td valign="top" align="150">
    <table width="140"><tr><td valign="center" align="left"><A HREF="showLogbookKWforT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">By Milestone</A></td></tr>
        <tr><td valign="center" align="left"><A HREF="showLogbookT.jsp"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">My Logbook</A></td></tr>
    <tr><td><b>Select a Research Group</b></td></tr><%=linksToEachGroup%>

   <%
     if (!(research_group_name==null)) {
     String yesNo="no";
     
      query="select distinct keyword_id from log,research_group,keyword where keyword.keyword=\'general\' and keyword.id=log.keyword_id and research_group.name=\'"+research_group_name+"\' and research_group.id=log.research_group_id and log.project_id="+project_id+";";
      rs = s.executeQuery(query);
      if (rs.next()){
      yesNo="yes";
      }

     
    %>

    <tr><td><BR><b>Entries for "<%=research_group_name%>"</b></td></tr>

    <tr><td valign="center" align="left"><A HREF="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>"><IMG SRC="graphics/logbook_view.gif" border=0" align="middle"> All Entries</A></td></tr>
<tr><td align="center"><IMG SRC="graphics/log_entry_yes.gif" border="0"><font  FACE="Comic Sans MS"> if entry exists</font></td></tr>

<tr><td><img src="graphics/log_entry_<%=yesNo%>.gif" border=0 align=center><A HREF="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>&keyword=general">general</A></td></tr>


<%
     HashMap keywordTracker = new HashMap();
      query="select distinct keyword_id from log,research_group where research_group.name=\'"+research_group_name+"\' and research_group.id=log.research_group_id and project_id="+project_id+";";
      rs = s.executeQuery(query);
      while (rs.next()){
       keyword_id=rs.getString("keyword_id");
       keywordTracker.put(keyword_id, new Boolean(true));
       }





//provide access to all possible items to view logs on. 
     query="select id,keyword,description,section,section_id from keyword where keyword.project_id in (0,"+project_id+ ") " + typeConstraint + "order by section,section_id;";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_loop=rs.getString("keyword");
       keyword_text=keyword_loop.replaceAll("_"," ");
       keyword_description=rs.getString("description");
       String this_section=(String)(rs.getString("section"));
       yesNo="no";
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
                 
                               // More work to do if we haven't seen this one yet.
                if (keywordTracker.containsKey(keyword_id)) {
                   yesNo="yes";}
 
                keyColor="";
                if (keyword.equals(keyword_loop)) { keyColor="color=\"#AA3366\"";}
                linksToEach=linksToEach + "<tr><td><img src=\"graphics/log_entry_" + yesNo + ".gif\" border=0 align=center><A HREF='showLogbookRGforT.jsp?research_group_name=" + research_group_name + "&keyword=" + keyword_loop + "'><FONT  "+keyColor+">" + keyword_text + "</font></A></td></tr>";}

      }
     
 
    %>
       <tr><td><BR><B>Select a Milestone:</b></td></tr>
 <%=linksToEach%>
    <%
    }  //end of conditional list of keywords.
    %>

</table>

   
   		</td>
   		
   		<td align="left" width="20" valign="top"><IMG SRC="graphics/blue_square.gif" border="0" width="2" height="650"></td>
   		
        <td valign="top" align="center">
             <table>
        <tr><td align="right">&nbsp;</td><td align="left">Click <b>Read more</b> to read full log entry and reset "new log" status.</td>
        </tr>      <tr><td align="right"><IMG SRC="graphics/logbook_pencil.gif" align="middle" border="0"></td><td align="left">Click to add and view comments on a logbook entry.</td>
        </tr>

        <tr><td colspan="2">&nbsp;</td></tr>
        <tr><td align="right" colspan="2"><font size="-2">Log Status: New log entries are marked as <IMG SRC="graphics/new_flag.gif" border=0 align="center"> <font color="#AA3366">New log entry</font>. Number of your comments (<font color="#AA3366"> number unread by students. </FONT>)</font></font> </td></tr>

</table>
        <%
        
     if (!(research_group_name==null)) {
        

     // get group ID
                //groupName defined in common.jsp
     String research_group_id="";
     query="select id from research_group where name=\'"+research_group_name+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=research_group_id%><BR><% return;}

// Always pass keyword, not id so we can pick off the description
//   String keyword_description="";
   keyword_id="";
   if (!keyword.equals(""))
    {
     // first make sure a keyword was passed in the call
     query="select id,keyword,description from keyword where project_id in (0,"+project_id+") and keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");}
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}

      
      }
   
    if (keyword_id.equals("")) {
    %>
    <h2>All logbook entries for group "<%=research_group_name%>"</h2>
     <%
     keyword_description="";
      queryWhere="  where log.project_id=" + project_id + " and keyword.project_id  in (0,"+project_id+") and log.keyword_id=keyword.id and research_group_id="+research_group_id+" and role=\'user\'";


     }
     else
     {
     %>
    <h2>Logbook entry for group "<%=research_group_name%>"
      </h2>
      <%
     queryWhere="  where log.project_id=" + project_id + " and keyword.project_id  in (0,"+project_id+") and research_group_id="+research_group_id+" and log.keyword_id=keyword.id and keyword_id="+keyword_id+" and role=\'user\'";

      }
      %>
      
<P>
      
      <table width="600" cellspacing="5">
      <%
    // look for any previous log entries for this keyword
        
    
     querySort=" order by keyword.section,keyword.section_id,log.id DESC;";
     queryItems="select log.id as log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered,log_text,keyword.description as description, keyword.id as data_keyword_id, keyword.keyword as keyword_name,keyword.section as section, keyword.section_id as section_id,log.new_log as new from log,keyword";
     query=queryItems+queryWhere+querySort;

     Statement sInner = null;
     ResultSet innerRs = null;

     int itemCount=0;
     boolean showFullLog=false;
     String elipsis="";
     String linkText="";
     String current_keyword_id="";
     String sectionText="";
     current_section="";
     rs = s.executeQuery(query);
     while (rs.next()){
          String data_keyword_id=rs.getString("data_keyword_id");
          String dateText=rs.getString("date_entered");
          keyword_description=rs.getString("description");
          String log_text=rs.getString("log_text");
          
          String log_id=rs.getString("log_id");
          String new_log=rs.getString("new");
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
          log_text_truncated=log_text_truncated.substring(0,maxChars);
          String keyword_name=rs.getString("keyword_name");
          String keyword_display=keyword_name.replaceAll("_"," ");
          String section=rs.getString("section");
          String section_id=rs.getString("section_id");
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
              comment_info=comment_info+"<BR><FONT size=-2>comments: " +comment_count+"</font>";
              }
              else
              {
              if (comment_count.equals("")) {comment_count="0";}
              comment_info=comment_info+"<BR><FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>)" +" </font>";
              }
             // out.write("New comments="+comment_new);
              }
            if (!showFullLog)
            {
            linkText="<A HREF=\"showLogbookRGforT.jsp?research_group_name="+research_group_name+"&keyword="+keyword+"&log_id="+log_id+"#"+log_id+"\">Read more</A>";
            }




              
          itemCount++;
          if (!(current_keyword_id.equals(data_keyword_id))) {
              current_keyword_id=data_keyword_id;
              if (itemCount>1) {
                  %></table><P>
                  <% 
                  }
               if (keyword_name.equals("general") || (current_section.equals(section))) { sectionText="";}
                  else
                 {
                    sectionText="";
                   char this_section_char = section.charAt(0);
                   switch( this_section_char ) {
                  case 'A': sectionText="Research Basics";break;
                   case 'B': sectionText="A: Get Started";break;
                   case 'C': sectionText="B: Figure it Out";break;      
                   case 'D': sectionText="C: Tell Others";break;    
                      }
                 current_section=section;
                 }

          %>
          <table cellpadding="5">
          
           <% if (!sectionText.equals(""))
          {
          %>
          <tr align="left"><td colspan="2"><font  size=+1><%=sectionText%></font></td></tr>
          <%
          }
          %>
          <tr align="left"><td colspan="2"><font  size=+1 color="#AA3366"><%=keyword_display%></FONT> - <%=keyword_description%></font></td></tr>
          <%

          
          }
          
          
           %>
          
         <tr><td valign="top" width="175" align="right"><A HREF="logCommentEntry.jsp?log_id=<%=log_id%>&keyword=<%=keyword_name%>&research_group_name=<%=research_group_name%>&path=RG"><IMG SRC="graphics/logbook_pencil.gif" border="0" align="top"</A> <%=dateText%><%=comment_info%></td><td width="400" valign="top">
         	<a name="<%=log_id%>"><e:whitespaceAdjust text="<%=log_text_truncated%>"/></a><%=elipsis%><%=linkText%></td></tr>
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
            String noEntries="No entries";
            if (!keyword_description.equals(""))
            {
             String keyword_name=keyword.replaceAll("_"," ");
              noEntries=noEntries+ " for \"" + keyword_name +": "+ keyword_description+ "\"";
             }
             %>
          
          <tr align="center"><td colspan="2"><font  size=+1><%=noEntries%>.</font></td></tr>
         <%
           }

         %>

    </table>
    
     <%
             }  //for displaying right column - when research_group has been chosen
       else
            {
           %>
            <table width="600" cellspacing="5"><tr><td width="590">&nbsp;</td></tr></table>


       <%
       }
       %>
    
    
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
