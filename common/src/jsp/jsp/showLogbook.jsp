<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.util.HTMLEscapingWriter" %>
<%@ include file="common.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<html>
    <head>
        <title>Enter Logbook</title>
        <link rel="stylesheet"  href="include/styletut.css" type="text/css">
    </head>
    <body onLoad='self.focus();'>
            <center>
            <table width="800" cellpadding="0" border="0" align="left"><tr><td valign="top" align="150">

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
String role = (String)session.getAttribute("role");
if (role.equals("teacher")) { 
    out.write("This page is only available to student research groups.");
    return;
    }
String keyColor="";
String query="";
String queryItems="";
String querySort="";
String queryWhere="";
String keyword_description="";
String keyword_text="";
String linksToEach="";
String keyword_loop="";
String keyword_id="";
String typeConstraint=" AND keyword.type in ('SW','S')";
if (groupName.startsWith("pd_")||groupName.startsWith("PD_")) {typeConstraint=" AND keyword.type in ('SW','W')";}

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
      
           String yesNo="no";
     
      query="select distinct keyword_id from log,research_group,keyword where keyword.keyword=\'general\' and keyword.id=log.keyword_id and research_group.name=\'"+groupName+"\' and research_group.id=log.research_group_id and log.project_id="+project_id+";";
      rs = s.executeQuery(query);
      if (rs.next()){
      yesNo="yes";
      }
%>
    <table width="140">

    <tr><td valign="center" align="left"><A HREF="showLogbook.jsp"><font  FACE="Comic Sans MS"><IMG SRC="graphics/logbook_view.gif" border=0" align="middle"> All Entries</font></A></td></tr>
<tr><td><img src="graphics/log_entry_<%=yesNo%>.gif" border=0 align=center><A HREF="showLogbook.jsp?keyword=general"><font  FACE="Comic Sans MS">general</FONT></A></td></tr>
<tr><td><b><BR><font  FACE="Comic Sans MS">Milestones from<BR>Research Basics<BR> and Study Guide</font></b></td></tr>
<tr><td align="center"><IMG SRC="graphics/log_entry_yes.gif" border="0"><font  FACE="Comic Sans MS"> if entry exists</font></td></tr>
<%
     HashMap keywordTracker = new HashMap();
      query="select distinct keyword_id from log,research_group where research_group.name=\'"+groupName+"\' and research_group.id=log.research_group_id and project_id in (0,"+project_id+");";
      rs = s.executeQuery(query);
      while (rs.next()){
       keyword_id=rs.getString("keyword_id");
       keywordTracker.put(keyword_id, new Boolean(true));
       }


//provide access to all possible items to make logs on. 
     query="select id,keyword,description,section,section_id from keyword where keyword.project_id in (0,"+project_id+") " + typeConstraint + " order by section,section_id;";
     String current_section="";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_loop=rs.getString("keyword");
       keyword_text=keyword_loop.replaceAll("_"," ");
       keyword_description=rs.getString("description");
       String this_section=(String)(rs.getString("section"));
       yesNo="no";

      if (!keyword_loop.equals("general")){
               if (!this_section.equals(current_section))
               {
                  String section_text="";
                  char this_section_char = this_section.charAt(0);
                   switch( this_section_char ) {
                   case 'A': section_text="Research Basics";break;
                   case 'B': section_text="A: Get Started";break;
                   case 'C': section_text="B: Figure it Out";break;      
                   case 'D': section_text="C: Tell Others";break;    
                      }
                    linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td><font  FACE='Comic Sans MS'>"+section_text+"</font></td></tr>";
                   current_section=this_section;
                 }

                  if (keywordTracker.containsKey(keyword_id)) {
                   yesNo="yes";}
 
    
      
      
                 keyColor="";
                 if (keyword.equals(keyword_loop)) { keyColor="color=\"#AA3366\"";}
                 linksToEach=linksToEach + "<tr><td><img src=\"graphics/log_entry_" + yesNo + ".gif\" border=0 align=center><A HREF='showLogbook.jsp?keyword="+keyword_loop+"'><font  FACE='Comic Sans MS'"+keyColor+">"+keyword_text+"</FONT></A></td></tr>";}

      }
     
 
    %>
    <%=linksToEach%>

</table>

   
   		</td>
   		
   		<td align="left" width="20" valign="top"><IMG SRC="graphics/blue_square.gif" border="0" width="2" height="500"></td>
   		
        <td valign="top" align="center">
        <%

     // get group ID
                //groupName defined in common.jsp
     String research_group_id="";
     query="select id from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=groupName%><BR><% return;}

