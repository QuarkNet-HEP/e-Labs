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
	String keyColor = "";
	String keyword_description = "";
	String keyword_text = "";
	String keyword_loop = "";
	Integer keyword_id = null;
	String typeConstraint = " AND keyword.type IN ('SW','S') ";
	String role = user.getRole();
	String groupName = user.getName();
	int project_id = elab.getId();

	if (role.equals("teacher")) { 
		messages += "This page is only available to student research groups.";
	}
	if (groupName.startsWith("pd_") || groupName.startsWith("PD_")) {
		typeConstraint = " AND keyword.type IN ('SW','W') ";
	}
	String keyword = request.getParameter("keyword");
	if (keyword == null) {
		keyword = "";
	} // note - display all entries
	String keyword_name = keyword;
	
	String yesNo = "no";
	try {
		yesNo = LogbookTools.getYesNoGeneral(groupName, project_id, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	//get all keywords for this research group
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
	try {
		rs = LogbookTools.getLogbookKeywordItems(project_id, typeConstraint, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	//build all links
	String linksToEach = LogbookTools.buildLogbookLinksToKeywords(rs, keywordTracker, keyword);

	int research_group_id = user.getId();	
	// Need to check if a keyword was passed in the parameters
	keyword_id = null;
	if (!keyword.equals("")) {
		// first make sure a keyword was passed in the call
		try {
			rs = LogbookTools.getKeywordDetailsByProject(project_id, keyword, elab);
			if (rs.next()) {
				keyword_id = (Integer) rs.getObject("id");
				keyword_description = rs.getString("description");
			}
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}
	//Let's build the results
	int itemCount=0;
	int sectionOrder=1;
	//Keep the same section order as with the links on the left
	TreeMap<Integer, String> logbookSectionOrder = new TreeMap<Integer, String>();
	//Save the section text for each section
	TreeMap<String, String> logbookSections = new TreeMap<String, String>();
	//Save all keywords with comments for each section
	TreeMap<String, ArrayList> logbookSectionKeywords = new TreeMap<String, ArrayList>();
	//Save all the entries to display
	TreeMap<String, ArrayList> logbookEntries = new TreeMap<String, ArrayList>() {
		public int compare(String s1, String s2) {
			int rank = getRank(s1) - getRank(s2);
			return rank;
		}
		private int getRank(String s) {
			String innerRank = s.substring(s.indexOf("-")+1, s.length());
			return Integer.parseInt(innerRank);
		}
	};
	try {
		rs = LogbookTools.getLogbookEntries(keyword_id, elab, project_id, research_group_id);
		while (rs.next()) {
			int data_keyword_id=rs.getInt("data_keyword_id");
			int log_id=rs.getInt("log_id");
			int section_id=rs.getInt("section_id");
			String dateText=rs.getString("date_entered");
			keyword_description=rs.getString("description");
			String log_text=rs.getString("log_text");
			log_text = log_text.replaceAll("''", "'");
			keyword_name=rs.getString("keyword_name");
			String keyword_display=keyword_name.replaceAll("_"," ");
			String section=rs.getString("section");
			itemCount++;
			ArrayList logbookSubsectionDetails = new ArrayList();
			ArrayList logbookDetails = new ArrayList();
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
			String sectionText = LogbookTools.getSectionText(section);
			if (keyword_name.equals("general")) {
				if (!logbookSectionOrder.containsValue("general")) {
					logbookSectionOrder.put(sectionOrder, "general");
					sectionOrder++;
				}
				logbookSections.put(keyword_name, "general");
			} 
			if (!logbookSections.containsKey(keyword_name) && !keyword_name.equals("general")) {
				if (!logbookSectionOrder.containsValue(sectionText)) {
					logbookSectionOrder.put(sectionOrder, sectionText);
					sectionOrder++;
				}
				logbookSections.put(keyword_name, sectionText);
			}
			if (!logbookSectionKeywords.containsKey(keyword_name)) {
				logbookSectionKeywords.put(String.valueOf(keyword_name), logbookSubsectionDetails);			
			}
			logbookEntries.put(String.valueOf(keyword_name)+"-"+String.valueOf(itemCount), logbookDetails);
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	request.setAttribute("messages", messages);
	request.setAttribute("yesNo", yesNo);
	request.setAttribute("linksToEach", linksToEach);
	request.setAttribute("groupName", groupName);
	request.setAttribute("keyword", keyword);
	request.setAttribute("keyword_id", keyword_id);
	request.setAttribute("keyword_name", keyword_name);
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("logbookSectionOrder", logbookSectionOrder);
	request.setAttribute("logbookSections", logbookSections);
	request.setAttribute("logbookSectionKeywords", logbookSectionKeywords);
	request.setAttribute("logbookEntries", logbookEntries);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	
	<body id="show-logbook" onload='self.focus();'>
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
												<a href="show-logbook.jsp"><font face="Comic Sans MS">
												<img src="../graphics/logbook_view.gif" border="0" " align="middle" alt=""> All Entries</font></a>
											</td>
										</tr>
										<tr>
											<td>
												<img src="../graphics/log_entry_${yesNo}.gif" border="0" align="center" alt=""><a href="show-logbook.jsp?keyword=general">
												<font face="Comic Sans MS">general</font></a>
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
										${linksToEach}
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
												<h2><font face="Comic Sans MS">Logbook Entry for Group "${groupName}"</font></h2>
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
												<font size="-2" face="Comic Sans MS">Comments: Number of teacher comments (<font color="#AA3366"> number unread </font>). 
												New comments by your teacher are marked as <img src="../graphics/new_flag.gif" border="0" align="center" alt=""></font>.
											</td>
										</tr>
									</table>
								</div>
								<table width="600" cellspacing="5">
									<c:choose>
										<c:when test="${not empty logbookSectionOrder }">
											<c:forEach items="${logbookSectionOrder }" var="logbookSectionOrder"> 
												<c:choose>
													<c:when test='${logbookSectionOrder.value == "general" }'>
														<tr align="left"><td colspan="2"><font face="Comic Sans MS" size="+2"></font></td></tr>
													</c:when>
													<c:otherwise>
														<tr align="left"><td colspan="2"><font face="Comic Sans MS" size="+2">${logbookSectionOrder.value }</font></td></tr>	
													</c:otherwise>
												</c:choose>	
												<c:forEach items="${logbookSections }" var="logbookSections">
													<c:choose>
														<c:when test="${logbookSectionOrder.value == logbookSections.value }">
															<c:forEach items="${logbookSectionKeywords }" var="logbookSectionKeywords">
																<c:choose>
																	<c:when test='${logbookSections.key == fn:substring(logbookSectionKeywords.key, 0, fn:indexOf(logbookSectionKeywords.key,  "-")) }'>
																		<tr align="left">
																			<td colspan="2">
																				<font face="Comic Sans MS" size="+1" color="#AA3366">${logbookSectionKeywords.value[1] }</font> - 
																				<font face="Comic Sans MS">${logbookSectionKeywords.value[0]}</font> 
																				<a href="log-entry.jsp?keyword=${ logbookSectionKeywords.key}"><img src="../graphics/logbook_pencil.gif" border="0" align="middle" alt=""></a>&nbsp;&nbsp;
																				<a href="show-comments-keyword.jsp?keyword=${ logbookSectionKeywords.key}"><img src="../graphics/logbook_view_comments_small.gif" border="0" align="middle" alt=""></a>
																			</td>
																		</tr>
																		<c:forEach items="${logbookEntries}" var="logbookEntries">
																			<c:choose>
																				<c:when test='${ logbookSectionKeywords.key == fn:substring(logbookEntries.key, 0, fn:indexOf(logbookEntries.key,  "-")) }' >
																					<tr>
																						<td valign="top" width="150" align="right"><font face="Comic Sans MS">${logbookEntries.value[3] }${logbookEntries.value[9]}<font></font></font></td>
																						<td width="450" valign="top"><font face="Comic Sans MS"><e:whitespaceAdjust text="${logbookEntries.value[4] }" /></font></td>
																					</tr>
																				</c:when>
																			</c:choose>
																		</c:forEach>																	
																	</c:when>
																</c:choose>
															</c:forEach>														
														</c:when>
													</c:choose>
												</c:forEach>
											</c:forEach>
										</c:when>
										<c:otherwise>
											<tr align="center">
												<td colspan="2">
													<font face="Comic Sans MS" size="+1">No entries for<br> "${keyword_name}: ${keyword_description}"</font> <a href="log-entry.jsp?keyword=${keyword}"><img src="../graphics/logbook_pencil.gif" border="0" align="middle" alt=""></a>
												</td>
											</tr>
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
