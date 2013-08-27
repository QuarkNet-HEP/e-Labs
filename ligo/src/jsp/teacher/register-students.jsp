<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Register Students</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
        <script type="text/javascript" src="../include/util-functions.js"></script>
        <script type="text/javascript" src="../include/clear-default-text.js"></script>	
        <script>
        	function checkEnteredData() {
        		var allOK = true;
    			var messages = document.getElementById("messages");
    			messages.innerHTML = "";
        		var existingGroup = document.getElementsByClassName("existingGroups");
				for (var i = 0; i < 10; i++) {
					var newGroup = document.getElementById("res_name_text"+i);
					allOK = checkGroupName(newGroup);
					if (newGroup != null && newGroup.value != "Group Name") {
	        			for (var j = 0; j < existingGroup.length; j++) {
	        				if (newGroup.value == existingGroup[j].name) {
	        					allOK = false;
	        	    			if (existingGroup[j].value < 4) {
	    	    	    			messages.innerHTML = "<i>* Cannot Save. "+newGroup.value+" already exists, add your student to the group instead of trying to create a new one.</i>";
	        	    			} else {
	        	    				messages.innerHTML = "<i>* Cannot Save. "+newGroup.value+" exists and already has the maximum number of students allowed per group. Please make a new group.</i>";
	        	    			}        					
	        				}
	        			}
        			}
        		}	
        		var chosenGroups = document.getElementsByClassName("chosenGroups");
        		for (var i = 0; i < chosenGroups.length; i++) {
        			for (var j = 0; j < existingGroup.length; j++) {
        				if (chosenGroups[i].value == existingGroup[j].name) {
            				alert(chosenGroups[i].value + "-" + existingGroup[j].name);
        	    			if (existingGroup[j].value == 4) {
            					allOK = false;
        	    				messages.innerHTML = "<i>* Cannot Save. "+chosenGroups[i].value+" exists and already has the maximum number of students allowed per group. Please make a new group.</i>";
        	    			}        					
        				}
        			}
        		}
        		
        		return allOK;
        	}
        	function checkNewGroup(object) {
        		checkExists(object);
        		checkGroupName(object);
        	}
        	function checkExists(object) {
    			var messages = document.getElementById("messages");
    			messages.innerHTML = "";
        		var existingGroup = document.getElementsByClassName("existingGroups");
        		for (var i = 0; i < existingGroup.length; i++) {
    	    		if (object.value == existingGroup[i].name) {
    	    			if (existingGroup[i].value < 4) {
	    	    			messages.innerHTML = "<i>* "+object.value+" already exists, add your student to the group instead of trying to create a new one.</i>";
    	    			} else {
    	    				messages.innerHTML = "<i>* "+object.value+" exists and already has the maximum number of students allowed per group. Please make a new group.</i>";
    	    			}
    	    		}
        		}
        	}
        	function checkGroupName(object) {
        		if (object != null) {
        			var messages = document.getElementById("messages");
        			if (object.value != "Group Name") {
		    			if (! /^[a-zA-Z0-9_-]+$/.test(object.value)) {
		    				var message = "Group Name contains invalid characters. Use any alphanumeric combination, dashes or underscores.";
		    				messages.innerHTML = "<i>* "+message+"</i>";
		    				return false;
		    			}
        			}
	        	}
        		return true;
        	}
        	function checkMaxNumber(object) {
    			var messages = document.getElementById("messages");
    			messages.innerHTML = "";
    			var newGroupCounter = 0;
    			for (var j = 0; j < 10; j++) {
    				var newGroup = document.getElementById("res_name_chooser"+j);
    				if (newGroup != null) {
    					if (newGroup.value == object.value) {
    						newGroupCounter++;
    					}
    				}
    			}
        		var existingGroup = document.getElementsByClassName("existingGroups");
        		for (var i = 0; i < existingGroup.length; i++) {
    	    		if (object.value == existingGroup[i].name) {
    	        		var total_items = parseInt(existingGroup[i].value) + parseInt(newGroupCounter);
    	    			if ( total_items > 4) {
    	    				messages.innerHTML = "<i>* "+object.value+" exists and already has the maximum number of students allowed per group. Please make a new group.</i>";
    	    			}
    	    		}
        		}       		
        	}
        </script>	
	</head>
	
	<body id="register-students" class="teacher">
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

