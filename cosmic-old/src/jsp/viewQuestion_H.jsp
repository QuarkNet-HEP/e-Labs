<%@ page import="java.io.*, java.util.*" %>
<%@ include file="common_H.jsp" %>
<%@ page import="gov.fnal.elab.db.*"%>
<html>
<head>
	<title>Resolve Feedback</title>
<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Resources";
%>
<%@ include file="include/navbar_common.jsp" %>
<BR>
<table cellpadding='10'>
<%
String submit  = request.getParameter("submit");
String getID = request.getParameter("ID");
if (submit != null)
{
    String name = "";
    String email = "";
    String ID = request.getParameter("ID");
    String text = request.getParameter("text");
    
    Feedback feedback = (Feedback) DBObject.findById("Feedback", ID);
    Comment comment = new Comment();
    comment.setBody(text);
    comment.setParentComment(feedback);
    comment.save();
    
    Login Log = comment.getMaker();
    if (Log instanceof User)
    {
        User Use = (User) Log;
        if (Use.getFirstName() != null)
            name += Use.getFirstName();
        if (Use.getLastName() != null)
            name += Use.getLastName();
         if (Use.getEmail() != null)
            email += Use.getEmail();
    }
    if (name.equals(""))
         name = Log.getUsername();
    %>
    <a href='viewQuestion.jsp'>Back</a><br>
    <br><center><font color='green'>Thank you, <%=name%>.<br>
    Your response has been stored.</font></center>
        <%
}
else if (getID == null || getID.equals(""))
{

out.write("<font size='+2'>Recent Feedback.</font>");

java.util.List rs = DBObject.getAll("Feedback", 0, 10000);

for (Iterator i = rs.iterator(); i.hasNext(); )
{
    Feedback r = (Feedback)i.next();
    Long ID = r.getId();
    int replys = r.getChildComments().size();
    boolean replyed = r.getIsRead();
    Login him = r.getMaker();
    String type = r.getType();
    String title = r.getSummary();
    String date = r.getDateEntered().toString();
    String text = r.getBody();
    if (type == null)
        type = "";   
    if (title == null)
        title = "";   
    if (text == null)
        text = "";  
    out.write("<tr>" + "<td>" + (replyed?"<font color='green'>replyed </font>":"<font color='red'>not replyed</font>")+"</td><td width='120'>" +type+"</td><td><a href='viewQuestion.jsp?ID="
            +ID+"'>"+title+"</a></td>");
    %>
<td><input type='button' name='add_FAQ' value='Add to FAQ' onClick='viewQuestion.jsp?ID=<%=ID%>&replyID='> </td></tr>
        <%
}
}
else { // getID is not null
    Feedback r = (Feedback) DBObject.findById("Feedback", getID);
    Long ID =  r.getId();
    int replys = r.getChildComments().size();
    boolean replyed = r.getIsRead();
    Login login = r.getMaker();
    String name = "";
    String email = "";
    if (login instanceof User)
    {
        User Use = (User) login;
        if (Use.getFirstName() != null)
            name += Use.getFirstName();
        if (Use.getLastName() != null)
            name += Use.getLastName();
         if (Use.getEmail() != null)
            email += Use.getEmail();
    }
    String type = r.getType();
    String title = r.getSummary();
    String date = r.getDateEntered().toString();
    String text = r.getBody();
    if (type == null)
        type = "";   
    if (title == null)
        title = "";   
    if (text == null)
        text = "";         
%>
<tr><td colspan='2' align='center'><b><%=title%></b></td></tr>
<tr><td>Type:</td><td><%=type%></td></tr>
<tr><td>Name:</td><td><%=name%></td></tr>
<tr><td>Email:</td><td><%=email%></td></tr>
<tr><td>Date Submitted:</td><td><%=date%></td></tr>
<tr><td>Content:</td><td><%=text%></td></tr>
<form method='get'>
<input type='hidden' name='ID' value=<%=getID%>>
<tr><td>Your Name:</td><td><input type='text' name='name'></td></tr>
<tr><td>Your Response:</td><td><textarea rows='10' cols='30'></textarea></td></tr>
<tr><td>&nbsp;</td><td><input type='submit' name='submit' value="Submit Response"></td></tr>
  <%
}
%></table>
