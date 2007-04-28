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
// edited to fix bug when some of the students get all the questions wrong. - Liz

String color = request.getParameter("color");    // The results can rely on color   surveyResults.jsp or surveyResults.jsp?color=yes to show color and surveyResults.jsp?color=no to show *s
// this is only important if a teacher wants to print out the results and does not have a color printer. 
if (color==null || color.equals("") ) color="yes";
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
String teacher_name="";
String correctTable = "";
String student_name="";
String queryString="";// for more debugging
String htmlQuery=""; // to support color and black and white
String debugInfo=""; // for more debugging
String prePost = request.getParameter("type"); 
if (prePost == null || prePost.equals("") ) {prePost="pre";}

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
        valid = false;

    rs = s.executeQuery("select name from teacher where id = '" + teacherID + "'");
    if (rs.next()) {
        teacher_name = rs.getString("name"); 
    }
    if (teacher_name == null)
        valid = false;





    queryString=queryString+"<BR>select student.name as name,count(*) from answer,student,question where  question.test_name='"+ prePost + "test' and question.id=answer.question_id and student.id=answer.student_id and student.id in (select DISTINCT student_id from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id= '" + teacherID + "')) group  by name order by name;";

        rs = s.executeQuery("select student.name as name,count(*) from answer,student,question where question.test_name='"+ prePost + "test' and question.id=answer.question_id and  student.id=answer.student_id and student.id in (select DISTINCT student_id from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id= '" + teacherID + "')) group  by name order by name;");

   if (debug)	
	correctTable += "<br><table border='1'><tr><td>Student Name</td><td>Number Correct</td></tr>";
    while (rs.next())
    {
	// creates the student
	student = new ArrayList();
	student.ensureCapacity(1);
	student.add(0, rs.getString("name"));
	
	// adds the student
	studentList.add(student);
    }
    ListIterator k = studentList.listIterator();
     	   while (k.hasNext())
     	   {
			student = (ArrayList)(k.next());
			student_name=student.get(0).toString();
         rs = s.executeQuery("select count(*) from answer,question,student where answer.question_id=question.id and question.test_name='"+ prePost +"test'and answer.answer=question.answer and student.id=answer.student_id and student.name='"+student_name+"';");
    queryString=queryString+ "<BR>select count(*) from answer,question,student where answer.question_id=question.id and question.test_name='"+ prePost +"test'and answer.answer=question.answer and student.id=answer.student_id and student.name='"+student_name+"';";
    if (rs.next()) {
	     student.ensureCapacity(2);
    	 student.add(1, rs.getString("count"));
 		if (debug)
    		correctTable += "<tr><td>" + student_name + "</td><td>" + rs.getString("count") + "</td></tr>";
		
			}
			}

   if (debug)
	correctTable += "</table><br>";
    htmlQuery="select student.name as name,question.id as question_id,question.question_no as question_number, CASE WHEN answer.answer=question.answer THEN '<a href=surveyQuestion.jsp?responseNo=' || answer.answer || '&questionNo=' || question.question_no ||'&questionId=' || question.id || '><font color=green>' || answer.answer || '</font></a>' ELSE '<a href=surveyQuestion.jsp?responseNo=' || answer.answer || '&questionNo=' || question.question_no || '&questionId=' || question.id || '><font color=red>' || answer.answer || '</font></a>' END as response from answer,question,student where answer.question_id=question.id and question.test_name='"+prePost+"test' and student.id=answer.student_id and student.id in (select DISTINCT student_id from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id='" + teacherID + "')) order by name;";
    if (color.equals("no")) htmlQuery="select student.name as name,question.id as question_id,question.question_no as question_number, CASE WHEN answer.answer=question.answer THEN '<font color=green>*</font>' ELSE '<a href=surveyQuestion.jsp?responseNo=' || answer.answer || '&questionNo=' || question.question_no || '&questionId=' || question.id || '><font color=red>' || answer.answer || '</font></a>' END as response from answer,question,student where answer.question_id=question.id and question.test_name='"+prePost+"test' and student.id=answer.student_id and student.id in (select DISTINCT student_id from research_group_student,research_group,student where student.id=research_group_student.student_id and research_group_student.research_group_id=research_group.id and research_group.id in (select id from research_group where teacher_id='" + teacherID + "')) order by name;";

   	rs = s.executeQuery(htmlQuery);

    if (debug)
	correctTable += "<br><table border='1'><tr><td>Student Name</td><td>Question Number</td><td>Response</td></tr>";
    ListIterator i = studentList.listIterator();
    student = null;
    int max = 0; // this is just store the maximum question number, to know the number of columns needed
    while (rs.next())
    {
	// checks if it is the same student
	if ( student != null && (student.get(0).toString()).equals(rs.getString("name")) )
	{
		int question_sql_id = Integer.parseInt(rs.getString("question_id")) + 1;
		int index = Integer.parseInt(rs.getString("question_number")) + 1;
		if (index > max)
			max = index;
		student.ensureCapacity(index);
		student.add(index, rs.getString("response"));
		//debugInfo=debugInfo + student + " Student" + min + "Min" + max + "Max<BR>";
	}
	else // moving onto another student
	{
		if (i.hasNext())
			student = (ArrayList)(i.next());

		int question_sql_id = Integer.parseInt(rs.getString("question_id")) + 1;
		int index = Integer.parseInt(rs.getString("question_number")) + 1;
		if (index > max)
			max = index;
		student.ensureCapacity(index);
		student.add(index, rs.getString("response"));
		//debugInfo=debugInfo + student + " Student" + min + " Min" + max + " Max<BR>";
	}
   if (debug)
	{
    		correctTable += "<tr><td>" + rs.getString("name") + "</td><td>" + rs.getString("question_number"); 
		correctTable += "</td><td>" + rs.getString("response") + "</td></tr>";
	}
    }

    if (debug)
	correctTable += "</table><br>";
	
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
			correctTable += "<td align ='right'>" + info + "</td>";
		}	
		correctTable += "</tr>";
	}
	correctTable += "</table><br>";

} catch (Exception e) {
    valid = false;
}

if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
<body bgcolor=FFFFFF  vlink=ff6600>
<center>
<TABLE WIDTH=804>
<TR><TD>
	<TABLE WIDTH=800 CELLPADDING=4>
	<TR><td>&nbsp;</td></tr>
	<TR><TD  bgcolor=black>
	<FONT FACE=ARIAL COLOR=white SIZE=+1>
	<B>Results for <%=prePost%>test for students of <%=teacher_name%> with login <%=login%></B><FONT>
	</TD></TR>
	<tr><td>Students' answers are listed under each question. Click on the answer to see the question and answers. Correct answers are displayed in green, incorrect answers are displayed in red. The black and white version shows an asterix instead of the answer number so that correct answers can be seen when printed on a black and white printer.</td></tr></table>

</td></tr>
<%=correctTable%>
<BR>
<%
if (color.equals("yes")){%><A HREF="surveyResults.jsp?color=no&type=<%=prePost%>">Display for Black and White Printout</A><%}else{%><A HREF="surveyResults.jsp?color=yes&type=<%=prePost%>">Display for Color Printout</A><%}
%>
</td></tr>
</table>
</center>
</body>
</html>