<%
int newSurveyId = -1; 
boolean teacherInStudy = "yes".equalsIgnoreCase(request.getParameter("eval"));
TreeMap<String, Integer> teacherGroups = new TreeMap<String, Integer>();

// Only for teachers in our study. 
if (teacherInStudy) {
	%> <i>You have agreed to enter our study</i><% 
	
	// Set teacher's database flag so we know he or she is in the survey.
	if (user.isStudy() == false) {
		elab.getUserManagementProvider().setTeacherInStudy(user, newSurveyId); 
		user.setStudy(true);
		// set this in the database. 
	}
}

// New survey/test handler is active by default. 
//if (user.getNewSurveyId() == null) { 
	if (StringUtils.equalsIgnoreCase(elab.getName(), "cosmic")) {
		newSurveyId = Integer.parseInt(elab.getProperty("cosmic.newsurvey"));
		user.setNewSurveyId(newSurveyId);
	}
	else if (StringUtils.equalsIgnoreCase(elab.getName(), "ligo")) {
		newSurveyId = Integer.parseInt(elab.getProperty("ligo.newsurvey"));
		user.setNewSurveyId(newSurveyId);
	}
	// set handlers for everything else. 
//}
//else {
//	newSurveyId = user.getNewSurveyId().intValue();
//}
	
String optionList = "<option value=\"discard\">Choose group</option>";
for (Iterator ite = user.getGroups().iterator(); ite.hasNext();) {
	ElabGroup group = (ElabGroup) ite.next();
	//EPeronja-05/30/2013-Added this check to prevent mixing/matching older groups
	//         with new students. This was not well-thought and was breaking the code
	//		   in show-students.jsp trying to show 'new' and 'old' students.
	boolean existsInSurvey = elab.getTestProvider().getSurveyStudents(group);
	if (!existsInSurvey) {	
		String name = group.getName();
		if (!name.equals(user.getName())) {
			if (group.getActive()) {
		    	optionList += "<option value=\"" + name + "\">" + name + "</option>";
			    teacherGroups.put(name, group.getStudents().size());
			}
		}
	}
}
request.setAttribute("teacherGroups", teacherGroups);

