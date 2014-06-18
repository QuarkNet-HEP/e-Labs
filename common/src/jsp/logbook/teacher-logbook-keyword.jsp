<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	String role = user.getRole();
	// it will display all logs entries for one keyword for all research groups associated with the teacher logged in.
	// If the keyword is not passed, then it will default to keyword "general".
	String linksToEachGroup = "";
	Integer keyword_id = null;
	String groupName = user.getName();
	String research_group_name = groupName; 
	String keyword = request.getParameter("keyword");
	//check if we are marking entries as read
	String mark_as_read = request.getParameter("mark_as_read");
	if (mark_as_read != null && mark_as_read.equals("yes")) {
		Integer logMark = Integer.parseInt(request.getParameter("log_id"));
		try {
			LogbookTools.updateResetLogbookEntry(logMark, elab);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}

	if (keyword == null) {
		keyword = "general";
	} // default to showing entries for "general" if no keyword is passed.
	int passed_log_id = -1;
	if (request.getParameter("log_id") != null) {
		passed_log_id = Integer.parseInt(request.getParameter("log_id"));
	}
	int project_id = elab.getId();	
	
	//check if we need to add an entry
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
		  			LogbookTools.insertComment(Integer.parseInt(log_id[j]), comment_enter, elab);
	  			} catch (Exception e) {
	  				messages += e.getMessage();
	  			}
			}//end of if check
 		}//end for loop
 	}//end of submit
	
	//build links to each keyword/milestone
 	String linksToEach = "";
	try {
		linksToEach = LogbookTools.buildTeacherKeywordLinks(project_id, keyword, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
	// Always pass keyword, not id so we can pick off the description
	keyword_id = null;
	// first make sure a keyword was passed in the call
	ResultSet rs = null;
	String keyword_description = "";
	try {
		rs = LogbookTools.getKeywordDetailsByProject(project_id, keyword, elab);
		if (rs.next()) {
			keyword_id = (Integer) rs.getObject("id");
			keyword_description = rs.getString("description");
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
	int teacher_id = user.getTeacherId();

	// look for any previous log entries for this keyword and all research groups
	int itemCount = 0;
	String current_rg_name = "";
	String linkText = "";
	ArrayList groupInfo = new ArrayList();
	TreeMap<String, ArrayList> commentInfo = new TreeMap<String, ArrayList>(){
		public int compare(String s1, String s2) {
			int rank = getRank(s1) - getRank(s2);
			return rank;
		}
		private int getRank(String s) {
			String innerRank = s.substring(s.indexOf("-")+1, s.length());
			return Integer.parseInt(innerRank);
		}
	};
    String thereAreNewEntries = "";
	try {
		rs = LogbookTools.getLogbookEntriesKeyword(keyword_id, teacher_id, false, elab);
		while (rs.next()) {
			String dateText = rs.getString("date_entered");
			String log_text = rs.getString("log_text");
			int logId = rs.getInt("log_id");
			String log_text_truncated;
			log_text_truncated = log_text.replaceAll("\\<(.|\\n)*?\\>", "");
			if (log_text_truncated.length() > 50) {
				log_text_truncated = log_text_truncated.substring(0, 50);
			} else {
				log_text_truncated = log_text;
			}
			String rg_name = rs.getString("rg_name");
			String new_log = rs.getString("new");
			Long comment_count = null;
			Long comment_new = null;
			String comment_info = "";
			comment_count = (Long) LogbookTools.getCommentCount(logId, elab);
			comment_new = (Long) LogbookTools.getCommentCountNew(logId, elab);
			if (new_log != null && new_log.equals("t")) {
				thereAreNewEntries = "There are new entries";
				comment_info = comment_info
						+ "<IMG SRC=\'../graphics/new_flag.gif\' border=0 align=\'center\'> <FONT color=\"#AA3366\" size=\"-2\"><b>New log entry</b></font> <a href=\"teacher-logbook-keyword.jsp?mark_as_read=yes&log_id="+String.valueOf(logId)+"&keyword="+keyword+"\" style=\"text-decoration: none;\"><FONT size=\"-2\"><strong>Mark as Read</strong></font></a><br />";
			}
			String comment_header = "";
			if (comment_new == 0L) {
				comment_header = "<strong>comments: " + comment_count + "</strong>";
			} else {
				if (comment_count == null) {
					comment_count = 0L;
				}
				comment_header =  "<strong>comments: " + comment_count + " (<FONT color=\"#AA3366\">" + comment_new + "</FONT>) " + "</strong>";
			}

			ArrayList commentDetails = LogbookTools.buildCommentDetails(logId, comment_header, elab);			
			itemCount++;
			ArrayList details = new ArrayList();
			details.add(logId);//0
			details.add(keyword);
			details.add(dateText);
			details.add(comment_info);//3
			details.add(log_text);
			details.add(log_text_truncated);
			details.add(commentDetails);//7
			if (!groupInfo.contains(rg_name)) {
				groupInfo.add(rg_name);
			}
			commentInfo.put(rg_name+"-"+String.valueOf(itemCount), details);
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
	request.setAttribute("messages", messages);
	request.setAttribute("thereAreNewEntries", thereAreNewEntries);
	request.setAttribute("linksToEach", linksToEach);
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("keyword", keyword);
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
			function showFullComment(showDivId, fullDivId) {
				var showDiv = document.getElementById(showDivId);
				var fullDiv = document.getElementById(fullDivId);
				showDiv.innerHTML = fullDiv.innerHTML;
			}			
		</script>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="teacher-logbook-keyword">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<c:choose>
					<c:when test="${not empty messages }">
						${messages }
					</c:when>
					<c:otherwise>
						<form method="get" name="log" action="">
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
											<td><a href="teacher-logbook-group.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">By Group</a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="teacher-logbook.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">My Logbook</a></td>
										</tr>
										<tr>
											<td><a href="teacher-logbook-keyword.jsp?keyword=general">general</a></td>
										</tr>
										<tr>
											<td><b>Select a Milestone:</b></td>
										</tr>
										${linksToEach }
									</table>
									</td>
									<td align="left" width="20" valign="top"><img src="../graphics/blue_square.gif" border="0" width="2" height="475" alt=""></td>
									<td valign="top" align="center">
										<div style="border-style: dotted; border-width: 1px;">
										<table width="600">
											<tr>
												<td align="left"><font size="+1" face="Comic Sans MS">Instructions</font></td>
											</tr>						
											<tr>
												<td><font size="-1" face="Comic Sans MS">
													<ul>
														<li>Select a milestone on the left to look at logbook entries of all your groups for a particular milestone.</li>
														<li>New log entries are marked as <img src="../graphics/new_flag.gif" border="0" align="center" alt="">
															<font color="#AA3366">New log entry</font>. Number of your comments (<font color="#AA3366"> number unread by students. </font>)
												        </li>
														<li>Click <b>Mark as Read</b> once you read the new entries.</li>
														<li>Enter comments in the textbox below the student's logbook entry.</li>
													</ul>
												</font></td>
											</tr>
										</table>
										</div>
										<table>
											<tr>
												<td align="center" height="20"><FONT color="#AA3366" face="Comic Sans MS"><strong>${thereAreNewEntries }</strong></FONT></td>
											</tr>
										</table>										
										<p>
										<h2>All logbook entries for your research groups<br> for "${keyword_description }"</h2>
		
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
																				${commentInfo.value[2]}
																			</td>
																			<td width="400" valign="top">
																				<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																				<c:choose>
																					<c:when test="${commentInfo.value[4] != commentInfo.value[5]}">
																						<div id="fullLog${commentInfo.value[0]}" style="display:none;"><e:whitespaceAdjust text="${commentInfo.value[4]}"></e:whitespaceAdjust></div>
																						<div id="showLog${commentInfo.value[0]}"><e:whitespaceAdjust text="${commentInfo.value[5]}" /> . . .<a href='javascript:showFullLog("showLog${commentInfo.value[0]}","fullLog${commentInfo.value[0]}");'>Read More</a></div>
																				    </c:when>
																				    <c:otherwise>
																					    <e:whitespaceAdjust text="${commentInfo.value[4]}"></e:whitespaceAdjust>
																				    </c:otherwise>
																				</c:choose>	
																			</td>
																		</tr>
																		<tr>
																			<td width="100"> </td>
																			<td valign="top"><font face="Comic Sans MS">${commentInfo.value[3]}</font><br />
																				<font face="Comic Sans MS" size"-2">
																					<c:if test="${not empty commentInfo.value[6] }">
																						<c:forEach items="${commentInfo.value[6] }" var="comments">
																							${comments }<br />
																						</c:forEach>
																					</c:if>
																				</font>
																			</td>																				    
																	    </tr>
																		<tr>
																			<td colspan="2">																	
																				<table width="400">
																					<tr>
																						<th>Your new comment:</th>
																					</tr>
																					<tr>
																						<td><textarea name="comment_text" id="comment_text_${commentInfo.value[0]}" cols="70" rows="3"></textarea></td>
																					</tr>
																					<tr>
																						<td align="center"><input type="submit" name="submit" id="submit_${commentInfo.value[0] }" value="Submit Comment"></td>
																					</tr>
																				</table>
																				<input type="hidden" name="log_id" id="log_id_${commentInfo.value[0] }" value="${commentInfo.value[0]}">
																				<input type="hidden" name="keyword" id="keyword_${commentInfo.value[0] }" value="${keyword}">
																				
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
									</td>
								</tr>
							</table>
							</center>
						</form>
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

