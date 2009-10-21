<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
	
	if (user.isGuest()) {
		response.sendRedirect(response.encodeRedirectURL(elab.nonSecure("home/index.jsp")));
		return; 
	}
	else if (user.isTeacher() || user.isAdmin()) {
		response.sendRedirect(response.encodeRedirectURL("../teacher"));
		return; 
    }
	else if (user.isNewSurvey()) { // New survey overrides the old one
		int surveyId = user.getNewSurveyId().intValue();
		// TODO: Check if all students have taken the test. 
		int countQuestions = elab.getSurveyProvider().getSurvey(surveyId).getQuestionCount(); 
		int taken = elab.getSurveyProvider().getTotalTaken("pre", user); 
		int students = user.getStudents().size(); 
		//System.out.println("Group: " + user.getName() + ", students: " + students 
        //        + ", taken: " + taken + ", qcount: " + countQuestions);
		
		if ((students > taken) && (countQuestions > 0)) {
			response.sendRedirect(response.encodeRedirectURL(elab.nonSecure("survey/show-students.jsp")));
			return; 
		}
	}
	else if (user.getSurvey()) {
		int countQuestions = elab.getTestProvider().getTest("presurvey").getQuestionCount();
        //check if all the students have taken the test. 
        int taken = elab.getTestProvider().getTotalTaken("presurvey", user);
        int students = user.getStudents().size();
       // System.out.println("Group: " + user.getName() + ", students: " + students 
       //         + ", taken: " + taken + ", qcount: " + countQuestions);
                   
		if ((students > taken) && (countQuestions > 0)) {
			response.sendRedirect(response.encodeRedirectURL(elab.nonSecure("test/show-students.jsp")));
			return; 
		}
	}

	if (!user.isFirstTime()) {
		response.sendRedirect(response.encodeRedirectURL(elab.nonSecure("home/")));
	}
	else {
		user.resetFirstTime();
	    response.sendRedirect(response.encodeRedirectURL(elab.nonSecure("home/index.jsp")));
	}
	return; 
%>