String submit = request.getParameter("submit");
if (submit != null) {
    try {
        List students = new ArrayList();
        List newGroups = new ArrayList();
        
		for (int formNum = 0; formNum < 10; formNum++) {
			String last = request.getParameter("last" + formNum);
			String first = request.getParameter("first" + formNum);
			String resName = request.getParameter("res_name" + formNum);
			String resNameChoose = request.getParameter("res_name_choose" + formNum);
			String survey = request.getParameter("is_survey" + formNum);
			
			boolean isNewGroup = true;
			
			boolean groupInSurvey = (StringUtils.containsIgnoreCase(survey, "yes") || 
					StringUtils.containsIgnoreCase(survey, "true"));
			
			if (resName == null || resName.equals("Group Name")) {
				resName = resNameChoose;
				isNewGroup = false;
			}
			
			if (last == null || first == null || resName == null ||
				last.equals("") || first.equals("") || resName.equals("") ||
				last.equals("Last Name") || first.equals("First Name") || resName.equals("Group Name") || 
				resName.equals("discard")) {
				continue;
			}
			
			ElabStudent newUser = new ElabStudent();
			first = first.replaceAll(" ", "").toLowerCase();
			last = last.replaceAll(" ", "").toLowerCase();
			String studentName = first.substring(0, 1) + last.substring(0, (last.length() < 7 ? last.length() : 7));
			
			newUser.setName(studentName);

			ElabGroup group = new ElabGroup(elab);
			newUser.setGroup(group);
			group.setName(resName);

			if (StringUtils.equalsIgnoreCase(elab.getName(), "cosmic")) { // cosmic
				group.setSurvey(false); // old, deprecated handler is disabled
				group.setStudy(teacherInStudy);
				group.setNewSurvey(groupInSurvey);
				group.setNewSurveyId(newSurveyId);
			}
			else if (StringUtils.equalsIgnoreCase(elab.getName(), "ligo")) {
				// TODO: LIGO 
				// Anyone taking this test will be in the 'New Survey' system
				group.setSurvey(false);
				group.setStudy(false);
				group.setNewSurvey(groupInSurvey);
				group.setNewSurveyId(newSurveyId);
			}
			else if (StringUtils.equalsIgnoreCase(elab.getName(), "cms")) {
				// TODO: CMS
				// Anyone taking this test will be in the 'New Survey' system
			}
			students.add(newUser);
			newGroups.add(Boolean.valueOf(isNewGroup));
		}
		List passwords = elab.getUserManagementProvider().addStudents(user, students, newGroups);
		List results = new ArrayList();
		Iterator i = students.iterator(), j = passwords.iterator();
		while (i.hasNext()) {
			String password = (String) j.next();
			ElabStudent u = (ElabStudent) i.next();
		    if (password != null) {
		        List l = new LinkedList();
		        l.add(u.getGroup().getName());
		        l.add(password);
		        results.add(l);
		    }
		}
		request.setAttribute("valid", Boolean.TRUE);
		request.setAttribute("results", results);
    }
    catch (Exception e) {
   		e.printStackTrace();
        request.setAttribute("valid", Boolean.FALSE);
        request.setAttribute("error", e.getMessage());
    }
		
		%>
			<c:choose>
				<c:when test="${valid}">
					<p class="success">Your student registration completed succesfully.</p>
					<p>
						The groups we created for you (and their associated passwords) are listed below.
					</p>
					<p>
					    If one of the groups you requested already existed in our project, your group name was altered
					    slightly to ensure uniqueness.  You may now use the File...Save feature in your browser to save
					    the information below.
					</p>
					<table border="0" id="registration-results">
						<tr>
							<th>Group Name</th>
							<th>Password</th>
						</tr>
						<c:forEach items="${results}" var="result">
							<tr>
								<td>${result[0]}</td>
								<td>${result[1]}</td>
							</tr>
						</c:forEach>
					</table>
				</c:when>
				<c:otherwise>
					<p class="error">A problem occured while registering with your students:</p>
					<p class="error">${error}</p>
				</c:otherwise>
			</c:choose>
		<%
	} //end of check for submit
	else {
		%>
			<ul>
				<li>
					Register new students below.  To register more students, click on the&nbsp; 
					<strong>+</strong> &nbsp;button.
				</li>
				<li>
					We will create new groups and their associated passwords for you.
				</li>
				<li>
					Select &nbsp;<img src="../graphics/logbook_pencil.gif" valign="middle"/>&nbsp;&nbsp;&nbsp; 
					if you want the new group to take the pretest.
				</li>
			</ul>
			<form name="register" method="post" 
				action="<%= elab.secure("teacher/register-students.jsp") %>"> 

			    <table cellpadding="0" cellspacing="0" border="0" align="center" width="800">
					<%
						for (int i = 0; i < 10; i++) {
							String visibility = "";
							String minusButton = "";
							if (i == 0) {
								visibility = "visibility:visible; display:;";
							}
							else {
								visibility = "visibility:hidden; display:none;";
							}
							if (i > 0) {
							    //holly matrimony!
								minusButton = "<input name=\"less_reg" + i + 
								"\" type=\"submit\" value=\"-\" onClick=\"this.form.first" + i + 
								".value='First Name'; this.form.last" + i + 
								".value='Last Name'; this.form.is_new" + i + 
								".value='Make new group'; aLs('res_name_text" + i + 
								"').visibility = 'hidden'; aLs('res_name_text" + i + 
								"').display = 'none'; aLs('res_name_chooser" + i + 
								"').visibility = 'visible'; aLs('res_name_chooser" + i + 
								"').display = ''; HideShow(\'group_line" + i + 
								"\');HideShow(\'plus_line" + i + "\'); aLs('is_upload_box" + i + 
								"').visibility = 'hidden'; aLs('is_upload_box" + i + 
								"').display = 'none'; aLs('is_survey_box" + i + 
								"').visibility = 'hidden'; aLs('is_survey_box" + i + 
								"').display = 'none'; return false;\">";
							}
							String textChange = "var opts = this.form.res_name_choose" + i + ".options.length; ";
							for (int j = i+1; j < 9; j++) {
								textChange += "this.form.res_name_choose" + j + 
								".options[opts]=new Option(this.form.res_name" + i + 
								".value, this.form.res_name" + i + 
								".value); this.form.res_name_choose" + j + ".options[opts].selected = true;";
							}
								%>
<tr>
	<td align="left">
		<div id="group_line<%=i%>" style="<%=visibility%> border-left:3px solid #AAAAAA; padding-left:5px; padding-bottom:5px; padding-top:5px;">
        	<input type="text" name="first<%=i%>" size="14" maxlength="30" value="First Name" class="cleardefault"/>
			<input type="text" name="last<%=i%>" size="14" maxlength="30" value="Last Name" class="cleardefault"/>
			<input id="res_name_text<%=i%>" type="text" name="res_name<%=i%>" size="14" maxlength="30" value="Group Name" style="visibility:hidden; display:none;" onChange="checkNewGroup(this);<%=textChange%>" class="cleardefault">
			<select id="res_name_chooser<%=i%>" class="chosenGroups" style="visibility:visible; display:;" name="res_name_choose<%=i%>" onChange="checkMaxNumber(this);">
            	<%=optionList%>
			</select>
			<input type="submit" name="is_new<%=i%>" value="Make new group" 
				onClick="HideShow('res_name_text<%=i%>'); HideShow('res_name_chooser<%=i%>');HideShow('is_upload_box<%=i%>');HideShow('is_survey_box<%=i%>'); if (this.form.is_new<%=i%>.value=='Make new group') { this.form.is_new<%=i%>.value='Choose group'; } else { this.form.is_new<%=i%>.value='Make new group'; } return false;"/>
        </div>
    </td>
    <td align="left" valign="middle">
        <div id="is_upload_box<%=i%>" style="visibility:hidden; display:none;">
        	<%-- Disabled for LIGO
            <input type="checkbox" name="is_upload<%=i%>" value="yes"/>
            <img src="../graphics/upload_registration.gif" valign="middle"/>
             --%>
        </div>
    </td>
    <td align="left" valign="middle">
        <div id="is_survey_box<%=i%>" style="visibility:hidden; display:none;">
            <input type="checkbox" name="is_survey<%=i%>" value="yes" checked="true"/>
            <img src="../graphics/logbook_pencil.gif" valign="middle"/>
        </div>
    </td>
    <td align="right">
        <div id="plus_line<%=i%>" style="<%=visibility%> padding-right:5px;">
	        <%=minusButton%>
				<%
			        // Don't show the plus button on the last line.
			        if (i != 9) {
						%><input name="more_reg<%=i%>" type="submit" value="+" 
							onClick="HideShow('group_line<%=i+1%>');HideShow('plus_line<%=i+1%>');return false;"/><%
        			}
				%>
        </div>
    </td>
</tr>
								<%
						}//for i = 0..9
					%>
					<tr>
						<td colspan="2"><div id="messages"></div></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td align="right" colspan="4">
							<input type="submit" name="submit" value="I'm done" onclick="return checkEnteredData();"/>
						</td>
					</tr>
				</table>
				<c:choose>
					<c:when test="${not empty teacherGroups}">
					 	<c:forEach items="${teacherGroups}" var="teacherGroups">
					 		<input type="hidden" name="${teacherGroups.key}" id="tg_${teacherGroups.key}" class="existingGroups" value="${teacherGroups.value}"></input>
					 	</c:forEach>
					</c:when>
				</c:choose>					
			</form>
		<%
	}//some else up there
%>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

