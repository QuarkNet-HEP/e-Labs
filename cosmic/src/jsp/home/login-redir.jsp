<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
	
	if (user.isGuest()) {
		response.sendRedirect("../home/first.jsp");
	}
	else if (user.isTeacher() || user.isAdmin()) {
		response.sendRedirect(response.encodeRedirectURL("../teacher"));
    }
	else if (user.isFirstTime() || user.getSurvey()) {
		int countQuestions = elab.getTestProvider().getTest("presurvey").getQuestionCount();
        //check if all the students have taken the test. 
        int taken = elab.getTestProvider().getTotalTaken("presurvey", user);
        int students = user.getStudents().size();
        System.out.println("Group: " + user.getName() + ", students: " + students 
                + ", taken: " + taken + ", qcount: " + countQuestions);
                   
		if ((students > taken) && (countQuestions > 0)) {
			response.sendRedirect(response.encodeRedirectURL("../test/show-students.jsp"));
		}
		else {
			if (user.isFirstTime()) {
            	user.resetFirstTime();
				response.sendRedirect(response.encodeRedirectURL("../home/first.jsp"));
			}
			else {
			    response.sendRedirect(response.encodeRedirectURL("../home/"));
			}
        }
	}
	else {
	    response.sendRedirect("../home/first.jsp");
	}
%>