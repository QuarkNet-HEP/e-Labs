<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../include/elab.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	String role = user.getRole();
	// it will display all logs entries for one keyword for all research groups associated with the teacher logged in.

	// Sample query - select research_group.name,to_char(log.date_entered,'MM/DD/YYY HH12:MI'), log.log_text
	//                from log,research_group where log.keyword_id=17 and research_group.id=log.research_group_id 
	//                where research_group.id in ( select id from research_group where teacher_id=2 and (role='user' or role='upload')   ) order by research_group_id,log.id;
	// If the keyword is not passed, then it will default to keyword "general".
	String keyword_description = "";
	String keyword_text = "";
	String linksToEach = "";
	String linksToEachGroup = "";
	String keyword_loop = "";
	Integer keyword_id = null;
	String groupName = user.getName();
	String research_group_name = groupName; 
	String keyColor = "";
	String keyword = request.getParameter("keyword");
	if (keyword == null) {
		keyword = "general";
	} // default to showing entries for "general" if no keyword is passed.
	int passed_log_id = -1;
	if (request.getParameter("log_id") != null) {
		passed_log_id = Integer.parseInt(request.getParameter("log_id"));
	}
	int project_id = elab.getId();	

	ResultSet rs = LogbookTools.getLogbookItems(project_id, "", elab);
	String current_section = "";
	while (rs.next()) {
		keyword_id = (Integer) rs.getObject("id");
		keyword_loop = rs.getString("keyword");
		keyword_text = keyword_loop.replaceAll("_", " ");
		keyword_description = rs.getString("description");
		String this_section = (String) (rs.getString("section"));
		if (!keyword_loop.equals("general")) {
			if (!this_section.equals(current_section)) {
				String section_text = "";
				char this_section_char = this_section.charAt(0);
				switch (this_section_char) {
				case 'A':
					section_text = "Research Basics";
					break;
				case 'B':
					section_text = "A: Get Started";
					break;
				case 'C':
					section_text = "B: Figure it Out";
					break;
				case 'D':
					section_text = "C: Tell Others";
					break;
				}
				linksToEach = linksToEach
						+ "<tr><td>&nbsp;</td></tr><tr><td>"
						+ section_text + "</td></tr>";
				current_section = this_section;
			}

			keyColor = "";
			if (keyword.equals(keyword_loop)) {
				keyColor = "color=\"#AA3366\"";
			}
			linksToEach = linksToEach
					+ "<tr><td><A HREF='showLogbookKWforT.jsp?keyword="
					+ keyword_loop + "'>"
					+ keyword_text + "</font></A></td></tr>";
		}
	}
	// Always pass keyword, not id so we can pick off the description
	//   String keyword_description="";
	keyword_id = null;
	// first make sure a keyword was passed in the call
	try {
		rs = LogbookTools.getEntriesByKeyword(project_id, keyword, elab);
		if (rs.next()) {
			keyword_id = (Integer) rs.getObject("id");
			keyword_description = rs.getString("description");
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
	int teacher_id = user.getTeacherId();
	// look for any previous log entries for this keyword and all research groups
	PreparedStatement sInner = null;
	ResultSet innerRs = null;
	int itemCount = 0;
	boolean showFullLog = false;
	String current_rg_name = "";
	String elipsis = "";
	String linkText = "";
	rs = LogbookTools.getLogbookEntriesByGroup(keyword_id, teacher_id, elab);
	ArrayList groupInfo = new ArrayList();
	TreeMap<String, ArrayList> commentInfo = new TreeMap<String, ArrayList>();
	
	while (rs.next()) {
		String dateText = rs.getString("date_entered");
		String log_text = rs.getString("log_text");
		int log_id = rs.getInt("log_id");
		showFullLog = false;
		if (log_id == passed_log_id) {
			showFullLog = true;
			elipsis = "";
			linkText = "";
		} else {
			elipsis = " . . .";
		}

		String log_text_truncated;
		//if (showFullLog)
		//	log_text_truncated = log_text;
		//else
			log_text_truncated = log_text.replaceAll("\\<(.|\\n)*?\\>","");
		int maxChars = log_text_truncated.length();
		if (maxChars > 50 && !showFullLog) {
			maxChars = 50;
		}
		log_text_truncated = log_text_truncated.substring(0, maxChars);
		String rg_name = rs.getString("rg_name");
		String new_log = rs.getString("new");
		Long comment_count = null;
		Long comment_new = null;
		String comment_info = "";
		//sInner = conn.prepareStatement("SELECT COUNT(id) AS comment_count FROM comment WHERE log_id = ?;");
		//sInner.setInt(1, log_id);
		//  Do a query for this log entry to see if there are any unread comments on it and if it has comments on it.
		//innerRs = sInner.executeQuery();
		//if (innerRs.next()) {
			comment_count = (Long) LogbookTools.getCommentCount(log_id, elab);
		//}
		//sInner = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new FROM comment WHERE comment.new_comment = 't' AND log_id = ?;");
		//sInner.setInt(1, log_id);
		//  out.write(innerQuery);
		//innerRs = sInner.executeQuery();
		
		//if (innerRs.next()) {
			comment_new = (Long) LogbookTools.getCommentCountNew(log_id, elab);
		//}
		if (new_log != null && new_log.equals("t") && !showFullLog) {
			comment_info = comment_info
					+ "<BR><IMG SRC=\'../graphics/new_flag.gif\' border=0 align=\'center\'> <FONT color=\"#AA3366\" size=\"-2\"><b>New log entry</b></font>";
		}
		if (comment_count == null || comment_count == 0L) {
			if (comment_new == 0L) {
				comment_info = comment_info
						+ "<BR><FONT size=-2>comments: "
						+ comment_count + "</font>";
			} else {
				if (comment_count == null) {
					comment_count = 0L;
				}
				comment_info = comment_info
						+ "<BR><FONT size=-2 >comments: "
						+ comment_count + " (<FONT color=\"#AA3366\">"
						+ comment_new + "</FONT>) " + "</font>";
			}
			// out.write("New comments="+comment_new);
		}
	 	//EPeronja-04/12/2013: this code is not used anymore
	 	// 					   replaced this functionality with Javascript
		//if (!showFullLog) {
		//	linkText = "<A HREF=\"showLogbookKWforT.jsp?research_group_name="
		//			+ rg_name
		//			+ "&keyword="
		//			+ keyword
		//			+ "&log_id="
		//			+ log_id + "\">Read more</A>";
		//}

		itemCount++;
		ArrayList details = new ArrayList();
		details.add(log_id);
		details.add(keyword);
		details.add(dateText);
		details.add(comment_info);
		details.add(log_text);
		details.add(log_text_truncated);
		details.add(elipsis);
		if (!groupInfo.contains(rg_name)) {
			groupInfo.add(rg_name);
		}
		commentInfo.put(rg_name+"-"+String.valueOf(itemCount), details);
	}
	request.setAttribute("messages", messages);
	request.setAttribute("groupInfo", groupInfo);
	request.setAttribute("commentInfo", commentInfo);	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>For Teachers: All Logbook entries for one milestone.</title>
		<!-- //EPeronja-04/12/2013: replace truncated text by long text for the log
									jsp used to be resubmitted for this!
		 -->
		<script>
			function showFullLog(showDivId, fullDivId) {
				var showDiv = document.getElementById(showDivId);
				var fullDiv = document.getElementById(fullDivId);
				showDiv.innerHTML = fullDiv.innerHTML;
			}
		</script>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="showlogbookKWforT">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<c:choose>
					<c:when test="${not empty messages }">
						${messages }
					</c:when>
					<c:otherwise>
					<table width="800">
						<tr>
							<td width="150">&nbsp;</td>
							<td align="right" width="100"><img src="../graphics/logbook_view_large.gif" align="middle" border="0" alt=""></td>
							<td width="550"><font size="+2">Teachers: View and Comment on<br>Logbooks of Student Research Groups</font></td>
						</tr>
					</table>
					<center>
					<table width="800" cellpadding="0" border="0" align="left">
						<tr>
							<td valign="top" align="150">
							<table width="140">
								<tr>
									<td><a href="showLogbookRGforT.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">By Group</a></td>
								</tr>
								<tr>
									<td valign="center" align="left"><a href="showLogbookT.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">My Logbook</a></td>
								</tr>
								<tr>
									<td><a href="showLogbookKWforT.jsp?keyword=general">general</a></td>
								</tr>
								<tr>
									<td><b>Select a Milestone:</b></td>
								</tr>
								<%=linksToEach%>

							</table>
							</td>
							<td align="left" width="20" valign="top"><img src="../graphics/blue_square.gif" border="0" width="2" height="475" alt=""></td>
							<td valign="top" align="center">
								<div style="border-style: dotted; border-width: 1px;">
								<table width="600">
									<tr>
										<td align="left" colspan="4"><font size="+1" face="Comic Sans MS">Instructions</font></td>
									</tr>				
									<tr>
										<td align="right">&nbsp;</td>
										<td align="left">Click <b>Read more</b> to read full log entry and reset "new log" status.</td>
									</tr>
									<tr>
										<td align="right"><img src="../graphics/logbook_pencil.gif" align="center" border="0" alt=""></td>
										<td align="left">Button to add and view comments on a logbook entry.</td>
									</tr>
									<tr>
										<td colspan="2">&nbsp;</td>
									</tr>
									<tr>
										<td align="right" colspan="2"><font size="-2">Log Status: New log entries are marked as <img
											src="../graphics/new_flag.gif" border="0" align="center" alt="">
										<font color="#AA3366">New log entry</font>. Number of your comments
										(<font color="#AA3366"> number unread by students. </font>)</font><font></font>
										</td>
									</tr>
								</table>
								<p>
								<h2>All logbook entries for your research groups<br> for "<%=keyword_description%>"</h2>

								<table cellpadding="5">
									<c:choose>
										<c:when test="${not empty groupInfo }">
											<c:forEach items="${groupInfo }" var="groupInfo">
												<tr align="center">
													<td colspan="2"><font size="+1">Group: ${groupInfo }</font></td>
												</tr>
												<c:choose>
													<c:when test="${not empty commentInfo }">
														<c:forEach items="${commentInfo }" var="commentInfo">
															<c:if test='${groupInfo == fn:substring(commentInfo.key, 0, fn:indexOf(commentInfo.key,  "-"))}'>														
																<tr>
																	<td valign="top" width="175" align="right">
																		<a href="logCommentEntry.jsp?log_id=${commentInfo.value[0]}&amp;keyword=${commentInfo.value[1]}&amp;research_group_name=${groupInfo}&amp;path=KW"><img src="../graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>${commentInfo.value[2]}${commentInfo.value[3] }
																	</td>
																	<td width="400" valign="top">
																		<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																		<div id="fullLog${commentInfo.value[0]}" style="display:none;"><e:whitespaceAdjust text="${commentInfo.value[4]}"></e:whitespaceAdjust></div>
																		<div id="showLog${commentInfo.value[0]}"><e:whitespaceAdjust text="${commentInfo.value[5]}" />${commentInfo.value[6]}<a href='javascript:showFullLog("showLog${commentInfo.value[0]}","fullLog${commentInfo.value[0]}");'>Read More</a></div>
																	</td>

																</tr>
															</c:if>
														</c:forEach>
													</c:when>
												</c:choose>
												
											</c:forEach>
										</c:when>
										<c:otherwise>
											<tr align="center">
												<td colspan="2"><font size="+1">No entries for this milestone.</font></td>
											</tr>
										</c:otherwise>
									</c:choose>	
								</table>
								</p>					
								</div>
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