// Always pass keyword, not id so we can pick off the description
//   String keyword_description="";
   keyword_id="";
   if (!keyword.equals(""))
    {
     // first make sure a keyword was passed in the call
     query="select id,keyword,description from keyword where keyword.project_id in (0,"+project_id+") and keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");}
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}

      
      }
   
    if (keyword_id.equals("")) {
    %>
  <table width="600"><tr><td align="right"><IMG SRC="graphics/logbook_large.gif" align="middle" border="0"></td><td><H2><font FACE="Comic Sans MS">Logbook Entries for Group "<%=groupName%>"</font></H2></td></tr></table>
     <%
     queryWhere="  where log.project_id=" + project_id + " and keyword.project_id in (0,"+project_id+") and log.keyword_id=keyword.id and research_group_id="+research_group_id+" and role=\'user\'";


     }
     else
     {
     %>
  <table width="600"><tr><td align="right"><IMG SRC="graphics/logbook_large.gif" align="middle" border="0"></td><td><H2><font  FACE="Comic Sans MS">Logbook Entry for Group "<%=groupName%>"</font></h2></td></tr>
  </table>
  
      <%
     queryWhere="  where log.project_id=" + project_id + " and keyword.project_id  in (0,"+project_id+") and research_group_id="+research_group_id+" and log.keyword_id=keyword.id and keyword_id="+keyword_id+" and role=\'user\'";

      }
      %>
      <table><tr><td align="center" height="20">&nbsp;</td></tr></table>
     <div style="border-style:dotted; border-width:1px;">
     <table width="600">
       <tr><td align="left" colspan="4"><font  SIZE="+1" FACE="Comic Sans MS">Instructions</font></td></tr>
       <tr align="center"><td align="right"><IMG SRC="graphics/logbook_pencil.gif" align="middle" border="0"></td><td align="left"><font FACE="Comic Sans MS">Button to add a logbook entry.</font></td>
        <td align="right"><IMG SRC="graphics/logbook_view_comments_small.gif" border="0"  align="middle"></td><td align="left"><font FACE="Comic Sans MS">Button to view your teacher's comments.</font></td></tr>
        <tr><td align="center" colspan="4"><font size="-2" FACE="Comic Sans MS">Comments: Number of teacher comments (<font color="#AA3366"> number unread </FONT>). New comments by your teacher are marked as <IMG SRC="graphics/new_flag.gif" border=0 align="center"></font>.</td></tr>
     </table>
    </div>

      
<P>
      
      <table width="600" cellspacing="5">
      <%
     Statement sInner = null;
     ResultSet innerRs = null;
    // look for any previous log entries for this keyword
     querySort=" order by keyword.section,keyword.section_id,log_id DESC;";
     queryItems="select log.id as log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered,log_text,keyword.description as description, keyword.id as data_keyword_id, keyword.keyword as keyword_name,keyword.section as section, keyword.section_id as section_id from log,keyword";
     query=queryItems+queryWhere+querySort;
     //out.write(query);
     
     int itemCount=0;
     String current_keyword_id="";
     String sectionText="";
     current_section="";
     rs = s.executeQuery(query);
     while (rs.next()){
          String data_keyword_id=rs.getString("data_keyword_id");
          String dateText=rs.getString("date_entered");
          keyword_description=rs.getString("description");
          String log_id=rs.getString("log_id");
          String log_text=rs.getString("log_text");
          String keyword_name=rs.getString("keyword_name");
          String keyword_display=keyword_name.replaceAll("_"," ");
          String section=rs.getString("section");
          String section_id=rs.getString("section_id");
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
          <table cellpadding="5" width="600">
          <% if (!sectionText.equals(""))
          {
          %>
          <tr align="left"><td colspan="2"><font  FACE="Comic Sans MS" size=+2><%=sectionText%></font></td></tr>
          <%
          }
          %>
          <tr align="left"><td colspan="2"><font  FACE="Comic Sans MS" size=+1 color="#AA3366"><%=keyword_display%></FONT> - <font  FACE="Comic Sans MS"><%=keyword_description%></font>  <A HREF="logEntry.jsp?keyword=<%=keyword_name%>"><IMG SRC="graphics/logbook_pencil.gif" border="0"  align="middle"></A>&nbsp;&nbsp;<A HREF="showCommentsForKW.jsp?keyword=<%=keyword_name%>"><IMG SRC="graphics/logbook_view_comments_small.gif" border="0"  align="middle"></A></td></tr>
          <%
          
          }
// get comment information
          String comment_count="";
          String comment_new="";
          String comment_info="";
          sInner = conn.createStatement();

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
          if (!comment_count.equals("") && !comment_count.equals("0") ) {
              if (comment_new.equals("0")) {
              comment_info=comment_info+"<BR><FONT size=-2>comments: "+comment_count+"</font>";
              }
              else
              {
              if (comment_count.equals("")) {comment_count="0";}
              comment_info=comment_info+"<BR><IMG SRC=\'graphics/new_flag.gif\' border=0 align=\'middle\'> <FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) " +"</font>";
              }
             // out.write("New comments="+comment_new);
              }

          %>
         <tr>
         	<td valign="top" width="150" align="right">
         		<font  FACE="Comic Sans MS"><%=dateText%><%=comment_info%><FONT>
         	</td>
         	<td width="450" valign="top">
         		<font  FACE="Comic Sans MS"><e:whitespaceAdjust text="<%= log_text %>"/></FONT>
         	</td>
         </tr>
          <%
          }
          if (itemCount==0) {
          String keyword_name=keyword.replaceAll("_"," ");
          %>
          
          <tr align="center"><td colspan="2"><font  FACE="Comic Sans MS" size=+1>No entries for<BR>"<%=keyword_name%>: <%=keyword_description%>"</font>  <A HREF="logEntry.jsp?keyword=<%=keyword%>"><IMG SRC="graphics/logbook_pencil.gif" border="0"  align="middle"></A></td></tr>
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
