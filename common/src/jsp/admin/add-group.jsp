<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.util.Calendar.*" %>
<%@ page import="java.util.GregorianCalendar.*" %>
<%@ page import="org.mindrot.BCrypt" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
	String messages = "";
	String done = "";
	String state = request.getParameter("state");
	String stateNew = request.getParameter("stateNew");
	String stateType = request.getParameter("stateType");
	String stateAbbrev = request.getParameter("stateAbbrev");
	String city = request.getParameter("city");
	String cityNew = request.getParameter("cityNew");
	String school = request.getParameter("school");
	String schoolNew = request.getParameter("schoolNew");
	//String teacher = request.getParameter("teacher");
	String teacherNew = request.getParameter("teacherNew");
	String teacherEmail = request.getParameter("teacherEmail");
	String researchGroup = request.getParameter("researchGroup");
	String[] researchProject = request.getParameterValues("researchProject");
	String ay = request.getParameter("ay");
	String groupRole = request.getParameter("groupRole");
	String detectorString = request.getParameter("detectorString");
	String survey = request.getParameter("survey");
	String passwd1 = request.getParameter("passwd1");
	String passwd2 = request.getParameter("passwd2");
	String newAccState, newAccCity, newAccSchool, newAccTeacher, newAccEmail, newAccRG, newAccAY, newAccGR, newAccDAQ, newAccRP, newAccSurvey;
	newAccState=newAccCity=newAccSchool=newAccTeacher=newAccEmail=newAccRG=newAccAY=newAccGR=newAccDAQ=newAccRP=newAccSurvey="";

	String submit =  request.getParameter("submitinfo");

	int stateId = 0;
	String stateName = "";
	int cityId = 0;
	String cityName = "";
	int schoolId = 0;
	String schoolName = "";
	int teacherId = 0;
	String teacherName = "";
	int researchGroupId = 0;
	ServletContext context = getServletContext();
	String home = context.getRealPath("").replace('\\', '/');

	TreeMap<Integer, ArrayList> states = new TreeMap<Integer, ArrayList>();
	TreeMap<Integer, ArrayList> cities = new TreeMap<Integer, ArrayList>();
	TreeMap<Integer, ArrayList> schools = new TreeMap<Integer, ArrayList>();
	TreeMap<Integer, ArrayList> teachers = new TreeMap<Integer, ArrayList>();
	TreeMap<Integer, ArrayList> groups = new TreeMap<Integer, ArrayList>();
	TreeMap<Integer, String> projects = new TreeMap<Integer, String>();
	TreeMap<String, String> academicyears = new TreeMap<String, String>();
	try {
		states = DataTools.getStates(elab);
		cities = DataTools.getCities(elab);
		schools = DataTools.getSchools(elab);
		teachers = DataTools.getTeachers(elab);
		groups = DataTools.getGroups(elab);
		projects = DataTools.getProjects(elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}

	int currentYear = Calendar.getInstance().get(Calendar.YEAR);
	int currentMonth = Calendar.getInstance().get(Calendar.MONTH);
	for (int i = 2004; i <= currentYear+1; i++){
		academicyears.put(String.valueOf(i), String.valueOf(i)+"-"+String.valueOf(i + 1));
	}
	//take into account that year changes in July
	int defaultYear = currentYear;
	if (currentMonth > 6) {
		defaultYear = currentYear + 1;
	}

	// The form on this page POSTs back to the page.
	// If we're processing POSTed data:
	if (submit != null && submit.equals("Submit")) {
		if (!stateNew.equals("") && !stateAbbrev.equals("") && !stateType.equals("")) {
			//need to add a new state - checkings should be done by javascript before submitting
			newAccState = stateAbbrev;
			int statetype = Integer.parseInt(stateType);
			stateId = DataTools.insertState(elab, stateNew, stateAbbrev, statetype);
			stateName = stateAbbrev;
		} else {
			if (state != null && !state.equals("")) {
				stateId = Integer.valueOf(state);
				stateName = DataTools.getStateAbbrev(elab, stateId);
				newAccState = stateName;
			} else {
				messages = "Not a valid state: "+ stateName;
			}
		}
		if (stateId > 0) {
			if (!cityNew.equals("")) {
				cityId = DataTools.insertCity(elab, cityNew, stateId);
				newAccCity = cityName = cityNew;
			} else {
				if (city != null && !city.equals("")) {
					cityId = Integer.valueOf(city);
					newAccCity = cityName = DataTools.getCityName(elab, cityId);
				} else {
					messages = "Not a valid city: "+ cityName;
				}
			}
		}
		if (cityId > 0) {
			if (!schoolNew.equals("")) {
				schoolId = DataTools.insertSchool(elab, schoolNew, cityId);
				newAccSchool = schoolName = schoolNew;
			} else {
				if (school != null && !school.equals("")) {
					schoolId = Integer.valueOf(school);
					newAccSchool = schoolName = DataTools.getSchoolName(elab, schoolId);
				} else {
					messages = "Not a valid school: "+ schoolName;
				}
			}
		}
		if (schoolId > 0) {
			if (!teacherNew.equals("")) {
				teacherId = DataTools.insertTeacher(elab, teacherNew, teacherEmail, schoolId);
				newAccTeacher = teacherName = teacherNew;
				newAccEmail = teacherEmail;
			}
		}
		String[] researchProjectName = new String[researchProject.length];
		for (int i = 0; i < researchProject.length; i++) {
			int rp = Integer.parseInt(researchProject[i]);
			for (Map.Entry<Integer,String> e : projects.entrySet()) {
				if (e.getKey() == rp) {
					researchProjectName[i] = e.getValue();
					newAccRP += e.getValue() + " ";
				}
			}
		}

		//create directories that are needed
		if(researchGroup != null && researchProject != null && ay != null && groupRole != null && survey != null && passwd1 != null && passwd2 !=null) {
			// Why are these directories set up before the test to see if the name and password is taken? LQ 7/25/06
			//EPeronja 06/18/2015: I think the answer is that if we fail to create the directory then we do not have a userarea?
			newAccRG = researchGroup;
			newAccAY = ay;
			newAccGR = groupRole;
			newAccSurvey = survey;
			// Iterate over all submitted projects (cosmic, cms, ...)
			for (int x = 0; x < researchProject.length; x++) {
				String singleResearchProjectName = researchProjectName[x];
				boolean mkdir, isDirectory;
				//directory structure:
				//home + users + ay/state/city/school/teacher/group/
				String[] newDirsArray = new String[] {
						ay,
						stateName,
						cityName.replaceAll(" ", "_"),
						schoolName.replaceAll(" ", "_"),
						teacherName.replaceAll(" ", "_"),
						researchGroup,
						singleResearchProjectName
				};
				String currDir = home + "/" + singleResearchProjectName + "/users"; 
				File newDir;
				for(int i=0; i<7; i++){
					currDir = currDir + "/" + newDirsArray[i].replaceAll(" ", "_"); //replace spaces with underscores for the directory name
					newDir = new File(currDir);
					try {
						isDirectory = newDir.isDirectory();
					} catch(SecurityException e) {
						messages = "Security permissions do not allow this directory (" + newDir + ") to be accessed";
						return;
					}

					if(!isDirectory){
						mkdir = newDir.mkdirs();
						if(mkdir == false){
							messages = "Directory: " + newDir + " couldn't be created! (when trying to add the directory: " + newDirsArray[i] + ")";
							return;
						}
					}
					//else if we're adding the group...
					else if(i==5){
						messages = "The group directory: " + newDirsArray[i] + " already exists on the system.\n<br>Use the back button on your browser and enter a different group name.";
						return;
					}
				}

				//the newUserArea base dir is now totally setup
				String newUserArea = newDirsArray[0] + "/" + newDirsArray[1] + "/" + newDirsArray[2] + "/" + newDirsArray[3] + "/" + newDirsArray[4] + "/" + newDirsArray[5];

				//setup subdirectories - Note that users is actually a symlink to
				// users -> /export/d1/quarknet/portal/users
				// Each e-Lab will need a similar symlink.
				String[] newSubdirsArray = new String[] {"plots", "posters", "scratch"};
				for(int i=0; i<3; i++){
					currDir = home + "/" +researchProjectName+"/users/" + newUserArea + "/" + researchProjectName + "/" + newSubdirsArray[i];
					newDir = new File(currDir);
					try {
						isDirectory = newDir.isDirectory();
					} catch(SecurityException e) {
						messages = "Security permissions do not allow this directory (" + newDir + ") to be accessed";
						return;
					}

					if(!isDirectory){
						mkdir = newDir.mkdirs();
						if(mkdir == false){
							messages = "Directory: " + newDir + " couldn't be created! (when trying to add the directory: " + newSubdirsArray[i] + ")";
							return;
						}
					}
				}

				//add the new registration information to research_group
				int i=0;

				// Generate hashed passwords just one time
				if ( x == 0 ) {
					String hashedPassword = BCrypt.hashpw(passwd1, BCrypt.gensalt(12)); 
					researchGroupId = DataTools.insertGroup(elab, researchGroup, hashedPassword, groupRole, newUserArea, ay, survey, teacherId);
				}

				//add the new group-project pair to research_group_project
				i = DataTools.insertGroupProject(elab, Integer.parseInt(researchProject[x]), researchGroupId);
				//add the new group-detectorID pair(s) to research_group_detectorid (if there are any) and just one time
				if ( x == 0 ) {
					if(detectorString != null && !detectorString.equals("")) {
						newAccDAQ = detectorString;
						String[] detectorIds = detectorString.split(",");
						i = DataTools.insertGroupDetector(elab, researchGroupId, detectorIds);
					}
				}
			}//end of looping through the projects

			done = "done";

		} else {
			messages = "Failed to add teacher. Report problem to e-labs@fnal.gov.";
		}
	}//end of submit

	// This is the alternate form of POST submission processing
	if (submit != null && submit.equals("Add a new teacher")) {
		done = "";
		messages = "";
	}

	request.setAttribute("messages", messages);
	request.setAttribute("done", done);
	request.setAttribute("states", states);
	request.setAttribute("cities", cities);
	request.setAttribute("schools", schools);
	request.setAttribute("teachers", teachers);
	request.setAttribute("groups", groups);
	request.setAttribute("projects", projects);
	request.setAttribute("academicyears", academicyears);
	request.setAttribute("defaultYear", defaultYear);
	request.setAttribute("survey", survey);
	request.setAttribute("newAccState",newAccState);
	request.setAttribute("newAccCity",newAccCity);
	request.setAttribute("newAccSchool",newAccSchool);
	request.setAttribute("newAccTeacher",newAccTeacher);
	request.setAttribute("newAccEmail",newAccEmail);
	request.setAttribute("newAccRG",newAccRG);
	request.setAttribute("newAccAY",newAccAY);
	request.setAttribute("newAccGR",newAccGR);
	request.setAttribute("newAccDAQ",newAccDAQ);
	request.setAttribute("newAccRP",newAccRP);
	request.setAttribute("newAccSurvey",newAccSurvey);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Add Users</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/add-group.css"/>
		<!-- <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>	-->
		<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
		<script type="text/javascript" src="add-group.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="add-group">
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
				<h1>Input the information for your new teacher.</h1>
				<form name="myform" method="post" onsubmit="return validateForm();">
					<table width="740" border="1">
						<c:choose>
							<c:when test='${done == "" }'>
								<tr>
									<td>
										<center>
											<table id="main-table">
												<tr>
													<td></td>
													<td colspan="3"><br />
														States includes states from the U.S., provinces from Canada, and countries.  
    												When registering countries other than Canada and the U.S., use the country name 
    												for state and these three letter
    												<e:popup href="../jsp/abbrev.jsp" target="abbrev"
																		 width="400" height="700">abbreviations
														</e:popup>.
													</td>
												</tr>
												<tr>
													<td>State or Country</td>
													<td>
														<select name="state" id="state">
															<option></option>
															<c:forEach items="${states }" var="state">
																<option name="${state.value[2] }"
																				value="${state.key }">${state.value[2] }
																</option>
															</c:forEach>
														</select>
													</td>
													<td>
														OR enter a new province/country, abbreviation and state type.<br />
														<input type="text" id="stateNew" name="stateNew"
																	 value="" size="30" maxlength="50">
														</input>
														<input type="text" id="stateAbbrev" name="stateAbbrev"
																	 value="" size="5" maxlength="3">
														</input>
														<select name="stateType" id="stateType">
															<option value="0" selected>Select type</option>
															<option value="2">Province</option>
															<option value="3">Country</option>
														</select>
														<br />
													</td>
												</tr>
												<tr>
													<td>City</td>
													<td>
														<select name="city" id="city"></select>
													</td>
													<td>
														OR enter a new city
														<input type=text name=cityNew id="cityNew" value=""
																	 size=30 maxlength=50 >
														</input>
														<div class="details" id="cityList"
																 style="display: inline-block;" >
															<img src="../graphics/view_data.gif" alt=" "
																	 border="0" />
															<span class="tooltip" id="cityTooltip"></span>
														</div>
													</td>
												</tr>
												<tr>
													<td>School/Institution</td>
													<td>
														<select name="school" id="school"></select>
													</td>
													<td>
														OR enter a new school/institution
														<input type=text id="schoolNew" name=schoolNew
																	 value="" size=30 maxlength=50>
														</input>
														<div class="details" id="schoolList"
																 style="display: inline-block;" >
															<img src="../graphics/view_data.gif" alt=" "
																	 border="0" />
															<span class="tooltip" id="schoolTooltip"></span>
														</div>
													</td>
												</tr>
												<tr>
													<td>New teacher/leader</td>
													<td colspan="2">
														<input type=text name=teacherNew id="teacherNew"
																	 value="" size=30 maxlength=50>
														</input>
														<div class="details" id="teacherList"
																 style="display: inline-block;" >
															<img src="../graphics/view_data.gif" alt=" "
																	 border="0" />
															<span class="tooltip" id="teacherTooltip"></span>
														</div>
													</td>
												</tr>
												<tr>
													<td>Teacher's/Leader's Email</td>
													<td colspan="2">
														<input type=text name=teacherEmail id="teacherEmail"
																	 value="" size=30 maxlength=50>
														</input>
													</td>
												</tr>
												<tr>
													<td>Group Name</td>
													<td colspan="2">
														<input type=text name=researchGroup id="researchGroup"
																	 	value="" size=30 maxlength=50>
														</input>
													</td>
												</tr>
												<tr>
													<td>Project</td>
													<td>
														<c:forEach items="${projects }" var="p">
															<input type="checkbox" name="researchProject"
																		 value="${p.key }" id="project${p.key }">
																${p.value }
															</input>
														</c:forEach>
													</td>
													<td>
														<div id="daqs" style="visibility: hidden;">
															DAQ Board ID(s)
															<input type="text" name="detectorString"
																		 id="detectorString" value="" size=30
																		 maxlength=500>
															</input>
															(e.g. 180,181,182)
														</div>
													</td>
												</tr>
												<tr>
													<td>Academic Year</td>
													<td colspan="2">
														<select name="ay" id="ay">
															<c:forEach items="${academicyears }" var="ay">
																<c:choose>
																	<c:when test="${defaultYear == ay.key }">
																		<option value ="AY${ay.key }" selected>
																			${ay.value }
																		</option>
																	</c:when>
																	<c:otherwise>
																		<option value ="AY${ay.key }">
																			${ay.value }
																		</option>
																	</c:otherwise>
																</c:choose>
															</c:forEach>
														</select>
													</td>
												</tr>
												<tr>
													<td>In Survey</td>
													<td colspan="2">
														<input type="radio" name="survey" value="no" checked>
															No
														</input>
														<input type="radio" name="survey" value="no" >
															Yes
														</input>
													</td>
												</tr>
												<tr>
													<td>Password</td>
													<td colspan="2">
														<input type="password" name="passwd1" id="passwd1"
																	 size="16" maxlength="72">
													</td>
                        </tr>
												<tr>
													<td>Verify Password</td>
													<td colspan="2">
														<input type="password" name="passwd2" id="passwd2"
																	 size="16" maxlength="72">
													</td>
												</tr>
												<tr>
													<td colspan="3">
														<div style="text-align: center;">
															<input type="submit" name="submitinfo" value="Submit">
														</div>
													</td>
												</tr>
											</table>
										</center>
									</td>
								</tr>
							</c:when>
    					<c:otherwise>
								<tr>
									<td>
										<table width="100%">
											<tr>
												<td>
													<c:choose>
														<c:when test='${done == "done" }'>
															<table>
																<tr>
																	<td colspan="2"><font color="green">
																		New group: ${newAccRG } created successfully!
																	</font><br /></td>
																</tr>
																<tr>
																	<td>State or Country: </td>
 																	<td>${newAccState }</td>
																</tr>
																<tr>
																	<td>City: </td>
																	<td>${newAccCity }</td>
																</tr>
																<tr>
																	<td>School/Institution: </td>
																	<td>${newAccSchool }</td>
																</tr>
																<tr>
																	<td>Teacher/Leader: </td>
																	<td>${newAccTeacher }</td>
																</tr>
																<tr>
																	<td>Teacher's/Leader's Email: </td>
																	<td>${newAccEmail }</td>
																</tr>
																<tr>
																	<td>Group Name: </td>
																	<td>${newAccRG }</td>
																</tr>
																<tr>
																	<td>Project(s): </td>
																	<td>${newAccRP }</td>
																</tr>
																<tr>
																	<td>Academic Year: </td>
																	<td>${newAccAY }</td>
																</tr>
																<tr>
																	<td>Role: </td>
																	<td>${newAccGR }</td>
																</tr>
																<c:if test='${newAccDAQ != "" }'>
																	<tr>
																		<td>DAQ Board ID(s): </td>
																		<td>${newAccDAQ }</td>
																	</tr>
																</c:if>
																<tr>
																	<td>In Survey: </td>
																	<td>${newAccSurvey }</td>
																</tr>
															</table>
 															<c:if test='${ survey == "Yes" }'>
 																If you wish to add students to your group (who must complete the survey), 
 																return to the
																a href="../login/logout.jsp">Registration Page</a> and login with your new group name.<br />
															</c:if>
															<c:if test='${ groupRole == "teacher" }'>
																You may add
															<a href="../login/login.jsp?user=<%=researchGroup%>&pass=<%=passwd1%>&project=<%=researchProject%>">
																 teachers or research groups</a> as a teacher with logon group <%=researchGroup%>.<br />
															</c:if>
														</c:when>
													</c:choose>
												</td>
											</tr>
											<tr><td>
												<div style="text-align: center;">
													<input type="submit" name="submitinfo"
															 	 value="Add a new teacher">
													</input>
												</div>
											</td></tr>
										</table>
									</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</table>
					<input type="hidden" name="groupRole" id="groupRole" value="teacher">
					</input>
				</form>
				<div id="messages">${messages }</div>
			</div><!-- End <div id="content"> -->
			
			<c:forEach items="${states }" var="sa">
				<input type="hidden" name="stateAbbreviation" value="${sa.value }">
			</c:forEach>
			<c:forEach items="${cities }" var="c">
				<input type="hidden" name="cityIn${c.value[1] }" value="${c.value}">
			</c:forEach>
			<c:forEach items="${schools }" var="s">
				<input type="hidden" name="schoolIn${s.value[1]}${s.value[2]}"
							 value="${s.value}">
			</c:forEach>
			<c:forEach items="${teachers }" var="t">
				<input type="hidden" name="teacherIn${t.value[3]}${t.value[4]}${t.value[5]}"
							 value="${t.value}">
			</c:forEach>
			<c:forEach items="${groups }" var="g">
				<input type="hidden" name="groups" value="${g.value}">
			</c:forEach>

			<!-- end content -->

			<div id="footer"></div>
		</div>
		<!-- end container -->
	</body>
</html>
