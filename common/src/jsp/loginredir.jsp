<%@ include file="include/elab.jsp" %>
<%@ include file="modules/login/loginrequired.jsp" %>
<%@ page import="gov.fnal.elab.survey.Survey" %>

<%
	
	if (user.isGuest()) {
		response.sendRedirect(
			response.encodeRedirectURL("http://" + elab.getProperties().getHost() + 
				elab.getProperties().getPort() + "/elab/" + elab.getName() + "/first.jsp"));
	}
	else if (user.isTeacher()) {
		response.sendRedirect(
			response.encodeRedirectURL("http://" + elab.getProperties().getHost() + 
                                elab.getProperties().getPort() + "/elab/" + elab.getName() + 
								"/teacher.jsp"));
    }
	else if (user.isFirstTime() || user.getSurvey().equals("t")) {
		int countQuestions = Survey.questionCount(elab);
        //check if all the students have taken the test. 
        int countStudents = Survey.studentCount(elab, user);
                   
		if ((countStudents > 0) && (countQuestions > 0)) {
			response.sendRedirect(
				response.encodeRedirectURL(
					"http://" + elab.getProperties().getHost() + 
					elab.getProperties().getPort()+ "/elab/" + elab.getName() + "/showStudents.jsp"));
		}
		else {
			if (user.isFirstTime()) {
            	user.resetFirstTime();
				response.sendRedirect(
					response.encodeRedirectURL(
						"http://" + elab.getProperties().getHost() + 
                        elab.getProperties().getPort() + "/elab/" +elab.getName() + "/first.jsp"));
			}
        }
	}
%>