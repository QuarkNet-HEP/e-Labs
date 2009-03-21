<%@ page import="gov.fnal.elab.db.*" %>
<%@ page import="gov.fnal.elab.cosmic.db.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../common.jsp" %>
<%@ include file="manage_inc.jsp" %>

<%
User me = User.findByUsernameAndPassword("paul", "junk");
%>

<html>
<head>
    <title>Admin User</title>
</head>

<body>

<%=headerString("User Administration")%>
<hr>

<%
String submitType = request.getParameter("submitType");
String action = request.getParameter("a");
String type = request.getParameter("t");
if(submitType != null){
    if(submitType.equals("create")){
        /**
         * Create a new user with attributes from the parameter
         */
        User newUser = null;
        if(type.equals("user")){
            newUser = new User();
        }
        else if(type.equals("manager")){
            newUser = new Manager();
        }
        else if(type.equals("qnteacher")){
            newUser = new QuarkNetTeacher();
        }

        String username = request.getParameter("username");
        String password1 = request.getParameter("password1");
        String password2 = request.getParameter("password2");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String surveyReq = request.getParameter("survey_req");
        String phoneNumber = "";
        String phoneNumber2 = "";
        String faxNumber = "";
        if(type.equals("manager") || type.equals("qnteacher")){
            phoneNumber = request.getParameter("phoneNumber");
            phoneNumber2 = request.getParameter("phoneNumber2");
            faxNumber = request.getParameter("faxNumber");
        }

        newUser.setUsername(username);
        newUser.setPassword(password1);
        newUser.setFirstName(firstName);
        newUser.setLastName(lastName);
        newUser.setEmail(email);
        if(surveyReq != null){
            newUser.setIsSurveyRequired(true);
        }
        if(type.equals("manager")){
            ((Manager)newUser).setPhoneNumber(phoneNumber);
            ((Manager)newUser).setPhoneNumber2(phoneNumber2);
            ((Manager)newUser).setFaxNumber(faxNumber);
        }
        else if(type.equals("qnteacher")){
            ((QuarkNetTeacher)newUser).setPhoneNumber(phoneNumber);
            ((QuarkNetTeacher)newUser).setPhoneNumber2(phoneNumber2);
            ((QuarkNetTeacher)newUser).setFaxNumber(faxNumber);
        }

        newUser.save();
%>
        <font color="green"><a href="show_user.jsp?u=<%=username%>">New user created (click to continue)</a><br>
<%
    }
    if(submitType.equals("update")){
        /**
         * Update a user's attributes, already in the database
         */
        submitType = "update";
        String username = request.getParameter("u");
        User updateUser = User.findByUsername(username);

        String password1 = request.getParameter("password1");
        String password2 = request.getParameter("password2");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String surveyReq = request.getParameter("survey_req");
        String phoneNumber = request.getParameter("phoneNumber");
        String phoneNumber2 = request.getParameter("phoneNumber2");
        String faxNumber = request.getParameter("faxNumber");

        updateUser.setUsername(username);
        updateUser.setPassword(password1);
        updateUser.setFirstName(firstName);
        updateUser.setLastName(lastName);
        updateUser.setEmail(email);
        if(surveyReq != null){
            updateUser.setIsSurveyRequired(true);
        }
        else{
            updateUser.setIsSurveyRequired(false);
        }
        if(type.equals("manager")){
            ((Manager)updateUser).setPhoneNumber(phoneNumber);
            ((Manager)updateUser).setPhoneNumber2(phoneNumber2);
            ((Manager)updateUser).setFaxNumber(faxNumber);
        }
        else if(type.equals("qnteacher")){
            ((QuarkNetTeacher)updateUser).setPhoneNumber(phoneNumber);
            ((QuarkNetTeacher)updateUser).setPhoneNumber2(phoneNumber2);
            ((QuarkNetTeacher)updateUser).setFaxNumber(faxNumber);
        }

        updateUser.save();
%>
        <font color="green"><a href="show_user.jsp?u=<%=username%>">User updated (click to continue)</a><br>
<%
    }
    if(submitType.equals("set_projects")){
        /**
         * Set projects a user is in from parameter attributes
         */
        String username = request.getParameter("u");
        User updateUser = User.findByUsername(username);
        
        String[] f = request.getParameterValues("set");
        if(f != null){
            Set set = new HashSet();
            for(int i=0; i<f.length; i++){
                Project p = Project.findById(f[i]);
                if(p != null){
                    set.add(p);
                }
            }
            updateUser.setProjects(set);
            updateUser.save();
        }
        else{
            updateUser.setProjects(new HashSet());  //set no projects
        }
%>
        <font color="green"><a href="show_user.jsp?u=<%=username%>">Project list updated for <%=username%> (click to continue)</a><br>
<%
    }           
}

