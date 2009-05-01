<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.test.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Record Answers</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="record-answers">
		<!-- entire page container -->
		<div id="container">
			<div id="content">


<%
	String type =  request.getParameter("type"); //pre for pretest and post for posttest.
	if (type == null) {
	    throw new ElabJspException("Mising test type");
	}
	request.setAttribute("type", type);
	String submit =  request.getParameter("submit");
	String studentId =  request.getParameter("studentid");
	if (!elab.getUserManagementProvider().isStudentInGroup(user, studentId)) {
	    //throw new ElabJspException("This student does not belong to this group.");
	}
	if (elab.getTestProvider().hasStudentTakenTest(type, studentId)) {
	    throw new ElabJspException("This student has already taken this test");
	}
	
	
    //enter answers into answer database.  Set presurvey to t in survey database. Finally check whether to set survey to true in research_group database
    ElabTest test = elab.getTestProvider().getTest(type);
    List questions = test.getQuestions();
   	int count =  Integer.parseInt(request.getParameter("count"));
	Map responses = new HashMap();
	// First check that they have answers to all the questions.
	for (int i = 1; i <= count; i++) {
	    String res = request.getParameter("response" + i);
	    if (res == null || res.equals("")) {
	        throw new ElabJspException("Please go back and answer all the questions.");
	    }
	    String qid = request.getParameter("questionId" + i);
	    responses.put(qid, res);
	}

	elab.getTestProvider().recordTestAnswers(type, studentId, responses);

	int total = elab.getTestProvider().getTotalStudents(user);
	int totalTaken = elab.getTestProvider().getTotalTaken(type, user);
    request.setAttribute("total", String.valueOf(total));
	request.setAttribute("totalTaken", String.valueOf(totalTaken));
%>

<h1>Thanks for taking this test.</h1>
<p>	
	${totalTaken} out of ${total} students in your research group have taken the test.
</p>
<c:choose>
	<c:when test="${totalTaken == total}">
		<p>
			Your group can now <a href="../home/index.jsp">start its Cosmic Investigation.</a>
		</p>
	</c:when>
	<c:otherwise>
		<p>
			<a href="../test/show-students.jsp?type=${type}">Show Students in Your Group.</a>
		</p>
	</c:otherwise>
</c:choose>
			
			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
	