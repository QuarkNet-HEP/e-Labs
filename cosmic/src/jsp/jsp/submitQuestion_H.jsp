<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<html>
<head>
<%@ include file="common.jsp" %>
<%@ include file="include/javascript.jsp" %>
<title>Submit a Question</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Resources";
%>
<%@ include file="include/navbar_common.jsp" %>
<BR>

</head>
<body>

<center>
<BR>
<% 
Login user = DBObject.findById("Login", session.getAttribute("login")); 
String text = request.getParameter("text");
String type = request.getParameter("type");
String title = request.getParameter("title");

if (request.getParameter("submit") != null && !request.getParameter("submit").equals(""))
{
   %>
    // checks if all the fields are filled out
    if (request.getParameter("type") ==null || request.getParameter("type").equals(""))
    {
        warn(out,"Please specify if this entry is a suggestion, question, bug report or feedback.");
    }
    else if (request.getParameter("title") ==null || request.getParameter("title").equals(""))
    {
        warn(out,"Please enter a title.");
    }
    else if (request.getParameter("text") ==null || request.getParameter("text").equals(""))
    {
        warn(out,"Please describe how we can help you.");
    }
    else 
    {
    Feedback f = new Feedback();
    f.setType(type);
    f.setSummery(title);
    f.setBody(text);
    f.save(); 
        %>
<font color=green>Your <%=type%> has been sucessfully submitted.  Thank you, <%=name%>.</font>
<% 
        text="";
        type=""; 
        title="";
    }
out.print("<br>");
} 
if (text == null)
    text = "";
if (title == null)
    title = "";
if (type == null || type.equals(""))
    type = "question";
%>
<table border='0'>
<form name='main_form' method=get>
<tr><td colspan='2' align='center'>We would love to hear your input.  <br>Whether its a suggestion, bug, 
    feedback or question, <br>we will try to get back to you as soon as possible.</td></tr>
<tr><td>Type:</td><td><label><input type='radio' name='type' value='question' <% if (type.equals("question")) out.print("checked='true'"); %> >Question</label></td></tr>
<tr><td>&nbsp;</td><td><label><input type='radio' name='type' value='feedback'<% if (type.equals("feedback")) out.print("checked='true'"); %>>Feedback</label></td></tr>
<tr><td>&nbsp;</td><td><label><input type='radio' name='type' value='bug'<% if (type.equals("bug")) out.print("checked='true'"); %>>Problem/Bug</label></td></tr>
<tr><td>&nbsp;</td><td><label><input type='radio' name='type' value='suggestion'<% if (type.equals("suggestion")) out.print("checked='true'"); %>>Suggestion</label></td></tr>
<tr><td>Title:</td><td><input type='text' name='title' value=<%=title%>></td></tr>
<tr><td>Input:</td><td><textarea cols='20' rows='10' name='text'><%=text%></textarea></td></tr>
<tr><td colspan='2'><input type='submit' value='Submit' name='submit'></td></tr>
</form>
</center>

</body>
</html>