//else this is a new user creation or edit user action
else{
    submitType = "create";

    //variables which are set if we're editing a user in the database
    String username = "";
    String firstName = "";
    String lastName = "";
    String email = "";
    boolean surveyReq = false;
    String surveyReqChecked = "";
    String phoneNumber = "";
    String phoneNumber2 = "";
    String faxNumber = "";
    if(action.equals("edit")){
        submitType = "update";
        username = request.getParameter("u");
        User updateUser = User.findByUsername(username);
        if(updateUser != null){
            firstName = updateUser.getFirstName();
            lastName = updateUser.getLastName();
            email = updateUser.getEmail();
            surveyReq = updateUser.getIsSurveyRequired();
            surveyReqChecked = (surveyReq == true) ? "checked" : "";
            if(type.equals("manager")){
                phoneNumber = ((Manager)updateUser).getPhoneNumber();
                phoneNumber2 = ((Manager)updateUser).getPhoneNumber2();
                faxNumber = ((Manager)updateUser).getFaxNumber();
            }
            else if(type.equals("qnteacher")){
                phoneNumber = ((QuarkNetTeacher)updateUser).getPhoneNumber();
                phoneNumber2 = ((QuarkNetTeacher)updateUser).getPhoneNumber2();
                faxNumber = ((QuarkNetTeacher)updateUser).getFaxNumber();
            }
        }
        else{
            out.println("No user found in database with the username: " + username);
        }
    }
%>
    <form method="post">
    <table>
        <tr>
           <td>Username:</td>
<%
           if(action.equals("edit")){
               out.println("<td>" + username + "</td>");
               out.println("<input type=hidden name=username value=" + username + "></td>");
           }
           else{
               out.println("<td><input type=text name=username size=10></td>");
           }
%>
       </tr>
       <tr>
           <td>Password:</td>
           <td><input type="password" name="password1" size="8"></td>
       </tr>
       <tr>
           <td>Password (again):</td>
           <td><input type="password" name="password2" size="8"></td>
       </tr>
       <tr>
           <td>First name:</td>
           <td><input type="text" name="firstName" size="10" value="<%=firstName%>"></td>
       </tr>
       <tr>
           <td>Last name:</td>
           <td><input type="text" name="lastName" size="10" value="<%=lastName%>"></td>
       </tr>
       <tr>
           <td>e-mail:</td>
           <td><input type="text" name="email" size="20" value="<%=email%>"></td>
       </tr>
       <tr>
           <td colspan="2">is taking the required surveys in a project required for this user?
           <input type="checkbox" name="survey_req" <%=surveyReqChecked%>></td>
       </tr>
<%
        if(type.equals("manager") || type.equals("qnteacher")){
%>
       <tr>
           <td>Phone Number:</td>
           <td><input type="text" name="phoneNumber" size="15" value="<%=phoneNumber%>"></td>
       </tr>
       <tr>
           <td>Secondary Phone Number (optional):</td>
           <td><input type="text" name="phoneNumber2" size="15" value="<%=phoneNumber2%>"></td>
       </tr>
       <tr>
           <td>Fax Number (optional):</td>
           <td><input type="text" name="faxNumber" size="15" value="<%=faxNumber%>"></td>
       </tr>
<%
        }
%>
       <tr>
           <td><input type="submit" name="submit" value="Submit"></td>
           <td><input type="hidden" name="submitType" value="<%=submitType%>"></td>
       </tr>
   </table>
   </form>
<%
   //end section of new/edit user
}
%>

<hr>

</body>
</html>
