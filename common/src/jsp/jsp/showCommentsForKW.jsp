<%@ page import="java.util.*" %>
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
// This will display all the comments associated with a particular keyword.
// e.g. select log.id,log.date_entered,log.log_text,comment.date_entered,comment.id,comment.comment from comment,log,keyword 
// where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=17 and log.research_group_id=57 and project_id=1; 
 String keyword =  request.getParameter("keyword");
 String keyword_id="";
 String keyword_description="";
 String research_group_id="";
 String query="";
 Statement sInner = null;
 ResultSet innerRs = null;
  sInner = conn.createStatement();

 String new_comment="";

     // get group ID
                //groupName defined in common.jsp
     research_group_id="";
     query="select id from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=groupName%><BR><% return;}
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
   if (keyword==null) {keyword="general";} //default to general keyword if none is included.
      String keyword_text=keyword.replaceAll("_"," ");
     
     // first make sure a keyword was passed in the call
     query="select id,description from keyword where project_id in (0,"+project_id+") and keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");}
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}
    %>
    <h1><font  FACE="Comic Sans MS">Comments on Your Logbook Entries for<BR>
      "<%=keyword_description%>"</FONT></h1>
     <div style="border-style:dotted; border-width:1px; width: 500px">
<h2>Instructions</h2>
    <p><font  FACE="Comic Sans MS">Comments in <b><FONT color="red">red</FONT></b> are new. Be sure you read them.</FONT></p>
<p><IMG SRC="graphics/logbook_pencil.gif" border="0"  align="middle"><font FACE="Comic Sans MS"> Button to add a logbook entry for "<%=keyword_text%>".</font></p>
<p><IMG SRC="graphics/logbook_view.gif" border="0"  align="middle"><font FACE="Comic Sans MS"> Button to view your logbook".</font></p></div>
<P>
      
      <table width="800" cellspacing="5" cellpadding="5">
      <%
    
    // look for any previous log entries for this keyword
     query="select log.id as log_id,to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as log_date,log.log_text as log_text,to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') as comment_date,comment.id as comment_id,comment.comment as comment,comment.new_comment as new_comment from comment,log,keyword ";
     query=query+ "where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=" + keyword_id + " and log.research_group_id=" + research_group_id + " and log.project_id="+project_id+ " and keyword.project_id in (0,"+project_id+")"; 
     query=query + " order by log_id DESC,comment_id DESC;";
    int itemCount=0;
     String curLogId="";
     rs = s.executeQuery(query);
     while (rs.next()){
          String log_id=rs.getString("log_id");
          String log_date=rs.getString("log_date");
          String log_text=rs.getString("log_text");
         String comment_id=rs.getString("comment_id");
          String comment_date=rs.getString("comment_date");
          String comment_text=rs.getString("comment");
          new_comment=rs.getString("new_comment");
          itemCount++;
          if (curLogId.equals(log_id)) {
            log_text=" ";
            log_date=" ";
           }
           else
           {
            curLogId=log_id;
            if (itemCount!=1) {%>
            <tr><td colspan="4" align="center"> <HR width="700" color="#1A8BC8" size=1  ></td></tr>
             <% }
           }
          if (itemCount==1) {
            %>
                         <tr><td align="center">&nbsp;</td><td align="center"><IMG SRC="graphics/logbook.gif"></td><td align="center">&nbsp;</td><td align="center"><IMG SRC="graphics/logbook_comments.gif"></td></tr>
<tr><th align="right" valign="top"><FONT FACE="Comic Sans MS">Log Date</font></th><th align="left"  valign="top"><FONT FACE="Comic Sans MS">Log Entry</font></th>
            <th align="right"  valign="top"><FONT FACE="Comic Sans MS">Date</font></th><th align="left"  valign="top"><FONT FACE="Comic Sans MS">Your Teacher's Comments</font> <A HREF="logEntry.jsp?keyword=<%=keyword%>"><IMG SRC="graphics/logbook_pencil.gif" border="0"  align="middle"></A></th></tr>
            <%
           } //itemCount
           String commentColor="black";
          if (new_comment!=null && new_comment.equals("t"))
           {commentColor="red";}
           %>
             <tr><td valign="top" width="100" align="right"><FONT FACE="Comic Sans MS"><%=log_date%><FONT></td><td width="300"  valign="top"><FONT FACE="Comic Sans MS"><%=log_text%></FONT></td>
             <td valign="top" width="100" align="right"><FONT FACE="Comic Sans MS" color="<%=commentColor%>"><%=comment_date%><FONT></td><td width="300"  valign="top"><FONT FACE="Comic Sans MS" color="<%=commentColor%>"><%=comment_text%></FONT></td>
            </tr>
          <%

         if (new_comment!=null && new_comment.equals("t"))
          {
          //reset  new_comment to false
           String innerQuery="UPDATE comment SET new_comment=\'f\'  WHERE id=" + comment_id + ";";
          int k=0;
          try{
                k = sInner.executeUpdate(innerQuery);
             } 
             catch (SQLException se){
                 warn(out, "There was some error updating your info into the comment table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              } // try-catch for updating survey table
              if(k != 1){
                  warn(out, "Weren't able to update your info to the database! " + k + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                  return;
               } //!k=1 test 



            }  // New comment









       }  //while

      if (itemCount==0) {
        %>
         <tr><td colspan="4" align="center"><FONT FACE="Comic Sans MS" size="+1">No comments.</FONT></td></tr>
        <%
          }
       %>
      </table>
    
    
   <BR>
    <HR width="400" color="#1A8BC8" size=1  >
<table><tr><td valign="center" align="center"><A HREF="showLogbook.jsp"><font  FACE="Comic Sans MS" size=+1><IMG SRC="graphics/logbook_view.gif" border=0" align="middle"> Show Logbook</font></A></td></tr></table>
</center>
	</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
