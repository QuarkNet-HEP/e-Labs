<%@ page import="java.util.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Records Anwers</title>
    </head>
    <body>
        <center>
<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<%

//start jsp by defining submit
String prePost =  request.getParameter("type"); //pre for pretest and post for posttest.
String submit =  request.getParameter("submit");
String student_id =  request.getParameter("student_id");
     // get group ID
                //groupName defined in common.jsp
     int elabId=0;  // id of eLab
     String ID="";
     String query="select id from research_group where name=\'"+groupName+"\';";
     rs = s.executeQuery(query);
     if (rs.next()){
       ID=rs.getString("id");}
       
       if (ID.equals("")) {%> Problem with ID for group <%=groupName%><BR><% return;}

         query = "SELECT id FROM project where name='"+elabName+"';";  // elabName is defined in the include file
         rs = s.executeQuery(query);
         // int elabId;
          if (rs.next()) {
                    elabId = rs.getInt(1);
          }
     boolean legalStudent=false; // check to see if this student is in the login group and if they have not taken the test yet.
     query="select student.id as id,survey." + prePost + "survey as tooktest from student,research_group_student,research_group_project,survey where research_group_student.research_group_id="+ ID + " AND research_group_project.research_group_id="+ ID +" AND research_group_student.student_id=student.id AND survey.student_id=student.id AND survey.project_id="+elabId+";";
     rs = s.executeQuery(query);
     while(rs.next()){
       String studentID=rs.getString("id");
       if ((studentID.equals(student_id)) && (rs.getString("tooktest").equals("f"))) legalStudent=true;
     } //while
    if (!legalStudent) {
    %>
    <FONT face="Arial" color="red">This student has either taken the test already or is not in this group.</FONT>
    <%
    return;
    }
    else
    { //enter answers into answer database.  Set presurvey to t in survey database. Finally check whether to set survey to true in research_group database
     int count =  Integer.parseInt(request.getParameter("count"));
      // First check that they have answers to all the questions.
      String responseName="";
      String questionName="";
      String[] testResponse = new String[100];
      String[] questionID = new String[100];
       for(int j=0; j<count; j++) {
          responseName="response"+(j+1);
         testResponse[j]=request.getParameter(responseName);
          questionName="questionId"+(j+1);
         questionID[j]=request.getParameter(questionName);
          if (testResponse[j]==null || testResponse[j].equals("")) {
          %>
               <FONT face="Arial" color="red">Please go back and answer all the questions.</FONT>
          <%
          return;
          }  // test on value of response
        } // for
        // all questions have been answered

       // OK to enter them in answer table
       for(int j=0; j<count; j++) {
         int i=0;
         query="INSERT INTO answer (question_id, student_id, answer) VALUES ("+questionID[j]+ "," + student_id + ",\'"+testResponse[j]+"\');";
           try{
                i = s.executeUpdate(query);
              } catch (SQLException se){
                 warn(out, "There was some error entering your info into the answer table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              }
              if(i != 1){
                 warn(out, "Weren't able to add your info to the database! " + i + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                    return;
              }
                    
          } //for each question
        
         // answers entered; update survey to reflect that pretest has been taken.
          query="UPDATE survey SET " + prePost + "survey='t' WHERE project_id="+elabId+" AND student_id="+student_id;
          int k=0;
          try{
                k = s.executeUpdate(query);
             } 
             catch (SQLException se){
                 warn(out, "There was some error entering your info into the survey table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: " + query);
                 return;
              } // try-catch for updating survey table
              if(k != 1){
                  warn(out, "Weren't able to add your info to the database! " + k + " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: " + query);
                  return;
               } //!k=1 test 
                     
      
   } // else - ok to process results.
     // get the number of students who should take the pretest
     // Find out how many students are in the group that need to take the test.

     String subquery="select student.id from student,research_group_student,research_group_project,survey where research_group_student.research_group_id="+ID +" AND research_group_project.research_group_id="+ID +"  AND research_group_student.student_id=student.id AND survey.student_id=student.id AND survey.project_id="+elabId;
     int totalTaken=0;
     int total=0;
     query= "select count(student_id) from survey where project_id="+ elabId +" and student_id in (" + subquery + ");";
     rs = s.executeQuery(query);
     if (rs.next()){
       total=Integer.parseInt(rs.getString(1));}

     subquery="select student.id from student,research_group_student,research_group_project,survey where research_group_student.research_group_id="+ID +" AND research_group_project.research_group_id="+ID +"  AND research_group_student.student_id=student.id AND survey.student_id=student.id AND survey.project_id="+elabId+" AND survey." + prePost + "survey='t'";
            
     query= "select count(student_id) from survey where project_id="+elabId+" and student_id in (" + subquery + ");";
     rs = s.executeQuery(query);
     if (rs.next()){
       totalTaken=Integer.parseInt(rs.getString(1));}
      String message="Thanks for taking this test.<BR>";
      message=message+ totalTaken+ " out of " + total + " students  in your research group have taken the test.<BR>";
      // update research_group to reflect that pretest has been taken by all students in group if totalTaken== total.
      if (totalTaken == total) {
         message=message + " Your group can now start your Cosmic Investigation.<BR><BR><A HREF=\'first.jsp\'>Start Investigation</A>";
          } // check if we need to update research_group column "survey"
         else
         {
         message=message + "<BR><BR><A HREF=\'showStudents.jsp?type="+prePost+"\'>Show Students in Your Group.</A>";
         }

%>
<%=message%>
		</center>
	</body>
<%
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>
</html>
