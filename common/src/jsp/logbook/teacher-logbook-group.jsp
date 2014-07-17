<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = ""; //to collect exception/feedback messages
	// invoked with optional research_group_name and keyword
	// if no research_group_name is passed, 
	String role = user.getRole();
	// it will display all or one keyword for a particular research group.
	// If the research_group_name is not passed, then it will show a list of research groups that teacher has for this e-Lab and return.
	// Each of these will link to this page with research_group_name passed without a keyword.
	String keyword_description = "";
	String keyword_text = "";
	String keyword_loop = "";
	String research_group_name = request.getParameter("research_group_name");
	String research_group_id_text = request.getParameter("research_group_id");
	int research_group_id = -1;
	if (research_group_name != null) {
		research_group_id = Integer.parseInt(research_group_id_text);
	}
	String keyword = request.getParameter("keyword");
	String current_section = "";
	String keyColor = "";

	if (keyword == null) {
		keyword =  "";
	} // note - display all entries
	String keyword_name = keyword;
	
	int passed_log_id = -1;	 	
	if (request.getParameter("log_id") != null) {
		passed_log_id = Integer.parseInt(request.getParameter("log_id"));
	}
	
	int project_id = elab.getId();
	String linksToEachGroup = LogbookTools.buildGroupLinks(user, "teacher-logbook-group.jsp");

	//check if we are entering new comments
	String submit = request.getParameter("submit");
	String[] log_id = request.getParameterValues("log_id");
	String[] comment_text = request.getParameterValues("comment_text");
 	if (submit != null && comment_text != null) {
 		//loop through all the comments
 		for (int j=0; j < comment_text.length; j++) {
			if (!comment_text[j].equals("")) {
	 			// need to update or insert an entry yet
		  		String comment_enter = comment_text[j].replaceAll("'", "''");
		  		comment_enter = ElabUtil.stringSanitization(comment_enter, elab, "Logbook user: "+user.getName());
	  			//we have to insert a new row into table
	  			try {
		  			int comment_id = LogbookTools.insertComment(Integer.parseInt(log_id[j]), comment_enter, elab);
	  			} catch (Exception e) {
	  				messages += e.getMessage();
	  			}
			}//end of if check
 		}//end for loop
 	}//end of submit

	Integer keyword_id = null;	
	String linksToEach = "";
	//build all links
	String yesNo = "No";
	String addFlag = "";
	if (!(research_group_name == null)) {
		yesNo = LogbookTools.getYesNoGeneral(research_group_id, project_id, elab);
		addFlag = LogbookTools.getNewLogEntriesGeneral(research_group_id, project_id, elab);
		HashMap keywordTracker = new HashMap();
		ResultSet rs = null;
		rs = LogbookTools.getKeywordTracker(research_group_id, project_id, elab);
		while (rs.next()){
			if (rs.getObject("keyword_id") != null) {
				keyword_id= (Integer) rs.getObject("keyword_id");
				Object new_log_entries = rs.getObject("new_log_entries");
				//keywordTracker.put(keyword_id.intValue(), true);
				keywordTracker.put(keyword_id.intValue(), new_log_entries);

			} else { 
				keyword_id = null;
			}
		}
		//provide access to all possible items to make logs on.
		try {
			rs = LogbookTools.getLogbookKeywordItems(project_id, research_group_name, elab);
		} catch (Exception e) {
			messages += e.getMessage();
		}
		
		try {
			linksToEach = LogbookTools.buildGroupLinksToKeywords(rs, keywordTracker, keyword, research_group_name, research_group_id);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}

    //build logbook entries and comments
	int sectionOrder=1;
    String thereAreNewEntries = "";
	//Keep the same section order as with the links on the left
	TreeMap<Integer, String> logbookSectionOrder = new TreeMap<Integer, String>();
	//Save the section text for each section
	TreeMap<String, String> logbookSections = new TreeMap<String, String>();
	//Save all keywords with comments for each section
	TreeMap<String, ArrayList> logbookSectionKeywords = new TreeMap<String, ArrayList>();
	//Save all the entries to display
	TreeMap<Integer, ArrayList> logbookEntries = new TreeMap<Integer, ArrayList>();

	String subtitle = "";
	//check if we are viewing only new entries
	String view_only_new = request.getParameter("view_only_new");
	if (view_only_new == null || view_only_new.equals("")) {
		view_only_new = "no";
	}
	if (!(research_group_name == null)) {
		try {
			keyword_id = null;
			if (!keyword.equals("")) {
				ResultSet rs = LogbookTools.getKeywordDetailsByProject(project_id, keyword, elab);
				if (rs.next()) {
					keyword_id = (Integer) rs.getObject("id");
					keyword_description = rs.getString("description");
				}
			}
	
			if (keyword_id == null) {
			    subtitle = "<h2>All logbook entries for group "+research_group_name+"</h2>";
			} 
			else {
				subtitle = "<h2>Logbook entry for group "+research_group_name+"</h2>";
			}
			ResultSet innerRs = null;
			int itemCount = 0;
			int commentCnt = 0;
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
				if (log_text == null) {
					log_text = "";
				}
				log_text = log_text.replaceAll("''", "'");
				Integer logid = (Integer) rs.getObject("log_id");
				Boolean new_log = (Boolean) rs.getObject("new");
				String log_text_truncated;
				log_text_truncated = log_text.replaceAll(
							"\\<(.|\\n)*?\\>", "");
				if (log_text_truncated.length() > 150) {
					log_text_truncated = log_text_truncated.substring(0, 138);
				} else {
					log_text_truncated = log_text;
				}
				keyword_name = rs.getString("keyword_name");
				String keyword_display = keyword_name.replaceAll("_", " ");
				String section = rs.getString("section");
				Integer section_id = (Integer) rs.getObject("section_id");
				Long comment_count = null;
				Long comment_new = null;
				String comment_info = "";
				comment_count = (Long) LogbookTools.getCommentCount(logid, elab);
				comment_new = (Long) LogbookTools.getCommentCountNew(logid, elab);
	
				if (new_log != null && new_log == true) {
					thereAreNewEntries = "<a href=\"teacher-logbook-group.jsp?view_only_new=yes&keyword="+keyword+"&research_group_name="+
										 research_group_name+"&research_group_id="+research_group_id+"\">View only new entries</a>";
					comment_info = "<div id=\"new_"+String.valueOf(logid)+"\"><IMG SRC=\'../graphics/new_flag.gif\' border=0 align=\'center\'> <FONT color=\"#AA3366\" size=\"-2\"><b>New log entry</b></font>"+
								   "<a href=\"javascript:markAsRead('new_"+String.valueOf(logid)+"', 'mark-as-read.jsp?mark_as_read=yes&log_id="+String.valueOf(logid)+"&markWhat=logentry&research_group_name="+research_group_name+"')\" style=\"text-decoration: none;\"><FONT size=\"-2\"> <strong>Mark as Read</strong></font></a><br /></div>";
				}
				String comment_header = "";
				if (comment_new == 0L) {
					comment_header = "<strong>Comments: " + comment_count + "</strong>";
				} else {
					if (comment_count == null) {
						comment_count = 0L;
					}
					comment_header =  "<strong>Comments: " + comment_count + " (<FONT color=\"#AA3366\">" + comment_new + "</FONT>) " + "</strong>";
				}
	
				ArrayList commentDetails = LogbookTools.buildCommentDetails(logid, comment_header, commentCnt, elab);	
				commentCnt = commentCnt + Integer.parseInt(String.valueOf(comment_count)) + 1;

				itemCount++;
				ArrayList logbookSubsectionDetails = new ArrayList();
				ArrayList logbookDetails = new ArrayList();
				logbookDetails.add(logid); //0
				logbookDetails.add(keyword_name);
				logbookDetails.add(dateText);
				logbookDetails.add(comment_info);//3
				logbookDetails.add(log_text);
				logbookDetails.add(log_text_truncated);
				logbookDetails.add(commentDetails); //6
				logbookSubsectionDetails.add(keyword_description);
				logbookSubsectionDetails.add(keyword_display);
				sectionText = LogbookTools.getSectionText(section);
				if (keyword_name.equals("general")) {
					if (!logbookSectionOrder.containsValue("general")) {
						if (view_only_new.equals("yes")) {
							if (new_log != null && new_log) {
								logbookSectionOrder.put(sectionOrder, "general");
								sectionOrder++;
								logbookSections.put(keyword_name, "general");
							}
						} else {
							logbookSectionOrder.put(sectionOrder, "general");
							sectionOrder++;
							logbookSections.put(keyword_name, "general");
						}
					}
				} 
				if (!logbookSections.containsKey(keyword_name) && !keyword_name.equals("general")) {
					if (!logbookSectionOrder.containsValue(sectionText)) {
						if (view_only_new.equals("yes")) {
							if (new_log != null && new_log) {
								logbookSectionOrder.put(sectionOrder, sectionText);
								sectionOrder++;
							}
						} else {
							logbookSectionOrder.put(sectionOrder, sectionText);
							sectionOrder++;
						}
					}
					if (view_only_new.equals("yes")) {
						if (new_log != null && new_log) {
							logbookSections.put(keyword_name, sectionText);
						}
					} else {
						logbookSections.put(keyword_name, sectionText);
					}

				}
				if (!logbookSectionKeywords.containsKey(keyword_name)) {
					if (view_only_new.equals("yes")) {
						if (new_log != null && new_log) {
							logbookSectionKeywords.put(String.valueOf(keyword_name), logbookSubsectionDetails);			
						}
					} else {
						logbookSectionKeywords.put(String.valueOf(keyword_name), logbookSubsectionDetails);								
					}
				}
				if (view_only_new.equals("yes")) {
					if (new_log != null && new_log) {
						logbookEntries.put(itemCount, logbookDetails);
					}
				} else {
					logbookEntries.put(itemCount, logbookDetails);				
				}
			}
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}
		
	request.setAttribute("messages", messages);
	if (view_only_new.equals("yes")) {
		thereAreNewEntries = "<a href=\"teacher-logbook-group.jsp?view_only_new=no&keyword="+keyword+"&research_group_name="+
				 research_group_name+"&research_group_id="+research_group_id+"\">View all entries</a>";
	}
	request.setAttribute("thereAreNewEntries", thereAreNewEntries);
	request.setAttribute("subtitle", subtitle);
	request.setAttribute("yesNo", yesNo);
	request.setAttribute("addFlag", addFlag);
	request.setAttribute("keyword", keyword);
	request.setAttribute("keyword_id", keyword_id);
	request.setAttribute("keyword_name", keyword_name);
	request.setAttribute("keyword_display", keyword_name.replaceAll("_", " "));
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("logbookSectionOrder", logbookSectionOrder);
	request.setAttribute("logbookSections", logbookSections);
	request.setAttribute("logbookSectionKeywords", logbookSectionKeywords);
	request.setAttribute("logbookEntries", logbookEntries);
	request.setAttribute("research_group_name", research_group_name);
	request.setAttribute("research_group_id", research_group_id);
	request.setAttribute("linksToEachGroup", linksToEachGroup);
	request.setAttribute("linksToEach", linksToEach);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>For Teachers: Show Logbooks of Student Research Group</title>
        <script type="text/javascript" src="logbook.js"></script>
        <script type="text/javascript" src="../include/elab.js"></script>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="teacher-logbook-group">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<c:choose>
					<c:when test="${not empty messages }">
						${messages }
					</c:when>
					<c:otherwise>
						<form method="get" name="log" action="">

						<table style="width: 800px; padding: 0; border: 0; text-align: left;">
							<tr>
								<td valign="top" width="150" nowrap>
									<div class="leftMenu">
									<table width="145">
										<tr>
											<td valign="center" align="left"><a href="teacher-logbook-keyword.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="" width="20" height="20">By Milestone</a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="teacher-logbook.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="" width="20" height="20">My Logbook</a></td>
										</tr>
										<c:choose>
											<c:when test='${research_group_name != null }'>	
												<tr>
													<td valign="center" align="left"><a	href="../logbook/teacher-logbook-group.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="" width="20" height="20"><font color="#1A8BC8">By Group</font></a></td>
												</tr>
												<tr>
													<td><br>
													<b>Entries for ${research_group_name }</b>
													<input type="hidden" name="research_group_name" value="${research_group_name }"></input>										
													<input type="hidden" name="research_group_id" value="${research_group_id }"></input>										
													</td>
												</tr>
		
												<tr>
													<td valign="center" align="left"><a href="teacher-logbook-group.jsp?research_group_name=${research_group_name }&research_group_id=${research_group_id}"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="" width="20" height="20">All Entries</a></td>
												</tr>
												<tr>
													<td align="center"><img src="../graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font></td>
												</tr>
												<tr>
													<td><img src="../graphics/log_entry_${yesNo}.gif" border="0" align="center" alt=""><a href="teacher-logbook-group.jsp?research_group_name=${research_group_name }&amp;keyword=general&research_group_id=${research_group_id}">general</a>${addFlag }</td>
												</tr>											
												<tr>
													<td><br>
													<b>Select a Milestone:</b></td>
												</tr>
												${linksToEach}
											</c:when>
											<c:otherwise>																															
												<tr>
													<td><b>Select a <br />Research Group</b></td>
												</tr>${linksToEachGroup }
											</c:otherwise>
										</c:choose>
									</table>
									</div>
								</td>
								<td align="left" width="20" valign="top">
									<div style="overflow:auto; width:20px; position: fixed;">
										<img src="../graphics/blue_square.gif" border="0" width="2" height="600" alt="">
									</div>
								</td>
								<td valign="top" align="left">
										<div style="width: 650px; height: 100px;">
											<div style="width: 150px; float:left;"><img src="../graphics/logbook_view_large.gif" align="middle" border="0" alt=""></img></div>
										 	<div style="width: 500px; float:right;"><font size="+2">Teachers: View and Comment on Logbooks of Student Research Groups</font></div>
										</div> 	

										<div class="instructions" id="instructions-v" style="visibility:visible; display">
											<a href="#" onclick="HideShow('instructions-v');HideShow('instructions-h');return false;"><img src="../graphics/Tright.gif" alt=" " border="0" /><font size="+1"> View Instructions</font></a>						
										</div>
										<div class="instructions" id="instructions-h" style="visibility:hidden; display: none">
										<table width="550">
											<tr>
												<td align="left">
													<a href="#" onclick="HideShow('instructions-v');HideShow('instructions-h');return false;"><img src="../graphics/Tdown.gif" alt=" " border="0" /><font size="+1"> Hide Instructions</font></a>
												</td>
											</tr>						
											<tr>
												<td><font size="-1">
													<ul>
														<li>Select a group on the left to display the logbook entries.</li>
														<li>New log entries are marked as <img src="../graphics/new_flag.gif" border="0" align="center" alt="">
															<font color="#AA3366">New log entry</font>. 
															Number of your comments (<font color="#AA3366"> number unread by students. </font>)
														</li>
														<li>Click <b>Mark as Read</b> once you read the new entries.</li>
														<li>Click on a milestone to limit your view to entries for that milestone.</li>
														<li>Enter comments in the textbox below the student's logbook entry.</li>
														<li>Click <strong>Submit All</strong> to save your comments.</li>
														<br />
														<c:if test="${not empty thereAreNewEntries }">
															<li><i>Toggle between <strong>'View only new entries'/'View all entries'</strong> to filter the results.</i></li>
														</c:if>
													</ul>
												</font></td>
											</tr>
										</table>
										</div>
										<table width="600">
											<tr>
												<td align="center" height="20"><FONT color="#AA3366"><strong>${thereAreNewEntries }</strong></FONT></td>
											</tr>
										</table>										
										<c:choose>
											<c:when test="${not empty subtitle }">
												<center>${subtitle }<br /></center>
												<table width="630" >		
													<c:choose>
														<c:when test="${not empty logbookSectionOrder }">
															<tr><td colspan="2">
																<table width="630">
																	<tr>
																		<td width="630" align="right">
											 								<div style="position: fixed; width: 600px;">
																				<input type="submit" name="submit" id="submitButton" value="Submit All">
																			</div>													
																		</td>
																	</tr>
																</table>
															</td></tr>
															<c:forEach items="${logbookSectionOrder }" var="logbookSectionOrder"> 
																	<c:choose>
																		<c:when test='${logbookSectionOrder.value == "general" }'>
																			<tr align="left">
																				<td colspan="2"><font size="+2"></font></td>
																			</tr>
																		</c:when>
																		<c:otherwise>
																			<tr align="left">
																				<td colspan="2"><font size="+2">${logbookSectionOrder.value }</font></td>
																			</tr>
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
																											<font size="+1" color="#AA3366">${logbookSectionKeywords.value[1] }</font> - 
																											<font size="+1">${logbookSectionKeywords.value[0]}</font> 
																										</td>
																									</tr>
																									<c:choose>			
																										<c:when test="${not empty logbookEntries }">			
																											<c:forEach items="${logbookEntries}" var="logbookEntries">
																												<c:choose>
																													<c:when test='${ logbookSectionKeywords.key == logbookEntries.value[1] }' >
																														<tr>
																																<td valign="top" width="100" align="right">
																																	${logbookEntries.value[2]}
																																</td>
																																<td width="400" valign="top" align="left">
																																	<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																																	<c:choose>
																																		<c:when test="${logbookEntries.value[4] != logbookEntries.value[5]}">
																																			<div id="fullLog${logbookEntries.value[0]}" style="display:none; width: 350px; height: 100%; text-align:left;"><e:whitespaceAdjust text="${logbookEntries.value[4]}"></e:whitespaceAdjust></div>
																																			<div id="showLog${logbookEntries.value[0]}" style="width: 350px; height: 100%; text-align:left;"><e:whitespaceAdjust text="${logbookEntries.value[5]}" /> . . .<a href='javascript:showFullLog("showLog${logbookEntries.value[0]}","fullLog${logbookEntries.value[0]}");'>Read More</a></div>
																																	    </c:when>
																																	    <c:otherwise>
																																		    <div style="width: 350px; height: 100%; text-align:left;"><e:whitespaceAdjust text="${logbookEntries.value[4]}"></e:whitespaceAdjust></div>
																																	    </c:otherwise>
																																	 </c:choose>	
																																</td>
																															</tr>
																															<tr>
																																<td width="100"> </td>
																																<td width="400" valign="middle"  align="left">
																														           <font>${logbookEntries.value[3]}</font>
																																	<font size=-2>
																																		<c:if test="${not empty logbookEntries.value[6] }">
																																			<c:forEach items="${logbookEntries.value[6] }" var="comments">
																																				<div style="width: 350px; height: 100%; background-color: #f2f2f2;"><e:whitespaceAdjust text="${comments }"></e:whitespaceAdjust><br /></div>
																																			</c:forEach>
																																		</c:if>
																																	</font>
																																</td>																										    
																														    </tr>																													
																															<tr>
																																<td colspan="2">
																																	<table width="550" >
																																		<tr>
																																			<th>Your new comment:</th>
																																		</tr>
																																		<tr>
																																			<td><textarea name="comment_text" id="comment_text_${logbookEntries.value[0]}" cols="65" rows="5"></textarea></td>
																																		</tr>
																																	</table>
																																	<input type="hidden" name="log_id" id="log_id_${logbookEntries.value[0] }" value="${logbookEntries.value[0]}">
																																	<input type="hidden" name="keyword" id="keyword_${logbookEntries.value[0] }" value="${keyword}">
																																</td>																												
																															</tr>
																														    <tr>
																														    	<td colspan="2" class="entrySeparator"> </td>
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
																	<font size="+1">No entries for<br> "${keyword_display}: ${keyword_description}"</font></a>
																</c:when>
																<c:otherwise>
																	<font size="+1">No entries.</font></a>													
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
						</form>
					</c:otherwise>
				</c:choose>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->		
	</body>
</html>
