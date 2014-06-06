<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.HTMLEscapingWriter"%>
<%@ page import="gov.fnal.elab.logbook.LogbookTools" %>
<%@ include file="../login/login-required.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>
<%
	String messages = "";
	String role = user.getRole();

	if (role.equals("teacher")) { 
		messages += "This page is only available to student research groups.";
	}

	String keyColor = "";
	String keyword_description = "";
	String keyword_text = "";
	String linksToEach = "";
	String keyword_loop = "";
	Integer keyword_id = null;
	String typeConstraint = " AND keyword.type IN ('SW','S') ";

	String groupName = LogbookTools.getGroupNameFromId(user.getId(), elab);
	if (groupName.startsWith("pd_") || groupName.startsWith("PD_")) {
		typeConstraint = " AND keyword.type IN ('SW','W') ";
	}

	String keyword = request.getParameter("keyword");
	if (keyword == null) {
		keyword = "";
	} // note - display all entries
	String keyword_name = keyword;
	//get project ID
	Integer project_id = elab.getId();
	String yesNo = "no";
	try {
		yesNo = LogbookTools.getYesNo(groupName, project_id, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}

	HashMap keywordTracker = new HashMap();
	ResultSet rs = null;
	try {
		rs = LogbookTools.getKeywordTracker(groupName, project_id, elab);
		while (rs.next()){
			if (rs.getObject("keyword_id") != null) {
				keyword_id= (Integer) rs.getObject("keyword_id");
				keywordTracker.put(keyword_id.intValue(), true);
			} else { 
				keyword_id = null;
			}
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}

	//provide access to all possible items to make logs on.
	ResultSet rs1 = null;
	try {
		rs1 = LogbookTools.getLogbookItems(project_id, typeConstraint, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	TreeMap<Integer, String> leftLinks = new TreeMap<Integer, String>();
	TreeMap<Integer, String> leftSublinks = new TreeMap<Integer, String>();
	String current_section = "";
	Integer keyword_count = 0;
	while (rs1.next()) {
		keyword_id = (Integer) rs1.getObject("id");
		keyword_loop = rs1.getString("keyword");
		keyword_text = keyword_loop.replaceAll("_"," ");
		keyword_description = rs1.getString("description");
		String this_section = (String)(rs1.getString("section"));
		String outer_this_section = "";
		yesNo = "no";
		keyword_count++;
		if (keyword_loop.equals("general") && (keyword.equals("") || keyword.equals("general"))) {
			leftLinks.put(keyword_count,"general");
			leftSublinks.put(keyword_count,"general");
		}
		if (!keyword_loop.equals("general")) {
			if (!this_section.equals(current_section)) {
				String section_text = "";
				char this_section_char = this_section.charAt(0);
				switch( this_section_char ) {
					case 'A': section_text="Research Basics";break;
					case 'B': section_text="A: Get Started";break;
					case 'C': section_text="B: Figure it Out";break;      
					case 'D': section_text="C: Tell Others";break;    
				}
				linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td><font face='Comic Sans MS'>"+section_text+"</font></td></tr>";
				outer_this_section = section_text;
				current_section = this_section;
				if (keyword.equals("") && !leftSublinks.containsValue(keyword_name)) {
					leftLinks.put(keyword_count, section_text);
					leftSublinks.put(keyword_count,keyword_name);
				} else {
					if (keyword.equals(keyword_name) && !leftSublinks.containsValue(keyword_name) && keyword_name.equals(keyword_loop)){
						leftLinks.put(keyword_count,section_text);
						leftSublinks.put(keyword_count,keyword_name);
					}
				}
			}
			if (keywordTracker.containsKey(keyword_id.intValue())) {
				yesNo="yes";
			}
			keyColor="";
			if (keyword.equals(keyword_loop)) { 
				keyColor="color=\"#AA3366\"";
			}
			linksToEach=linksToEach + "<tr><td><img src=\"../graphics/log_entry_" + yesNo + ".gif\" border=0 align=center><a href='showLogbook.jsp?keyword="+keyword_loop+"'><font face='Comic Sans MS'"+keyColor+">"+keyword_text+"</face></a></td></tr>";
			if (keyword.equals("") && !leftSublinks.containsValue(keyword_loop)) {
				if (!leftLinks.containsValue(outer_this_section)) {
					leftLinks.put(keyword_count,outer_this_section);		
				}
				leftSublinks.put(keyword_count,keyword_loop);
			} else {
				if (keyword.equals(keyword_name) && !leftSublinks.containsValue(keyword_loop)){
					if (!leftLinks.containsValue(outer_this_section)) {
						leftLinks.put(keyword_count,outer_this_section);		
					}
					leftSublinks.put(keyword_count,keyword_loop);
				}
			}
	
		}
	}
	
	// get group ID
	//groupName defined in common.jsp
	Integer research_group_id = user.getId();
	
	// Always pass keyword, not id so we can pick off the description
	keyword_id = null;
	ResultSet rs2 = null;
	if (!keyword.equals("")) {
		// first make sure a keyword was passed in the call
		try {
			rs2 = LogbookTools.getEntriesByKeyword(project_id, keyword, elab);
			if (rs2.next()) {
				keyword_id = (Integer) rs2.getObject("id");
				keyword_description = rs2.getString("description");
			}
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}
	String queryWhere; 
	int keyword_identification = -1;
	if (keyword_id == null) {
		queryWhere = " WHERE log.project_id = ? AND keyword.project_id in (0, ?) AND log.keyword_id = keyword.id and research_group_id = ? and role='user' ";
		keyword_identification = -1;
	} else {
		queryWhere = " WHERE log.project_id = ? and keyword.project_id  in (0, ?) and research_group_id = ? and log.keyword_id = keyword.id and keyword_id = ? and role='user' ";	
		keyword_identification = keyword_id.intValue();
	}
	int itemCount=0;
	ResultSet rs3 = null;
	TreeMap<String, String> logbookSections = new TreeMap<String, String>();
	TreeMap<String, ArrayList> logbookSubsections = new TreeMap<String, ArrayList>();
	TreeMap<String, ArrayList> logbookResults = new TreeMap<String, ArrayList>();
	try {
		rs3 = LogbookTools.getLogbookDetails(queryWhere, elab, project_id, research_group_id, keyword_identification);
		while (rs3.next()) {
			ArrayList logbookSubsectionDetails = new ArrayList();
			ArrayList logbookDetails = new ArrayList();
			int data_keyword_id=rs3.getInt("data_keyword_id");
			int log_id=rs3.getInt("log_id");
			int section_id=rs3.getInt("section_id");
			String dateText=rs3.getString("date_entered");
			keyword_description=rs3.getString("description");
			String log_text=rs3.getString("log_text");
			log_text = log_text.replaceAll("''", "'");
			keyword_name=rs3.getString("keyword_name");
			String keyword_display=keyword_name.replaceAll("_"," ");
			String section=rs3.getString("section");
			itemCount++;
			logbookDetails.add(data_keyword_id);
			logbookDetails.add(log_id);
			logbookDetails.add(section_id);
			logbookDetails.add(dateText);
			logbookDetails.add(log_text);
			logbookDetails.add(keyword_name);
			logbookDetails.add(section);
			logbookDetails.add(keyword_description);
			logbookDetails.add(keyword_display);
			logbookSubsectionDetails.add(keyword_description);
			logbookSubsectionDetails.add(keyword_display);
			
			/////find the comment crap
			Long comment_count = LogbookTools.getCommentCount(log_id, elab);
			Long comment_new = LogbookTools.getCommentCountNew(log_id, elab);
			String comment_info="";
			
			if (!(comment_count == null) && !(comment_count == 0L)) {
				if (comment_new == 0L) {
					comment_info=comment_info+"<BR><FONT size=-2>comments: "+comment_count+"</font>";
				}
				else {
					if (comment_count == null) {
						comment_count = 0L;
					}
					comment_info=comment_info+"<BR><IMG SRC=\'graphics/new_flag.gif\' border=0 align=\'middle\'> <FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) " +"</font>";
				}
			}
			logbookDetails.add(comment_info);
			String sectionText = "";
			char this_section_char = section.charAt(0);
			switch( this_section_char ) {
				case 'A': sectionText="Research Basics";break;
				case 'B': sectionText="A: Get Started";break;
				case 'C': sectionText="B: Figure it Out";break;      
				case 'D': sectionText="C: Tell Others";break;    
			}	
			if (keyword_name.equals("general")) {
				logbookSections.put(keyword_name, "general");
			} 
			if (!logbookSections.containsKey(keyword_name) && !keyword_name.equals("general")) {
					logbookSections.put(keyword_name, sectionText);
			}
			if (!logbookSubsections.containsKey(keyword_name)) {
				logbookSubsections.put(String.valueOf(keyword_name), logbookSubsectionDetails);			
			}
			logbookResults.put(String.valueOf(keyword_name)+"-"+String.valueOf(itemCount), logbookDetails);
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	request.setAttribute("messages", messages);
	request.setAttribute("yesNo", yesNo);
	request.setAttribute("keyword_id", keyword_id);
	request.setAttribute("keyword_name", keyword_name);
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("leftLinks", leftLinks);
	request.setAttribute("leftSublinks", leftSublinks);
	request.setAttribute("logbookSections", logbookSections);
	request.setAttribute("logbookSubsections", logbookSubsections);
	request.setAttribute("logbookResults", logbookResults);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	
	<body id="showlogbook" onload='self.focus();'>
		<!-- entire page container -->
		<div id="container">	
			<div id="content">
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
											<td valign="center" align="left">
												<a href="showLogbook.jsp"><font face="Comic Sans MS"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt=""> All Entries</font></a>
											</td>
										</tr>
										<tr>
											<td>
												<img src="../graphics/log_entry_${yesNo}.gif" border="0" align="center" alt=""><a href="showLogbook.jsp?keyword=general"><font face="Comic Sans MS">general</font></a>
											</td>
										</tr>
										<tr>
											<td>
												<b><br><font face="Comic Sans MS">Milestones from<br>Research Basics<br>and Study Guide</font></b>
											</td>
										</tr>
										<tr>
											<td align="center">
												<img src="../graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font>
											</td>
										</tr>
										<%=linksToEach%>
									</table>
								</td>
								<td align="left" width="20" valign="top">
									<img src="../graphics/blue_square.gif" border="0" width="2" height="500" alt="">
								</td>
								<td valign="top" align="center">		
									<table width="600">
										<tr>
											<td align="right">
												<img src="../graphics/logbook_large.gif" align="middle" border="0" alt="">
											</td>
											<td>
												<h2><font face="Comic Sans MS">Logbook Entry for Group "<%=groupName%>"</font></h2>
											</td>
										</tr>
									</table>
									<table>
										<tr>
											<td align="center" height="20">&nbsp;</td>
										</tr>
									</table>
								<div style="border-style: dotted; border-width: 1px;">
									<table width="600">
										<tr>
											<td align="left" colspan="4">
												<font size="+1" face="Comic Sans MS">Instructions</font>
											</td>
										</tr>
										<tr align="center">
											<td align="right">
												<img src="../graphics/logbook_pencil.gif" align="middle" border="0" alt="">
											</td>
											<td align="left">
												<font face="Comic Sans MS">Button to add a logbook entry.</font>
											</td>
											<td align="right">
												<img src="../graphics/logbook_view_comments_small.gif" border="0" align="middle" alt="">
											</td>
											<td align="left">
												<font face="Comic Sans MS">Button to view your teacher's comments.</font>
											</td>
										</tr>
										<tr>
											<td align="center" colspan="4">
												<font size="-2" face="Comic Sans MS">Comments: Number of teacher comments (<font color="#AA3366"> number unread </font>). New comments by your teacher are marked as <img src="../graphics/new_flag.gif" border="0" align="center" alt=""></font>.
											</td>
										</tr>
									</table>
								</div>
								<table width="600" cellspacing="5">
									<c:choose>
										<c:when test="${not empty leftLinks }">
											<c:forEach items="${leftLinks }" var="leftLinks"> 
												<c:choose>
													<c:when test='${leftLinks.value == "general" }'>
														<tr align="left"><td colspan="2"><font face="Comic Sans MS" size="+2"></font></td></tr>
													</c:when>
													<c:otherwise>
														<tr align="left"><td colspan="2"><font face="Comic Sans MS" size="+2">${leftLinks.value }</font></td></tr>	
													</c:otherwise>
												</c:choose>	
												<c:forEach items="${leftSublinks }" var="leftSublinks">
													<c:forEach items="${logbookSections }" var="logbookSections">
														<c:choose>
															<c:when test="${leftSublinks.value == logbookSections.key }">	
																<c:choose>
																	<c:when test="${logbookSections.value == leftLinks.value }">
																		<c:forEach items="${logbookSubsections }" var="logbookSubsections">
																			<c:choose>
																				<c:when test='${logbookSections.key == fn:substring(logbookSubsections.key, 0, fn:indexOf(logbookSubsections.key,  "-")) }'>
																					<tr align="left">
																						<td colspan="2">
																							<font face="Comic Sans MS" size="+1" color="#AA3366">${logbookSubsections.value[1] }</font> - 
																							<font face="Comic Sans MS">${logbookSubsections.value[0]}</font> 
																							<a href="logEntry.jsp?keyword=${ logbookSubsections.key}"><img src="../graphics/logbook_pencil.gif" border="0" align="middle" alt="">
																							</a>
																							&nbsp;&nbsp;
																							<a href="showCommentsForKW.jsp?keyword=${ logbookSubsections.key}">
																								<img src="../graphics/logbook_view_comments_small.gif" border="0" align="middle" alt="">
																							</a>
																						</td>
																					</tr>
																					<c:forEach items="${logbookResults}" var="logbookResults">
																						<c:choose>
																							<c:when test='${ logbookSubsections.key == fn:substring(logbookResults.key, 0, fn:indexOf(logbookResults.key,  "-")) }' >
																								<tr>
																									<td valign="top" width="150" align="right"><font
																										face="Comic Sans MS">${logbookResults.value[3] }${logbookResults.value[9]}  <font>
																									</font></font></td>
																									<td width="450" valign="top"><font face="Comic Sans MS"><e:whitespaceAdjust
																										text="${logbookResults.value[4] }" /></font></td>
																								</tr>
																							</c:when>
																						</c:choose>
																					</c:forEach>	
																				</c:when>
																			</c:choose>
																		</c:forEach>
																	</c:when>
																</c:choose>
															</c:when>
														</c:choose>	
													</c:forEach>
												</c:forEach>										
											</c:forEach>							
										</c:when>
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
