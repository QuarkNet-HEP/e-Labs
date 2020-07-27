<%-- TODO: Each e-Lab uses an individual version of this file, despite the
fact that there's a common file for it.  That seems like a small improvement
to be made. - JG 5Feb2018 --%>

<%-- All logins (username/pw and guest) are redirected to this page.
                                                          - JG 27Jul2020 --%>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%	String ptr = response.encodeRedirectURL(elab.secure("home/index.jsp?justLoggedIn=yes")); 

if (user.isTeacher() || user.isAdmin()) {
		ptr = response.encodeRedirectURL("../teacher?justLoggedIn=yes");
}
else if (user.isNewSurvey()) { // New survey overrides the old one
		int surveyId = user.getNewSurveyId().intValue();
		// Check if all students have taken the test. 
		int countQuestions = elab.getSurveyProvider().getSurvey(surveyId).getQuestionCount(); 
		int taken = elab.getSurveyProvider().getTotalTaken("pre", user); 
		int students = user.getStudents().size(); 
		//System.out.println("Group: " + user.getName() + ", students: " + students 
    //        + ", taken: " + taken + ", qcount: " + countQuestions);
		
		if ((students > taken) && (countQuestions > 0)) {
				ptr = response.encodeRedirectURL(elab.nonSecure("survey/show-students.jsp"));
		}
}
else if (user.getSurvey()) {
		int countQuestions = elab.getTestProvider().getTest("presurvey").getQuestionCount();
    // Check if all the students have taken the test. 
    int taken = elab.getTestProvider().getTotalTaken("presurvey", user);
    int students = user.getStudents().size();
    // System.out.println("Group: " + user.getName() + ", students: " + students 
    //         + ", taken: " + taken + ", qcount: " + countQuestions);
    
		if ((students > taken) && (countQuestions > 0)) {
				ptr = response.encodeRedirectURL(elab.nonSecure("test/show-students.jsp"));
		}
}

response.sendRedirect(ptr);


%>
