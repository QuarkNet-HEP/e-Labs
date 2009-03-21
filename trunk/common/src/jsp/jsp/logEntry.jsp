<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Enter Logbook</title>
    </head>
    <script language='javascript'>
function insertImgSrc()
{
    var raw = document.log.img_src.value;
    var parsed = raw.split(",");
    for (var i = 0; i < parsed.length; i++)
    {
        var txt = document.log.log_text.value;
        txt = txt.replace("(--Image "+i+"--)", parsed[i]);
        document.log.log_text.value = txt;
    }
};
    </script>
    
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
    <body>
        <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%
//start jsp by defining submit
String role = (String)session.getAttribute("role");
if (role.equals("teacher")) { 
    out.write("This page is only available to student research groups.");
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
String keyword_id="";
String buttonText="Add Your Logbook Entry";
String currentEntries="";

if (research_group_id==null) {
     // get group ID
                //groupName defined in common.jsp
     research_group_id="";
     String query="select id from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       research_group_id=rs.getString("id");}
       
       if (research_group_id.equals("")) {%> Problem with ID for research group <%=groupName%><BR><% return;}
    }
 String project_id =  request.getParameter("project_id");
 if (project_id==null) {
     // get project ID
                //eLab defined in common.jsp
     project_id="";
     String query="select id from project where name=\'"+eLab+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       project_id=rs.getString("id");}
      if (project_id.equals("")) {%> Problem with id for project <%=eLab%><BR><% return;}
    }
// Always pass keyword, not id so we can pick off the description
   String keyword_description="";
   String keyword =  request.getParameter("keyword");
   if (keyword==null) {keyword="general";} //default to general keyword if none is included.
     
     // first make sure a keyword was passed in the call
     String query="select id,description from keyword where keyword=\'"+keyword+"\';";
     rs = s.executeQuery(query);
     while (rs.next()){
       keyword_id=rs.getString("id");
       keyword_description=rs.getString("description");}
       if (keyword_id.equals("")) {%> Problem with id for log. <%=keyword%><BR><% return;}
    %>
    
     <table width="600" align="center"><tr><td align="center"><IMG SRC="graphics/logbook_large.gif" align="middle" border="0"><font size="+2" FACE="Comic Sans MS" align="left"> For
      "<%=keyword_description%>"</font></td></tr></table>


    
    <%
    if (log_id==null) {log_id="";}
    
    
    
    // second version
    
      // look for any previous log entries for this keyword
     query="select log.id as cur_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') as date_entered,log.log_text as cur_text from log where project_id="+project_id+" and keyword_id="+keyword_id+ " and research_group_id="+research_group_id+" and role=\'user\' order by cur_id DESC;";
 
     Statement sInner = null; // for comment query
     ResultSet innerRs = null; // for comment query
