<%@ page buffer="1000kb" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.Ostermiller.util.RandPass" %>
<%@ page import="java.sql.*" %>

<HTML>
<HEAD>
<TITLE>Test Results</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%@ include file="include/javascript.jsp" %>
</HEAD>
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="common.jsp" %>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>


<% 
// page displays survey results.  -Hao


String login = (String)session.getAttribute("login");
String role = (String)session.getAttribute("role");
if (role == null || !role.equals("teacher")) { //Short circuit operator.  Do not change order.%>
<tr><td>
To see the test results of students, you need to have a teacher login. If you have a teacher login, log in with it.  If you need help, contact <A HREF="mailto:quarknet@fnal.gov">quarknet@fnal.gov</A>.
</td></tr>
</table>
<%
return;
}
%>

<%
boolean valid = true;
boolean debug = false;

int teacherID = -1;
String teacherUA = null;
String correctTable = "";
String debugInfo = "";
String maxDebug = ""; // this is just store the maximum question number, to know the number of columns needed
String maxString="";
int max = 0; // this is just store the maximum question number, to know the number of columns needed


/*
 * Each person will be an item in the arrylist
 * item 0 will be the name (string)
 * item 1 will be total number correct (string)
 * item 2+ will be the n-1 question's response (string)
 */

ArrayList studentList = new ArrayList(); //each item will be an array list of rows
ArrayList student;

try {
    // Use transactions to recover from failure.
    
    rs = s.executeQuery("select teacher_id, userarea from research_group where name = '" + login + "'");
    if (rs.next()) {
        teacherID = rs.getInt("teacher_id"); 
        teacherUA = rs.getString("userarea");
    }
    if (teacherUA == null || teacherID == -1)
        {valid = false;
        debugInfo=debugInfo+" teacherUA test";}

    rs = s.executeQuery("select DISTINCT student_id,student.name as name from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id= '" + teacherID + "') order by name;");



    if (debug)	
	correctTable += "<br><table border='1'><tr><td>Student Name</td><td>Number Correct</td></tr>";
    while (rs.next())
    {
	// creates the student
	student = new ArrayList();
	student.ensureCapacity(2);
	student.add(0, rs.getString("name"));
    int student_id = Integer.parseInt(rs.getString("student_id"));
     rs = s.executeQuery("select count(*) from answer,question,student where answer.question_id=question.id and answer.answer=question.answer and student.id=answer.student_id and student.id=;'" + student_id + "';");
	student.add(1, rs.getString("count"));
	
	// adds the student
	studentList.add(student);
	if (debug)
    		correctTable += "<tr><td>" + rs.getString("name") + "</td><td>" + rs.getString("count") + "</td></tr>";
    }
   if (debug)
	correctTable += "</table><br>";

   	rs = s.executeQuery("select student.name as name,question.id as question_number, CASE WHEN answer.answer=question.answer THEN '<a href=surveyQuestion.jsp?responseNo=' || answer.answer || '&questionNo=' || question.question_no || '><font color=green>' || answer.answer || '</font></a>' ELSE '<a href=surveyQuestion.jsp?responseNo=' || answer.answer || '&questionNo=' || question.question_no || '><font color=red>' || answer.answer || '</font></a>' END as response from answer,question,student where answer.question_id=question.id and student.id=answer.student_id and student.id in (select DISTINCT student_id from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id=" + teacherID + ")) order by name;");
    debug=true;
    if (debug)
	correctTable += "<br><table border='1'><tr><td>Student Name</td><td>Question Number</td><td>Response</td></tr>";
    ListIterator i = studentList.listIterator();
    student = null;
    max = 0; // this is just store the maximum question number, to know the number of columns needed
    while (rs.next())
    {
	// checks if it is the same student
	if ( student != null && student.get(0).equals(rs.getString("name")) )
	{
		int index = Integer.parseInt(rs.getString("question_number")) + 1;
		if (index > max)
			max = index;
		student.ensureCapacity(index);
		student.add(index, rs.getString("response"));
	}
	else // moving onto another student
	{
		if (i.hasNext())
			student = (ArrayList)(i.next());

		int index = Integer.parseInt(rs.getString("question_number")) + 1;
		if (index > max)
			max = index;
		student.ensureCapacity(index);
		student.add(index, rs.getString("response"));
	}
	
//debug=true;
        if (debug)
	{
    		correctTable += "<tr><td>" + rs.getString("name") + "</td><td>" + rs.getString("question_number"); 
		correctTable += "</td><td>" + rs.getString("response") + "</td></tr>";
	}
    }

    if (debug)
	correctTable += "</table><br>";
	 maxString=Integer.toString(max);
	 maxDebug=maxDebug+ "<BR>next="+ maxString;
	// finally, prints the combined table stored in studentList
	correctTable += "<br><table border='1'><tr><td>Student Name</td><td>Total Correct</td>";
	for (int a = 1; a < max; a++)
		correctTable += "<td align ='right'>Q" + a + "</td>";	
	correctTable += "</tr>";

	ListIterator j = studentList.listIterator();
	while (j.hasNext())
	{
		student = (ArrayList)(j.next());
    		correctTable += "<tr>";
		for (int a = 0; a <= max; a++)
		{
			String info = new String("");
			if (student.get(a) != null)
				info = student.get(a).toString();
				debugInfo=debugInfo + "<BR>"+info;
			correctTable += "<td align ='right'>" + info + "</td>";
		}	
		correctTable += "</tr>";
	}
	correctTable += "</table><br>";

} catch (Exception e) {
    valid = false;
     debugInfo=debugInfo+" exception" + e.getMessage();
     
}

if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
<body bgcolor=FFFFFF  vlink=ff6600>
<center>
Valid is <%=valid%><BR>
Max is <%=maxDebug%>
<%=debugInfo%>
<TABLE WIDTH=804>
<TR><TD>
	<TABLE WIDTH=800 CELLPADDING=4>
	<TR><td>&nbsp;</td></tr>
	<TR><TD  bgcolor=black>
	<FONT FACE=ARIAL COLOR=white SIZE=+1>
	<B>Presurvey Results:   <%=login%>'s students</B>
	</TD></TR></table>

</td></tr>
<%=correctTable%>
<br>
Note: Correct answers are displayed in green, incorrect answers are displayed in red.
</td></tr>
</table>
</center>
</body>
</html>
