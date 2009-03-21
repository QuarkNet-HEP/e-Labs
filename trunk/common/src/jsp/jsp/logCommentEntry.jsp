<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Enter Logbook</title>
    </head>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
    <body>
        <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
//start jsp by defining submit
// sample sql - INSERT INTO comment (log_id,comment) VALUES (22,'I like how you solved this.');
// parameters passed are log_id, optional comment_text, 

String role = (String)session.getAttribute("role");
if (!role.equals("teacher")) { 
    out.write("This page is only available to teachers.");
    return;
    }
String submit =  request.getParameter("button");
String log_id_param =  request.getParameter("log_id");
String comment_id =request.getParameter("comment_id");
String path =request.getParameter("path");
if (path==null) { path="RG";}
String comment_text =  request.getParameter("comment_text");
String research_group_name =  request.getParameter("research_group_name");
String research_group_id="";
String keyword_id="";
String keyword_text="";
String buttonText="Add Your Comment to a Logbook Entry";
String query="";

     // get group ID
                //groupName defined in common.jsp
     research_group_id="";
     query="select id from research_group where name=\'"+research_group_name+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=research_group_name%><BR><% return;}
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
// Always pass keyword, not id so we can pick off the description
   String keyword_description="";
   String keyword =  request.getParameter("keyword");
   if (keyword==null) {keyword="general";} //default to general keyword if none is included.
       keyword_text=keyword.replaceAll("_"," ");
     
     // first make sure a keyword was passed in the call
     query="select id,description from keyword where keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");
     }
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}
    %>

<%
// This will display all the comments associated with a particular keyword research_group, both passed.
// e.g. select log.id,log.date_entered,log.log_text,comment.date_entered,comment.id,comment.comment from comment,log,keyword 
// where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=17 and log.research_group_id=57 and project_id=1; 

      String currentEntries="";

    %>

    <h1>Comments on group <%=research_group_name%>'s logbook entries for<BR>
      "<%=keyword_text%>: <%=keyword_description%>"</h1>
<P>

      <%
   // look for any previous log entries for this keyword
     query="select log.id as log_id,to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as log_date,log.log_text as log_text from log,keyword ";
     query=query+ "where log.keyword_id=keyword.id and keyword.id=" + keyword_id + " and log.research_group_id=" + research_group_id + " and log.project_id="+project_id; 
     query=query + " order by log_id DESC;";
     Statement sInner = null; // for comment query
     ResultSet innerRs = null; // for comment query
