<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	String ref_rg_name = request.getParameter("ref_rg_name"); // this is the name we are referring to in the logbook
	Integer project_id = elab.getId();
	Integer research_group_id = user.getGroup().getId();
    String teacher_name = user.getTeacher();

	//get all research groups and build links
	Collection<ElabGroup> rgTeacherGroups = user.getGroups();
	Iterator i = rgTeacherGroups.iterator();
	String linksToEachGroup = "";
	while (i.hasNext()){
		ElabGroup eg = (ElabGroup) i.next();
		if (eg.getRole().equals("user") || eg.getRole().equals("upload")) {
			//EPeronja-only display active research groups
			if (eg.getActive()) {
				linksToEachGroup = linksToEachGroup
						+ "<tr><td><A HREF='show-logbook-teacher.jsp?ref_rg_name="+ eg.getName() + "'>" + eg.getName()+ "</A></td></tr>";
			}
		}
	}//end while loop

	Integer ref_rg_id = null;
	if (!(ref_rg_name == null) && (!ref_rg_name.equals("general"))) {
		ElabGroup eg1 = user.getGroup(ref_rg_name);
		ref_rg_id = eg1.getId();
		if (ref_rg_id == null) {
			messages += "Problem with ID for student research group " + ref_rg_name;
		}
	} else {
		if (!(ref_rg_name == null) && ref_rg_name.equals("general")) {
			ref_rg_id = research_group_id; // general references for teachers will be self referential.
		} 
		else {
			ref_rg_name = "";// note - display all entries
		}
	}

	int itemCount = 0;
	ResultSet rs = null;

	String subtitle = "Display header";
	//check whether to retrieve for all groups or for a specific group
	if (ref_rg_name.equals("")) {
		subtitle = "For all groups for teacher " + teacher_name;
		try {
			//false at the end indicates only active research groups
			rs = LogbookTools.getLogbookEntriesForAllGroups(elab, project_id, research_group_id, false);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	} else {
		if (ref_rg_name.equals("general")) {
			subtitle = "General notes for teacher " + teacher_name;
		} else {
			subtitle = "For group " + ref_rg_name + " for teacher "+ teacher_name;
		}
		try {
			rs = LogbookTools.getLogbookEntriesForGroup(elab, project_id, research_group_id, ref_rg_id);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}//end of testing what to retrieve

	//retrieve logbook details
	TreeMap<String, ArrayList> ids = new TreeMap<String, ArrayList>();
	TreeMap<String, ArrayList> logbookResults = new TreeMap<String, ArrayList>(){
		public int compare(String s1, String s2) {
			int rank = getRank(s1) - getRank(s2);
			return rank;
		}
		private int getRank(String s) {
			String innerRank = s.substring(s.indexOf("-")+1, s.length());
			return Integer.parseInt(innerRank);
		}
	};
	//build logbook results
	if (rs != null) {
		while (rs.next()) {
			ArrayList logbookDetails = new ArrayList();
			String dateText = rs.getString("date_entered");
			String log_text = rs.getString("log_text");
			log_text = log_text.replaceAll("''", "'");
			String log_id = rs.getString("log_id");
			ref_rg_id = rs.getInt("ref_rg_id");
			itemCount++;
			logbookDetails.add(dateText);
			logbookDetails.add(log_text);
			logbookDetails.add(log_id);
			logbookResults.put(String.valueOf(ref_rg_id)+"-"+String.valueOf(itemCount), logbookDetails);
			String gn = LogbookTools.getGroupNameFromId(ref_rg_id, elab);
			ArrayList userDetails = new ArrayList();
			userDetails.add(gn);
			userDetails.add(String.valueOf(research_group_id));
			ids.put(String.valueOf(ref_rg_id), userDetails);			
		}//end looping through resultset
	}//end of checking rs for null
	
	request.setAttribute("messages", messages);
	request.setAttribute("linksToEachGroup", linksToEachGroup);
	request.setAttribute("subtitle", subtitle);
    request.setAttribute("research_group_id", research_group_id);
    request.setAttribute("ref_rg_id", ref_rg_id);    
	request.setAttribute("ids", ids);
	request.setAttribute("logbookResults", logbookResults);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Show Research Group Logbook for Teacher</title>
		<link rel="stylesheet" href="styletut-teacher.css" type="text/css">
	</head>
	<body id="show-logbook-teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<table width="800">
					<tr>
						<td width="150">&nbsp;</td>
						<td width="100" align="right"><img src="../graphics/logbook_view_large.gif" align="middle" border="0" alt=""></td>
						<td width="550"><font size="+2">Teachers: View Your <b>Private</b> Logbook<br /> on Student Research Groups.</font></td>
					</tr>
				</table>
				<center>
				
				<c:choose>
					<c:when test="${not empty messages }">
						${messages }
					</c:when>
					<c:otherwise>
						<table width="800" cellpadding="0" border="0" align="left">
							<tr>
								<td valign="top" align="150">
									<table width="140">
										<tr>
											<td valign="center" align="left"><b>Student Logbooks</b></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="../logbook/show-logbook-keyword-teacher.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt=""><font color="#1A8BC8">By Milestone</font></a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a	href="../logbook/show-logbook-group-teacher.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt=""><font color="#1A8BC8">By Group</font></a></td>
										</tr>
										<tr>
											<td><b>Your Logbook:<br />
												<a href="show-logbook-teacher.jsp?ref_rg_name=general">general</a><br /><br />Select a Research Group</b></td>
										</tr>
										${linksToEachGroup}
										<tr>
											<td valign="center" align="left"><a href="show-logbook-teacher.jsp">All Groups</a></td>
										</tr>
									</table>
								</td>
								<td align="left" width="20" valign="top"><img src="../graphics/red_square.gif" border="0" width="2" height="475" alt=""></td>
								<td valign="top" align="center">
									<div style="border-style: dotted; border-width: 1px;">
										<table width="600">
											<tr>
												<td align="left" colspan="4"><font size="+1" face="Comic Sans MS">Instructions</font></td>
											</tr>
											<tr>
												<td align="right"><img src="../graphics/logbook_pencil.gif" align="middle" border="0" alt=""></td>
												<td align="left">Button to add logbook entry.</td>
											</tr>
										</table>
									</div>
									<h2>${subtitle }</h2>
									<p>
								<table>
									<c:choose>
										<c:when test="${not empty ids }">
											<c:forEach items="${ids }" var="ids">
												<tr align="center">
													<td colspan="2"><font size="+1">${ids.value[0] }</font>
														<a href="../logbook/log-entry-teacher.jsp?research_group_id=${ids.value[1]}&amp;ref_rg_id=${ids.key}">
														<img src="../graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>
													</td>
												</tr>
												<c:choose>
													<c:when test="${not empty logbookResults }">
														<c:forEach items="${logbookResults }" var="logbookResults">
															<c:if test='${ids.key == fn:substring(logbookResults.key, 0, fn:indexOf(logbookResults.key,  "-"))}'>
																<tr>
																	<td valign="top" width="175" align="right">${logbookResults.value[0] }</td>
																	<td width="400" valign="top"><e:whitespaceAdjust
																		text="${logbookResults.value[1] }" /></td> 
																</tr>
															</c:if>		
														</c:forEach>
													</c:when>
												</c:choose>
											</c:forEach>
										</c:when>
											<c:otherwise>
												<tr><td colspan="2"><font size="+1">No entries.</font>
													<a href="../logbook/log-entry-teacher.jsp?research_group_id=${research_group_id}&amp;ref_rg_id=${ref_rg_id}"><img src="../graphics/logbook_pencil.gif" border="0" align="top" alt=""></a> 
												</td></tr>
											</c:otherwise>										
									</c:choose>
								</table>
								</td>
							</tr>
						</table>
					</c:otherwise>
				</c:choose>
				</center>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->		
	</body>
</html>
