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
	String keyword_description = "";
	String keyword_text = "";
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
	Collection<String> groups = user.getGroupNames();
	Iterator it = groups.iterator();
	while(it.hasNext()) {
		String rg_name = it.next().toString();
		ElabGroup eg = user.getGroup(rg_name);
		if (eg.getRole().equals("user") || eg.getRole().equals("upload")) {
			//EPeronja: only display active research groups
			if (eg.getActive()) {
				linksToEachGroup = linksToEachGroup
						+ "<tr><td><A HREF='show-logbook-group-teacher.jsp?research_group_name="
						+ rg_name + "'>" + rg_name + "</A></td></tr>";
			}
		}		
	}
	String yesNo = "No";
	
	int sectionOrder=1;
	//Keep the same section order as with the links on the left
	TreeMap<Integer, String> logbookSectionOrder = new TreeMap<Integer, String>();
	//Save the section text for each section
	TreeMap<String, String> logbookSections = new TreeMap<String, String>();
	//Save all keywords with comments for each section
	TreeMap<String, ArrayList> logbookSectionKeywords = new TreeMap<String, ArrayList>();
	//Save all the entries to display
	TreeMap<String, ArrayList> logbookEntries = new TreeMap<String, ArrayList>(){
		public int compare(String s1, String s2) {
			int rank = getRank(s1) - getRank(s2);
			return rank;
		}
		private int getRank(String s) {
			String innerRank = s.substring(s.indexOf("-")+1, s.length());
			return Integer.parseInt(innerRank);
		}
	};
		
	Integer keyword_id = null;	
	String linksToEach = "";
	//build all links
	if (!(research_group_name == null)) {
		yesNo = LogbookTools.getYesNoGeneral(research_group_name, project_id, elab);
		HashMap keywordTracker = new HashMap();
		ResultSet rs = null;
		rs = LogbookTools.getKeywordTracker(research_group_name, project_id, elab);
		while (rs.next()){
			if (rs.getObject("keyword_id") != null) {
				keyword_id= (Integer) rs.getObject("keyword_id");
				keywordTracker.put(keyword_id.intValue(), true);
			} else { 
				keyword_id = null;
			}
		}
		//provide access to all possible items to make logs on.
		try {
			rs = LogbookTools.getLogbookKeywordItems(project_id, typeConstraint, elab);
		} catch (Exception e) {
			messages += e.getMessage();
		}
		
		try {
			linksToEach = LogbookTools.buildGroupLinksToKeywords(rs, keywordTracker, keyword, research_group_name);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}

	int research_group_id = -1;
	String display = "";

	if (!(research_group_name == null)) {
		ElabGroup eg = user.getGroup(research_group_name);
		if (eg != null) {
			research_group_id = eg.getId();
		}
		keyword_id = null;
		if (!keyword.equals("")) {
			ResultSet rs = LogbookTools.getKeywordDetailsByProject(project_id, keyword, elab);
			if (rs.next()) {
				keyword_id = (Integer) rs.getObject("id");
				keyword_description = rs.getString("description");
			}
		}

		if (keyword_id == null) {
		    display = "<h2>All logbook entries for group "+research_group_name+"</h2>";
		} 
		else {
			display = "<h2>Logbook entry for group "+research_group_name+"</h2>";
		}
		ResultSet innerRs = null;
		int itemCount = 0;
		boolean showFullLog = false;
		String elipsis = "";
		String linkText = "";
		Integer current_keyword_id = null;
		String sectionText = "";
		current_section = "";
		ResultSet rs = LogbookTools.getLogbookEntries(keyword_id, elab, project_id, research_group_id);

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
			ArrayList logbookDetails = new ArrayList();
			logbookDetails.add(log_id);
			logbookDetails.add(keyword_name);
			logbookDetails.add(dateText);
			logbookDetails.add(comment_info);
			logbookDetails.add(log_text);
			logbookDetails.add(log_text_truncated);
			logbookDetails.add(elipsis);
			logbookSubsectionDetails.add(keyword_description);
			logbookSubsectionDetails.add(keyword_display);

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
	}
		
	request.setAttribute("messages", messages);
	request.setAttribute("display", display);
	request.setAttribute("yesNo", yesNo);
	request.setAttribute("keyword_id", keyword_id);
	request.setAttribute("keyword_name", keyword_name);
	request.setAttribute("keyword_display", keyword_name.replaceAll("_", " "));
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("logbookSectionOrder", logbookSectionOrder);
	request.setAttribute("logbookSections", logbookSections);
	request.setAttribute("logbookSectionKeywords", logbookSectionKeywords);
	request.setAttribute("logbookEntries", logbookEntries);
	request.setAttribute("research_group_name", research_group_name);
	request.setAttribute("linksToEachGroup", linksToEachGroup);
	request.setAttribute("linksToEach", linksToEach);
	
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
	<body id="show-logbook-group-teacher">
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
											<td valign="center" align="left"><a href="show-logbook-keyword-teacher.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">By Milestone</a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="show-logbook-teacher.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">My Logbook</a></td>
										</tr>
										<tr>
											<td><b>Select a Research Group</b></td>
										</tr>${linksToEachGroup }
										<c:if test="${not empty research_group_name }">
											<tr>
												<td><br>
												<b>Entries for ${research_group_name }</b></td>
											</tr>
	
											<tr>
												<td valign="center" align="left"><a href="show-logbook-group-teacher.jsp?research_group_name=${research_group_name }"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="">All Entries</a></td>
											</tr>
											<tr>
												<td align="center"><img src="../graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font></td>
											</tr>
											<tr>
												<td><img src="../graphics/log_entry_${yesNo}.gif" border="0" align="center" alt=""><a href="show-logbook-group-teacher.jsp?research_group_name=${research_group_name }&amp;keyword=general">general</a></td>
											</tr>
											<tr>
												<td><br>
												<b>Select a Milestone:</b></td>
											</tr>
											${linksToEach}
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
																	<c:choose>
																	<c:when test="${not empty logbookSections }">
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
																								</td>
																							</tr>
																							<c:choose>			
																								<c:when test="${not empty logbookEntries }">			
																									<c:forEach items="${logbookEntries}" var="logbookEntries">
																										<c:choose>
																											<c:when test='${ logbookSectionKeywords.key == fn:substring(logbookEntries.key, 0, fn:indexOf(logbookEntries.key,  "-")) }' >
																												<tr>
																														<td valign="top" width="175" align="right">
																															<a href="log-comment.jsp?log_id=${logbookEntries.value[0]}&amp;keyword=${logbookEntries.value[1]}&amp;research_group_name=<%=research_group_name%>&amp;path=RG"><img src="../graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>${logbookEntries.value[2]}${logbookEntries.value[3] }
																														</td>
																														<td width="400" valign="top">
																															<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																															<div id="fullLog${logbookEntries.value[0]}" style="display:none;"><e:whitespaceAdjust text="${logbookEntries.value[4]}"></e:whitespaceAdjust></div>
																															<div id="showLog${logbookEntries.value[0]}"><e:whitespaceAdjust text="${logbookEntries.value[5]}" />${logbookEntries.value[6]}<a href='javascript:showFullLog("showLog${logbookEntries.value[0]}","fullLog${logbookEntries.value[0]}");'>Read More</a></div>
																														</td>
													
																													</tr>
								
																											</c:when>
																										</c:choose>
																									</c:forEach>
																								</c:when>
																							</c:choose>	
																						</c:when>
																					</c:choose>
																				</c:forEach>
																			</c:when>
																		</c:choose>
																	</c:forEach>
																	</c:when>																	
																	</c:choose>
																</c:forEach>
															</c:when>
															<c:otherwise>
															<tr align="center">
																<td colspan="2">
																<c:choose>
																	<c:when test="${not empty keyword_name }">
																		<font face="Comic Sans MS" size="+1">No entries for<br> "${keyword_display}: ${keyword_description}"</font></a>
																	</c:when>
																	<c:otherwise>
																		<font face="Comic Sans MS" size="+1">No entries.</font></a>													
																	</c:otherwise>
																	</c:choose>
																</td>
															</tr>																		
															</c:otherwise>
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
