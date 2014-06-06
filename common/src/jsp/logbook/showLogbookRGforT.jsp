<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../include/elab.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	// invoked with optional research_group_name and keyword
	// if no research_group_name is passed, 
	String role = user.getRole();
	// it will display all or one keyword for a particular research group.
	// If the research_group_name is not passed, then it will show a list of research groups that teacher has for this e-Lab and return.
	// Each of these will link to this page with research_group_name passed without a keyword.
	String queryItems = "";
	String querySort = "";
	String queryWhere = "";
	String keyword_description = "";
	String keyword_text = "";
	String linksToEach = "";
	String linksToEachGroup = "";
	String keyword_loop = "";
	String research_group_name = request.getParameter("research_group_name");
	String keyword = request.getParameter("keyword");

	String current_section = "";
	String keyColor = "";
	String typeConstraint = "AND keyword.type IN ('SW','S') ";
	
	if (!(research_group_name == null)) {
		if (research_group_name.startsWith("pd_")
				|| research_group_name.startsWith("PD_")) {
			typeConstraint = "AND keyword.type IN ('SW','W') ";
		}
	}
	if (keyword == null) {
		keyword = "";
	} // note - display all entries
	String keyword_name = keyword;
	
	int passed_log_id = -1;	 	
	if (request.getParameter("log_id") != null) {
		passed_log_id = Integer.parseInt(request.getParameter("log_id"));
	}
	
	int project_id = elab.getId();
	String groupName = user.getName();
	Collection<String> groups = user.getGroupNames();
	Iterator it = groups.iterator();
	while(it.hasNext()) {
		String rg_name = it.next().toString();
		ElabGroup eg = user.getGroup(rg_name);
		if (eg.getRole().equals("user") || eg.getRole().equals("upload")) {
			linksToEachGroup = linksToEachGroup
					+ "<tr><td><A HREF='showLogbookRGforT.jsp?research_group_name="
					+ rg_name + "'>" + rg_name + "</A></td></tr>";
		}		
	}
	String yesNo = "No";
	TreeMap<Integer, String> leftLinks = new TreeMap<Integer, String>();
	TreeMap<Integer, String> leftSublinks = new TreeMap<Integer, String>();
	TreeMap<String, String> logbookSections = new TreeMap<String, String>();
	TreeMap<String, ArrayList> logbookSubsections = new TreeMap<String, ArrayList>();
	Integer keyword_id = null;	

	if (!(research_group_name == null)) {
		yesNo = LogbookTools.getYesNo(research_group_name, project_id, elab);
		HashMap keywordTracker = new HashMap();
		ResultSet rs = null;
		try {
			rs = LogbookTools.getKeywordTracker(research_group_name, project_id, elab);
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
	

		Integer keyword_count = 0;
		while (rs1.next()) {
			keyword_id = (Integer) rs1.getObject("id");
			keyword_loop = rs1.getString("keyword");
			keyword_text = keyword_loop.replaceAll("_", " ");
			keyword_description = rs1.getString("description");
			String this_section = (String) (rs1.getString("section"));
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
					outer_this_section = section_text;
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
	
				// More work to do if we haven't seen this one yet.
				if (keywordTracker.containsKey(keyword_id)) {
					yesNo = "yes";
				}
	
				keyColor = "";
				if (keyword.equals(keyword_loop)) {
					keyColor = "color=\"#AA3366\"";
				}
				linksToEach = linksToEach
						+ "<tr><td><img src=\"../graphics/log_entry_"
						+ yesNo
						+ ".gif\" border=0 align=center><A HREF='showLogbookRGforT.jsp?research_group_name="
						+ research_group_name + "&keyword="
						+ keyword_loop + "'><FONT  " + keyColor + ">"
						+ keyword_text + "</font></A></td></tr>";
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
	}//end if research group is not null
	
	int research_group_id = -1;
	String display = "";
	ArrayList groupInfo = new ArrayList();
	TreeMap<String, ArrayList> commentInfo = new TreeMap<String, ArrayList>();

	if (!(research_group_name == null)) {
		ElabGroup eg = user.getGroup(research_group_name);
		if (eg != null) {
			research_group_id = eg.getId();
		}
		keyword_id = null;
		if (!keyword.equals("")) {
			ResultSet rs = LogbookTools.getEntriesByKeyword(project_id, keyword, elab);
			if (rs.next()) {
				keyword_id = (Integer) rs.getObject("id");
				keyword_description = rs.getString("description");
			}
		}
		querySort =  "ORDER BY keyword.section, keyword.section_id, log.id DESC;";
		queryItems = "SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text, keyword.description AS description, keyword.id AS data_keyword_id, keyword.keyword AS keyword_name, keyword.section AS section, keyword.section_id AS section_id, log.new_log AS new FROM log, keyword ";

		if (keyword_id == null) {
		    display = "<h2>All logbook entries for group "+research_group_name+"</h2>";
			queryWhere = "WHERE log.project_id = ? AND keyword.project_id IN (0, ?) AND log.keyword_id = keyword.id AND research_group_id = ? AND role = 'user' ";
			keyword_description = "";
			keyword_id = -1;
		} 
		else {
			display = "<h2>Logbook entry for group "+research_group_name+"</h2>";
			queryWhere = "WHERE log.project_id = ? AND keyword.project_id IN (0, ?) AND log.keyword_id = keyword.id AND research_group_id = ? AND role = 'user' AND keyword_id = ?";
		}
		ResultSet innerRs = null;
		int itemCount = 0;
		boolean showFullLog = false;
		String elipsis = "";
		String linkText = "";
		Integer current_keyword_id = null;
		String sectionText = "";
		current_section = "";
		ResultSet rs = LogbookTools.getLogbookDetails(queryWhere, elab, project_id, research_group_id, keyword_id);

		while (rs.next()) {
			Integer data_keyword_id = (Integer) rs.getObject("data_keyword_id");
			String dateText = rs.getString("date_entered");
			keyword_description = rs.getString("description");
			String log_text = rs.getString("log_text");
			log_text = log_text.replaceAll("''", "'");
			Integer log_id = (Integer) rs.getObject("log_id");
			Boolean new_log = (Boolean) rs.getObject("new");
			showFullLog = false;
			if (log_id.equals(passed_log_id)) {
				showFullLog = true;
				elipsis = "";
				linkText = "";
			} else {
				elipsis = " . . .";
			}
			String log_text_truncated;

			if (showFullLog)
				log_text_truncated = log_text;
			else
				log_text_truncated = log_text.replaceAll(
						"\\<(.|\\n)*?\\>", "");
			int maxChars = log_text_truncated.length();
			if (maxChars > 50 && !showFullLog) {
				maxChars = 50;
			}
			log_text_truncated = log_text_truncated.substring(0,
					maxChars);
			keyword_name = rs.getString("keyword_name");
			String keyword_display = keyword_name.replaceAll("_", " ");
			String section = rs.getString("section");
			Integer section_id = (Integer) rs.getObject("section_id");
			Long comment_count = null;
			Long comment_new = null;
			String comment_info = "";
			comment_count = (Long) LogbookTools.getCommentCount(log_id, elab);
			comment_new = (Long) LogbookTools.getCommentCountNew(log_id, elab);

			if (new_log != null && new_log == true && !showFullLog) {
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
							+ comment_count
							+ " (<FONT color=\"#AA3366\">"
							+ comment_new + "</FONT>)" + " </font>";
				}
				// out.write("New comments="+comment_new);
			}
			itemCount++;
			ArrayList logbookSubsectionDetails = new ArrayList();
			ArrayList details = new ArrayList();
			details.add(log_id);
			details.add(keyword);
			details.add(dateText);
			details.add(comment_info);
			details.add(log_text);
			details.add(log_text_truncated);
			details.add(elipsis);
			logbookSubsectionDetails.add(keyword_description);
			logbookSubsectionDetails.add(keyword_display);

			if (!groupInfo.contains(research_group_name)) {
				groupInfo.add(research_group_name);
			}
			commentInfo.put(keyword_name+"-"+String.valueOf(itemCount), details);
			
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

		}
	}
		
	request.setAttribute("messages", messages);
	request.setAttribute("display", display);
	request.setAttribute("yesNo", yesNo);
	request.setAttribute("keyword_id", keyword_id);
	request.setAttribute("keyword_name", keyword_name);
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("leftLinks", leftLinks);
	request.setAttribute("leftSublinks", leftSublinks);
	request.setAttribute("logbookSections", logbookSections);
	request.setAttribute("logbookSubsections", logbookSubsections);
	request.setAttribute("research_group_name", research_group_name);
	request.setAttribute("groupInfo", groupInfo);
	request.setAttribute("commentInfo", commentInfo);	
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>For Teachers: Show Logbooks of Student Research Group</title>
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
	<body id="showlogbookRGforT">
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
											<td valign="center" align="left"><a href="showLogbookKWforT.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">By Milestone</a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="showLogbookT.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">My Logbook</a></td>
										</tr>
										<tr>
											<td><b>Select a Research Group</b></td>
										</tr><%=linksToEachGroup%>
										<c:if test="${not empty research_group_name }">
											<tr>
												<td><br>
												<b>Entries for "<%=research_group_name%>"</b></td>
											</tr>
	
											<tr>
												<td valign="center" align="left"><a href="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="">All Entries</a></td>
											</tr>
											<tr>
												<td align="center"><img src="../graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font></td>
											</tr>
											<tr>
												<td><img src="../graphics/log_entry_<%=yesNo%>.gif" border="0" align="center" alt=""><a href="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>&amp;keyword=general">general</a></td>
											</tr>
											<tr>
												<td><br>
												<b>Select a Milestone:</b></td>
											</tr>
											<%=linksToEach%>
										</c:if>
									</table>
								</td>
								<td align="left" width="20" valign="top"><img src="../graphics/blue_square.gif" border="0" width="2" height="650" alt=""></td>
								<td valign="top" align="center">
									<div style="border-style: dotted; border-width: 1px;">
										<table width="600">
											<tr>
												<td align="left" colspan="4"><font size="+1"
													face="Comic Sans MS">Instructions</font></td>
											</tr>
											<tr>
												<td align="right">&nbsp;</td>
												<td align="left">Click <b>Read more</b> to read full log entry and reset "new log" status.</td>
											</tr>
											<tr>
												<td align="right"><img src="../graphics/logbook_pencil.gif" align="middle" border="0" alt=""></td>
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
										<c:choose>
											<c:when test="${not empty display }">
												${display }
								<table>		
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
																						<td colspan="2"><font size="+1" color="#AA3366">${logbookSubsections.value[0]}</font>	- ${logbookSubsections.value[1]}<font></font></td>
																					</tr>
												<c:choose>
													<c:when test="${not empty commentInfo }">
														<c:forEach items="${commentInfo }" var="commentInfo">
															<c:if test='${logbookSubsections.key == fn:substring(commentInfo.key, 0, fn:indexOf(commentInfo.key,  "-"))}'>														
																<tr>
																	<td valign="top" width="175" align="right">
																		<a href="logCommentEntry.jsp?log_id=${commentInfo.value[0]}&amp;keyword=${commentInfo.value[1]}&amp;research_group_name=${groupInfo}&amp;path=RG"><img src="../graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>${commentInfo.value[2]}${commentInfo.value[3] }
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
											</c:when>
										</c:choose>
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