int itemCount=0;
     String hrHtml="";
     //out.write(query);
     rs = s.executeQuery(query);
     while (rs.next()){
          String cur_log_id=rs.getString("cur_id");
          String log_date=rs.getString("date_entered");
          String cur_log_text=ElabUtil.whitespaceAdjust(rs.getString("cur_text"));
          String log_date_show=log_date;
          String log_text_show=cur_log_text;
          itemCount++;
           currentEntries=currentEntries+hrHtml;
          if (itemCount==1) {
             currentEntries=currentEntries+"<tr><th valign='center' align='right'><IMG SRC='graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"+groupName+"\'s log entries</th><th><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
           } //itemCount
          
           // look for comments associated with this log item
           
          sInner = conn.createStatement();
          String innerQuery="select to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') as comment_date,comment.comment as comment from comment where log_id="+cur_log_id+";";
          //out.write("\r\r"+innerQuery);
          innerRs = sInner.executeQuery(innerQuery);
          int commentCount=0;
             String comment_date="";
             String comment_existing="";
          while (innerRs.next()){
             comment_date=innerRs.getString("comment_date");
             comment_existing=innerRs.getString("comment");
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
				{  currentEntries=currentEntries+"<tr><td valign='top' width='100' align='right'>"+ log_date + "</td><td width='300'  valign='top'>"+cur_log_text + "</td><td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
				}

         if (itemCount==0) {
          currentEntries=currentEntries+"<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
          }
        }  //while for log
      
 
    
    
    
    
    
    
    
    
    
    // end of second version
       
       
       
       
       
       
       
   if ((submit!=null) && !(log_text.equals(""))) {  
   // need to update or insert an entry yet
      String log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">" + log_text + "</div>";
 
      String parsed[] = img_src.split(",");
      for (int i = 0; i < parsed.length; i++)
      {
        log_enter = log_enter.replaceAll("\\(--Image "+i+"--\\)", parsed[i]);
      }     
      log_enter=log_enter.replaceAll("'","''");
 
      if (log_id == "" && log_text != "") {
      //we have to insert a new row into table
         int i=0;
         query="INSERT INTO log (project_id, research_group_id, keyword_id, role,log_text,new_log) VALUES ("+project_id + "," + research_group_id + "," + keyword_id + ",\'user\','"  + log_enter + "\','t');";
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
      query="select log.id as id from log where research_group_id="+research_group_id+" and project_id="+project_id+" and keyword_id="+keyword_id+" and role=\'user\' order by log.id DESC;";
       rs = s.executeQuery(query);
      if (rs.next()){
       log_id=rs.getString("id");}
       if (log_id.equals("")) {%> Problem with ID for log entered.<BR><% return;}
  %>
     <h2><font  FACE="Comic Sans MS">Your log was successfully entered. You can edit it and update it.<BR>Click <FONT color="#1A8BC8">Show Logbook</font> to access all entries in your logbook.</FONT></h2>
 <%
            
      }
      else if (!log_text.equals(""))
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
     <h2><font  FACE="Comic Sans MS">Your log was successfully updated. You can edit it some more and update it.<BR>Click <FONT color="#1A8BC8">Show Logbook</font> to access all entries in your logbook.</FONT></h2>
 <%
            

      }
      buttonText="Update Our Logbook Entry";
      log_enter=log_enter.replaceAll("''","'");
      %><table border=1><tr><td align='left'><%=log_enter%></td></tr></table>
          
        <%
   }
   if (log_text==null) {log_text="";}
   %>
   <P>
              <form method=post name="log">
              <table  width='400'>
              <tr><th><font  FACE="Comic Sans MS">Your New Log Book Entry</FONT></th></th>
             <% if (log_id != "") {
             %>
            <tr><td colspan='2'><input type="hidden" name="log_id" value="<%=log_id%>"></td></tr>
            <% 
            }
            %>
            <tr><td colspan='2'><input type="hidden" name="project_id" value="<%=project_id%>"></td></tr>
            <tr><td colspan='2'><input type="hidden" name="research_group_id" value="<%=research_group_id%>"></td></tr>
            <tr><td colspan='2'><input type="hidden" name="keyword" value="<%=keyword%>"></td></tr>
            <tr><td colspan='2'><input type="hidden" name="role" value="<%=role%>"></td></tr>
            <tr><td colspan='2'><textarea name="log_text" cols="80" rows="10"><%=log_text%></textarea></td></tr>
            <tr><td align='left'><INPUT type='button' name="plot" onClick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;" value="Insert a plot"></td>
            <td align='right'><INPUT type="submit" name="button" value="<%=buttonText%>"></td></tr>
            </table>
            <input type="hidden" name="img_src" value="<%=img_src%>">
            <input type="hidden" name="count" value="<%=count%>">
            </form>
            
   <BR>
<table><tr><td valign="center" align="center"><A HREF="showLogbook.jsp"><font  FACE="Comic Sans MS" size=+1><IMG SRC="graphics/logbook_view.gif" border=0" align="middle"> Show Logbook</font></A></td></tr></table>

<P>
<%
if (!currentEntries.equals("")) {
%>
<HR width="400" color="#1A8BC8" size=3>
<table width="600" cellspacing="5" cellpadding="5">
    <%=currentEntries%>
    </table>



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
