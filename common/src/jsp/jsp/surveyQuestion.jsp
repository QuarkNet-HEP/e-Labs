<%@ page import="java.util.regex.*" %>
<%@ include file="common.jsp" %>
<html>
    <head>
        <title>Test Question</title>
    </head>
    <body>
<center>
<%
//start jsp by defining submit
String questionNo =  request.getParameter("questionNo");
String responseNo = request.getParameter("responseNo");
String questionId = request.getParameter("questionId");
%>


<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>
<%
     rs = s.executeQuery("select answer, question,id,response1,response2,response3,response4,response5 from question where question.id = " + questionId + ";");

       if(!rs.next())
		return; // should only be one result
       String question=rs.getString("question");
      // String questionId=rs.getString("id");
       String response1=rs.getString("response1");
       String response2=rs.getString("response2");
       String response3=rs.getString("response3");
       String response4=rs.getString("response4");
       String response5=rs.getString("response5");
       String answer = rs.getString("answer");
     %>
     <table width="600">
    <tr><th align="left"><%=questionNo%>) <%=question%>
    <tr><td><input type="radio" name="response<%=questionNo%>" value="1">1) <%=response1%></td></tr>
    <td><input type="radio" name="response<%=questionNo%>" value="2">2) <%=response2%></td></tr>
    <% if (!response3.equals("")) {
     %>
     <td><input type="radio" name="response<%=questionNo%>" value="3">3) <%=response3%></td></tr>
     <%
     }
     if (!response4.equals("")) {
     %>
     <td><input type="radio" name="response<%=questionNo%>" value="4">4) <%=response4%></td></tr>
     <%
     }
     if (!response5.equals("")) {
     %>
     <td><input type="radio" name="response<%=questionNo%>" value="5">5) <%=response5%></td></tr>
     <%
     }
     %>
       </table><P><HR width="600">
<table width="600">
<tr><td align="left">The correct choice is choice <%=answer%>. </td></tr>
<tr><td align="left">The student's choice is choice <%=responseNo%>.</td></tr>
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
  

