<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.URLEncoder" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%
Collection groupNames = user.getGroupNames();
request.setAttribute("groupNames", groupNames);
String message = "";
String un = request.getParameter("un");
ArrayList activeSessions = SessionListener.getTotalSessionUsers();
activeSessions.removeAll(Collections.singleton(null));
boolean unLoggedin = false;
if (un != null && un.equals(user.getName())) {
    message = "Please use the log out link on the top right corner to log yourself out.";	
} else {
	if (un != null) {
		for (int i = 0; i < activeSessions.size(); i++) {
		  HttpSession s = (HttpSession) activeSessions.get(i);
		  //get user
		    try {
		    boolean validSession = false;
		    Enumeration att_names = s.getAttributeNames();
		    while (att_names.hasMoreElements()) {
		      String attr = (String) att_names.nextElement();
		      if (attr.equals("elab")) {
		        validSession = true;
		      }
		    }
		    if (validSession) {
		      ElabGroup eu = (ElabGroup) s.getAttribute("elab.user");
		      Elab e = (Elab) s.getAttribute("elab");
		      if (eu != null && e != null) {
		    	  if (eu.getName().equals(un)) {
		    		  unLoggedin = true;
		    		  //log user out
		    		  s.invalidate();
		    		  message = "Username <strong>"+un+"</strong> has been logged out successfully.";
		    	  }
		      }
		    }//end of validSession
		  } catch (Exception e) {
		      message = "Exception in research-group-logout.jsp: " + e.getMessage();      
		  }
		}
		if (!unLoggedin) {
		    message = "Username <strong>"+un+"</strong> is not logged in.";
		}
	}
}
request.setAttribute("message",message);  
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Log out research groups</title>
    <link rel="stylesheet" type="text/css" href="../css/style2.css"/>
    <link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
    <link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
    <script>
	    function verifyUsername() {
	      var validUsername = false;
	      var un = document.getElementById("un");
	      console.log(un.value);
	      var validUsers = document.getElementsByName("researchGroups");
	      var messages = document.getElementById("messages");
	      for (var i=0; i < validUsers.length; i++) {
	    	  if (validUsers[i].value == un.value) {
	    		  validUsername = true;
	    	  }
	      }
	      if (!validUsername)	{
	          messages.innerHTML = "<i>* The username <strong>"+un.value+"</strong> is not in your research groups.</i>";	    	  
	      }      
	      return validUsername;
	    }
   </script>    
  </head>

  <body id="research-group-logout">
    <!-- entire page container -->
    <div id="container">
      <div id="top">
        <div id="header">
          <%@ include file="../include/header.jsp" %>
          <div id="nav">
            <%@ include file="../include/nav-teacher.jsp" %>
          </div>
        </div>
      </div>
      
      <div id="content">
        <h1>Research Group Log Out</h1>
        <ul>
           <li>Enter the research group username you wish to log out</li>
        </ul>
        <form id="researchGroupLogout" method="post">
            <table style="text-align: center;">
                <tr>
                  <td>Username: <input type="text" name="un" id="un"></input></td>
                </tr>
						    <tr>
						      <td><div id="messages">${message}</div></td>
						    </tr>
						    <tr>
						      <td><input type="submit" name="submitButton" value="Log Research Group Out" onclick="return verifyUsername();"></input></td>
						    </tr>     
            </table>
        </form>

		    <c:forEach items="${groupNames}" var="group">
          <input type="hidden" name="researchGroups" id="${group }" value="${group }"></input>
		    </c:forEach>

      </div>
      <!-- end content -->

      <div id="footer">
      </div>
    
    </div>
    <!-- end container -->
  </body>
</html>

