<HTML>
<HEAD>
<TITLE>Registration</TITLE>
<!-- include css style file -->
<%@ include file="common.jsp" %>
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="include/javascript.jsp" %>
</HEAD>
<body bgcolor=FFFFFF  vlink=ff6600>
<center>
<TABLE WIDTH=804>
<TR><TD>
	<TABLE WIDTH=800 CELLPADDING=4>
	<TR><TD  bgcolor=black>
	<FONT FACE=ARIAL COLOR=white SIZE=+1>
	<B>Cosmic Ray e-Lab Registration</B>
	</TD></TR></table>

</td></tr>

<P>

<% 
String login = (String)session.getAttribute("login");
String role = (String)session.getAttribute("role");
if (role != null && role.equals("teacher")) { //Short circuit operator.  Do not change order.%>
<tr><td>
	<table cellpadding="4" cellspacing="4" border="0">
	<tr><td  valign="top" width="300"><FONT FACE=ARIAL><A HREF="massRegistration.jsp">Register student research groups with a spreadsheet.</A></font></td><td valign="top"><FONT FACE=ARIAL SIZE=-1>
	Using an existing spreadsheet with your class lists is the easiest way to register groups. The spreadsheet must contain the first and last names of each student in the project and the name of each research group. Decide what role you want the research group to have--user or upload. If your students will be taking the pre- and post-tests for assessment, select <b>Yes</b> for the column <b>In survey</b>. A template on the next page will get you started.</FONT></td></tr>
	
	<tr><td  valign="top"><FONT FACE=ARIAL><A HREF="registerStudents.jsp">Register student research groups.</A></font></td><td valign="top"><FONT FACE=ARIAL SIZE=-1>
	Use this page to register less than ten students. You can link new students to existing research groups or you can create new research groups for students.</FONT></td></tr>

	<tr><td  valign="top">
	<FONT FACE=ARIAL>
	<a href="updateGroups.jsp">Update your previously created groups.</FONT></a></td><td valign="top"><FONT FACE=ARIAL  SIZE=-1>Update your research groups.</FONT></td></tr>
	</table>

</td></tr>

<% } 
else
{
%>
<tr height="12"><td>&nbsp;</td></tr>
<tr><td>
To register research groups, teachers or students, you need to have a teacher login. If you have a teacher login, log in with it.  If you need help, contact <A HREF="mailto:quarknet@fnal.gov">quarknet@fnal.gov</A>.
</td></tr>

<% } 
%>




</CENTER>

</BODY>
</HTML>

