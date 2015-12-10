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
int loggedOutCount = 0;
int sessionUsers = 0;
ArrayList sessionsToInvalidate = new ArrayList();
String submit = request.getParameter("submitButton");

if (submit != null && submit.equals("Log Research Group Out")) {
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
	              sessionsToInvalidate.add(s);
	              //log user out
	              //s.invalidate();
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
	    if (!sessionsToInvalidate.isEmpty()) {
	      for (int i = 0; i < sessionsToInvalidate.size(); i++) {
	        loggedOutCount++;
	        HttpSession s = (HttpSession) sessionsToInvalidate.get(i);
	        s.invalidate();
	      }
	    }
	    message = "Username <strong>"+un+"</strong> has been logged out successfully "+String.valueOf(loggedOutCount)+" time(s).";
	  }
	}	
}

//now create the local TreeMap
TreeMap<String, String> sessionDetails = new TreeMap<String, String>();
for (int i = 0; i < activeSessions.size(); i++) {
    HttpSession s = (HttpSession) activeSessions.get(i);
    StringBuilder sb = new StringBuilder();
      //start building session details
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
        	if (groupNames.contains(eu.getName()) && !eu.getName().equals(user.getName())) {
	          sessionUsers++;
	          sb.append("<strong>Username:</strong> "+ eu.getName() + "<br />");
	          String school = eu.getSchool() != null ? eu.getSchool() : "";
	          String city = eu.getCity() != null ? eu.getCity() : "";
	          String state = eu.getState() != null ? eu.getState() : "";
	          sb.append("<strong>Location:</strong> "+ school + ", " + city + " - " + state + "<br />");
	          sb.append("<strong>Role:</strong> "+ eu.getRole() + "<br />");
	          sb.append("<strong>Logged in to:</strong> "+ e.getName() + "<br />");
        	}
        }
        String sessiontext = sb.toString();
        if (!sessiontext.equals("")) {
            sessionDetails.put("<strong>Session # " + String.valueOf(i), sessiontext + "</strong>");        
        }
      }//end of validSession
    } catch (Exception e) {
        message = "Exception in session-tracking.jsp: " + e.getMessage();      
    }
  }
  request.setAttribute("sessionUsers", sessionUsers);
  request.setAttribute("sessionDetails",sessionDetails);  
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
        <p>If any of your research groups has exceeded the maximum number of logins and they are not able to log out themselves, 
        you will need to log them out using this tool. 
        Until you log them out, no one else can login as that research group. <br /><br />
        To avoid this situation, it is good practice to give student teams their own research group 
        username to log in rather than having multiple student teams use the same research group username.
        </p>
        <ul>
           <li>Check your research groups that are logged in.</li>
           <li>Choose the research group username you wish to log out and submit your request.</li>
        </ul>      
        <h2>Total Users Logged In: ${sessionUsers}</h2>
           <table style="border: 1px solid black; cell-padding: 15px;">
              <tr>
                <th style="vertical-align: top; border: 1px dotted gray;">Details</th>
              </tr>
              <c:forEach items="${sessionDetails}" var="sessionDetails">
                <c:if test="${not empty sessionDetails.value}">
                  <tr>
                    <td style="vertical-align: top; border: 1px dotted gray;">${sessionDetails.value }</td>
                  </tr>
                </c:if>
              </c:forEach>
           </table>

        <form id="researchGroupLogout" method="post">
            <table style="text-align: center;">
                <tr>
                  <td>Username: 
                      <select name="un" id="un">
                        <option></option>
                        <c:forEach items="${groupNames }" var="group">
                            <option value="${group }">${group }</option>
                        </c:forEach>
                      </select>
                  </td>
                </tr>
						    <tr>
						      <td><div id="messages">${message}</div></td>
						    </tr>
						    <tr>
						      <td><input type="submit" name="submitButton" value="Log Research Group Out"></input></td>
						    </tr>     
            </table>
        </form>
      </div>
      <!-- end content -->

      <div id="footer">
      </div>
    
    </div>
    <!-- end container -->
  </body>
</html>

