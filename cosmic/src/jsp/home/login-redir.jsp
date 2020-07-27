<%-- TODO: Each e-Lab uses an individual version of this file, despite the
fact that there's a common file for it.  That seems like a small improvement
to be made. - JG 5Feb2018 --%>

<%-- All logins (username/pw and guest) are redirected to this page.
- JG 27Jul2020 --%>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
// Redirect guests to the e-Lab's home index
if (user.isGuest()) {
		response.sendRedirect(
				response.encodeRedirectURL(
						elab.nonSecure("home/index.jsp")
				)
		);
		return;
}
// Redirect Teachers and Admins to the teacher index
else if (user.isTeacher() || user.isAdmin()) {
		response.sendRedirect(
				response.encodeRedirectURL("../teacher/index.jsp?justLoggedIn=yes")
		);
		return;
}

// Redirect others to the survey or test, according to status
else if (user.isNewSurvey()) { // New survey overrides the old one
		int surveyId = user.getNewSurveyId().intValue();
		// TODO: Check if all students have taken the test. 
		int countQuestions = elab.getSurveyProvider().getSurvey(surveyId).getQuestionCount();
		int taken = elab.getSurveyProvider().getTotalTaken("pre", user);
		int students = user.getStudents().size();
		//System.out.println("Group: " + user.getName() + ", students: " + students 
		//        + ", taken: " + taken + ", qcount: " + countQuestions);

		if ((students > taken) && (countQuestions > 0)) {
				response.sendRedirect(
						response.encodeRedirectURL(
								elab.nonSecure("survey/show-students.jsp")
						)
				);
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
				response.sendRedirect(
						response.encodeRedirectURL(
								elab.nonSecure("test/show-students.jsp")
						)
				);
				return;
		}
}

// Redirect users not caught by the above to the e-Lab's home index,
// adding GET parameter based on "first time" status
if (!user.isFirstTime()) {
		response.sendRedirect(
				response.encodeRedirectURL(
						elab.nonSecure("home/index.jsp?justLoggedIn=yes")
				)
		);
}
else {
		user.resetFirstTime();
		response.sendRedirect(
				response.encodeRedirectURL(elab.nonSecure("home/index.jsp"))
		);
}
// This is identified as unreachable, which throws a breaking error (JG 27Jul2020):
//return; 
%>
