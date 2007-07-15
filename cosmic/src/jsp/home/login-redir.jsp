<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.survey.Survey" %>

<%
	
	if (user.isGuest()) {
		response.sendRedirect("../home/first.jsp");
	}
	else if (user.isTeacher()) {
		response.sendRedirect(response.encodeRedirectURL("../teacher"));
    }
	else if (user.isFirstTime() || user.getSurvey()) {
		int countQuestions = Survey.questionCount(elab);
        //check if all the students have taken the test. 
        int countStudents = Survey.studentCount(elab, user);
                   
		if ((countStudents > 0) && (countQuestions > 0)) {
			response.sendRedirect(response.encodeRedirectURL("../jsp/show-students.jsp"));
		}
		else {
			if (user.isFirstTime()) {
            	user.resetFirstTime();
				response.sendRedirect(response.encodeRedirectURL("../home/first.jsp"));
			}
        }
	}
	else {
	    response.sendRedirect("../home/first.jsp");
	}
%>

??