int itemCount=0;
     String hrHtml="";
     //out.write(query);
     rs = s.executeQuery(query);
     while (rs.next()){
          String log_id=rs.getString("log_id");
          String log_date=rs.getString("log_date");
          String log_text=ElabUtil.whitespaceAdjust(rs.getString("log_text"));
          String log_date_show=log_date;
          String log_text_show=log_text;
          itemCount++;
           currentEntries=currentEntries+hrHtml;
          if (itemCount==1) {
             currentEntries=currentEntries+"<tr><th valign='center' align='right'><IMG SRC='graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"+research_group_name+"\'s log entries</th><th><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
           } //itemCount
          
           // look for comments associated with this log item
           
          sInner = conn.createStatement();
          String innerQuery="select to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') as comment_date,comment.comment as comment from comment where log_id="+log_id+";";
          //out.write("\r\r"+innerQuery);
          innerRs = sInner.executeQuery(innerQuery);
          int commentCount=0;
             String comment_date="";
             String comment_existing="";
          while (innerRs.next()){
             comment_date=innerRs.getString("comment_date");
             comment_existing=ElabUtil.whitespaceAdjust(innerRs.getString("comment"));
             commentCount++;
          if (commentCount>1) {
            log_text_show=" ";
            log_date_show=" ";
            hrHtml="";
           }
           else
           {
            hrHtml="<tr><td colspan='5'><HR color='#1A8BC8'></td></tr>";
           }
           
               currentEntries=currentEntries+"<tr><td valign='top' width='100' align='right'>"+ log_date_show + "</td><td width='300'  valign='top'>"+log_text_show + "</td>";
             // out.write ("Comment Count ="+commentCount);
             // out.write ("comment_existing="+comment_existing);
				currentEntries=currentEntries+"<td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>"+comment_date+"</td><td width='300'  valign='top'>"+comment_existing+"</td></tr>";

             } //while for comments
              if (commentCount==0)
				{  currentEntries=currentEntries+"<tr><td valign='top' width='100' align='right'>"+ log_date + "</td><td width='300'  valign='top'>"+log_text + "</td><td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
				}

         if (itemCount==0) {
          currentEntries=currentEntries+"<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
          }
        }  //while for log
      

      if (comment_id==null) {comment_id="";}
   if (submit!=null && !(comment_text.equals(""))) {  
   // need to update or insert an entry yet
      
      String comment_enter=comment_text.replaceAll("'","''");
      if ( comment_id == "") {
      //we have to insert a new row into table
         int i=0;
         query="INSERT INTO comment (log_id,comment,new_comment) VALUES (" + log_id_param + ",\'"  + comment_enter + "\',\'t\');";
           try{
                i = s.executeUpdate(query);
              } catch (SQLException se){
                 warn(out, "There was some error entering your info into the comment table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              }
              if(i != 1){
                 warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                    return;
              }
      // get the comment_id of the entry you just entered
      query="select comment.id as id from comment where log_id="+log_id_param+" and comment=\'"+ comment_enter +"\' order by comment.id DESC;";
       rs = s.executeQuery(query);
      if (rs.next()){
       comment_id=rs.getString("id");}
       if (comment_id.equals("")) {%> Problem with ID for comment entered.<BR><% return;}
   %>
     <h2><font   color="#1A8BC8">Your comment was successfully entered. You can edit it and update it.<BR>Use the buttons under the form to display the Research Group's Logbook</FONT></h2>
 <%
            
      }
      else if (!comment_text.equals(""))
      {
      //we need to update row with id=comment_id 
           query="UPDATE comment SET comment=\'"+comment_enter + "\' WHERE id=" + comment_id + ";";
          int k=0;
          try{
                k = s.executeUpdate(query);
             } 
             catch (SQLException se){
                 warn(out, "There was some error entering your info into the comment table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              } // try-catch for updating survey table
              if(k != 1){
                  warn(out, "Weren't able to add your info to the database! " + k + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                  return;
               } //!k=1 test 
  %>
     <h2><font color="#1A8BC8">Your comment was successfully updated. You can edit it some more and update it.<BR>Use the buttons under the form to display the Research Group's Logbook</FONT></h2>
 <%
            

      }
      
      
      buttonText="Update Your Comment on a Log Entry";
    
   }
   
     query="select log.id as log_id,to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as log_date,log.log_text as cur_log_text from log ";
     query=query+ "where log.id="+log_id_param +";"; 
     rs = s.executeQuery(query);
     String cur_log_text="";
     if (rs.next()){
          cur_log_text=rs.getString("log_date")+ " - "+ ElabUtil.whitespaceAdjust(rs.getString("cur_log_text"));
          }
   
   
   
   
   
   
   if (comment_text==null) {comment_text="";}
   %>
   <P>
              <form method=get name="log">
              <table  width=400>
              <tr><th>Your new comment for</th></tr>
              <tr><td align="left"><%=cur_log_text%></td></tr>
             <% if (comment_id != "") {
             %>
            <tr><td><input type="hidden" name="comment_id" value="<%=comment_id%>"></td></tr>
            <% 
            }
            %>
            <tr><td><input type="hidden" name="log_id" value="<%=log_id_param%>"></td></tr>
            <tr><td><input type="hidden" name="research_group_name" value="<%=research_group_name%>"></td></tr>
            <tr><td><input type="hidden" name="keyword" value="<%=keyword%>"></td></tr>
            <tr><td><textarea name="comment_text" cols="80" rows="10"><%=comment_text%></textarea></td></tr>
            <tr><td align="center"><INPUT type="submit" name="button" value="<%=buttonText%>"></td></tr>
            </table>
            </form>
            
   <BR>
<table width="500">
<tr><td valign="center" align="center"><A HREF="showLogbook<%=path%>forT.jsp?research_group_name=<%=research_group_name%>&keyword=<%=keyword%>"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">Go Back<BR>For "<%=keyword%>" for group "<%=research_group_name%>"</A> </td>

<%
if (path.equals("KW"))
{
%>
<td valign="center" align="center"><A HREF="showLogbook<%=path%>forT.jsp?keyword=<%=keyword%>"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">Go Back<BR>For "<%=keyword%>" for all research groups.</A></td></tr></table>

<%
}
else
{
%>
<td valign="center" align="center"><A HREF="showLogbook<%=path%>forT.jsp?research_group_name=<%=research_group_name%>"><IMG SRC="graphics/logbook_view_small.gif" border=0" align="middle">Go Back<BR>For all keywords for group "<%=research_group_name%>".</A></td></tr></table>

<%
}
%>



<BR>
      <table width="800" cellspacing="5" cellpadding="5">
      <tr><th colspan="5" align="center"><%=research_group_name%>'s log entries and teacher's comments entered previously</th></tr>
      <%=currentEntries%>
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
