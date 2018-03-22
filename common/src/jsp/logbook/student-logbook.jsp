<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.util.HTMLEscapingWriter"%>
<%@ page import="gov.fnal.elab.logbook.LogbookTools" %>
<%@ include file="../login/login-required.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>

<%
String messages = ""; //to collect exception/feedback messages
String role = user.getRole();
if (role.equals("teacher")) { 
		messages += "This page is only available to student research groups.";
}
String keyword = request.getParameter("keyword");
if (keyword == null) {
		keyword = "";
} // note - display all entries

//start building left hand side menu
String groupName = user.getName();
int projectId = elab.getId();
String yesNo = "no";
String addFlag = "";
try {
		//check whether there are entries for the general keyword
		yesNo = LogbookTools.getYesNoGeneral(user.getId(), projectId, elab);
    addFlag = LogbookTools.getNewCommentsGeneral(user.getId(), projectId, elab);
} catch (Exception e) {
		messages += e.getMessage();
}

Integer keywordId = null;
//get all keywords for this research group
HashMap keywordTracker = new HashMap();
ResultSet rs = null;
try {
		rs = LogbookTools.getKeywordTracker(user.getId(), projectId, elab);
		while (rs.next()){
				if (rs.getObject("keyword_id") != null) {
						keywordId= (Integer) rs.getObject("keyword_id");
						Object new_comments = rs.getObject("new_comments");
						//keywordTracker.put(keywordId.intValue(), true);
						keywordTracker.put(keywordId.intValue(), new_comments);
				} else { 
						keywordId = null;
				}
		}
} catch (Exception e) {
		messages += e.getMessage();
}
//provide access to all possible items to make logs on.
String linksToEach = "";
try {
		rs = LogbookTools.getLogbookKeywordItems(projectId, groupName, elab);
		//build all links
		linksToEach = LogbookTools.buildStudentKeywordLinks(rs, keywordTracker, keyword);
} catch (Exception e) {
		messages += e.getMessage();
}

// Need to check if a keyword was passed in the parameters (to display only those entries)
keywordId = null;
String keywordDescription = "";
if (!keyword.equals("")) {
		try {
				rs = LogbookTools.getKeywordDetailsByProject(projectId, keyword, elab);
				if (rs.next()) {
						keywordId = (Integer) rs.getObject("id");
						keywordDescription = rs.getString("description");
				}
		} catch (Exception e) {
				messages += e.getMessage();
		}
}	

//now check if we are saving an entry
String submit = request.getParameter("button");
String logEnter = "";
String log_text = request.getParameter("log_text");
String count_string= request.getParameter("count");
Integer count = 0;
if (count_string != null) {
	 	count = Integer.parseInt(count_string); 
}
if (submit != null) {
		if (submit.equals("Submit Entry")) {
		 		String img_src = request.getParameter("img_src");
		 		log_text = ElabUtil.stringSanitization(log_text, elab, "Logbook user: "+user.getName());
				String parsed[] = img_src.split("\\t");
				logEnter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
				+ log_text + "</div>";
				for (int i = 0; i < parsed.length; i++) {
						logEnter = logEnter.replaceAll("\\(--Image " + i
								+ "--\\)", parsed[i]);
				}
				logEnter = logEnter.replaceAll("'", "''");
				if (log_text != "") {
						try {
								int logid = LogbookTools.insertLogbookEntry(projectId, user.getId(), keywordId, logEnter, "user", elab);
						} catch (Exception e) {
								messages += e.getMessage();
						}
				}			
		}
}//end of submit

//Let's build the all the entries
int itemCount=0;
int sectionOrder=1;
int commentCnt = 0;
String keywordName = keyword;	
String keyColor = "";
String thereAreNewComments = "";
int researchGroupId = user.getId();	
//Keep the same section order as with the links on the left
TreeMap<Integer, String> logbookSectionOrder = new TreeMap<Integer, String>();
//Save the section text for each section
TreeMap<String, String> logbookSections = new TreeMap<String, String>();
//Save all keywords with comments for each section
TreeMap<String, ArrayList> logbookSectionKeywords = new TreeMap<String, ArrayList>();
//Save all the entries to display
TreeMap<Integer, ArrayList> logbookEntries = new TreeMap<Integer, ArrayList>();
//check if we are viewing only new entries
String view_only_new = request.getParameter("view_only_new");
if (view_only_new == null || view_only_new.equals("")) {
		view_only_new = "no";
}
try {
		rs = LogbookTools.getLogbookEntries(keywordId, elab, projectId, researchGroupId);
		while (rs.next()) {
				int data_keyword_id=rs.getInt("data_keyword_id");
				int log_id=rs.getInt("log_id");
				int section_id=rs.getInt("section_id");
				String dateText=rs.getString("date_entered");
				keywordDescription=rs.getString("description");
				String logText=rs.getString("log_text");
				if (logText == null) {
						logText = "";
				}			
				logText = logText.replaceAll("''", "'");
				keywordName=rs.getString("keyword_name");
				String keyword_display=keywordName.replaceAll("_"," ");
				String section=rs.getString("section");
				String log_text_truncated;
				log_text_truncated = logText.replaceAll("\\<(.|\\n)*?\\>", "");
				if (log_text_truncated.length() > 150) {
						log_text_truncated = log_text_truncated.substring(0, 138);
				} else {
						log_text_truncated = logText;
				}
				itemCount++;
				ArrayList logbookSubsectionDetails = new ArrayList();
				ArrayList logbookDetails = new ArrayList();
				logbookDetails.add(data_keyword_id); //0
				logbookDetails.add(log_id); 
				logbookDetails.add(section_id); 
				logbookDetails.add(dateText); 
				logbookDetails.add(logText); //4
				logbookDetails.add(keywordName);//5
				logbookDetails.add(section);
				logbookDetails.add(keywordDescription);
				logbookDetails.add(keyword_display); 
				logbookDetails.add(log_text_truncated); //9 
				logbookSubsectionDetails.add(keywordDescription);
				logbookSubsectionDetails.add(keyword_display);
				//get the comment counts
				Long comment_count = LogbookTools.getCommentCount(log_id, elab);
				Long comment_new = LogbookTools.getCommentCountNew(log_id, elab);
				String comment_info="";
				if (comment_new != 0L) {
						//comment_info="<IMG SRC=\'../graphics/new_flag.gif\' border=0 align=\'middle\'> <FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) " +"</font><br />";
						comment_info="<div id=\"new_"+String.valueOf(log_id)+"\"><IMG SRC=\'../graphics/new_flag.gif\' border=0 align=\'center\'> "+
						"<FONT color=\"#AA3366\" size=\"-2\"><b>comments: " + comment_count + 
						" (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) </b></font> "+
						"<a href=\"javascript:markAsRead('new_"+String.valueOf(log_id)+"', 'mark-as-read.jsp?mark_as_read=yes&log_id="+String.valueOf(log_id)+"&markWhat=comments&keyword="+keyword+"')\" style=\"text-decoration: none;\"><FONT size=\"-2\"> <strong>Mark as Read</strong></font></a><br /></div>";


				}
				logbookDetails.add(comment_info); //10
				//get the actual comments
				String comment_header = "";
				if (comment_count == null) {
						comment_count = 0L;
				}
				if (comment_new == 0L) {
						comment_header = "<strong>Comments: " + comment_count + "</strong>";
				} else {
						thereAreNewComments = "<a href=\"student-logbook.jsp?view_only_new=yes&keyword="+keyword+"\">View only entries with new comments</a>";
						comment_header =  "<strong>Comments: " + comment_count + " (<FONT color=\"#AA3366\">" + comment_new + "</FONT>) " + "</strong>";
				}
				
				ArrayList commentDetails = LogbookTools.buildCommentDetails(log_id, comment_header, commentCnt, elab);
				commentCnt = commentCnt + Integer.parseInt(String.valueOf(comment_count)) + 1;
				logbookDetails.add(commentDetails); //11
				
				String sectionText = LogbookTools.getSectionText(section);
				if (keywordName.equals("general")) {
						if (!logbookSectionOrder.containsValue("general")) {
								if (view_only_new.equals("yes")) {
										if (comment_new > 0L) {
												logbookSectionOrder.put(sectionOrder, "general");
												sectionOrder++;
												logbookSections.put(keywordName, "general");
										}
								} else {
										logbookSectionOrder.put(sectionOrder, "general");
										sectionOrder++;
										logbookSections.put(keywordName, "general");
								}
						}
				} 
				if (!logbookSections.containsKey(keywordName) && !keywordName.equals("general")) {
						if (!logbookSectionOrder.containsValue(sectionText)) {
								if (view_only_new.equals("yes")) {
										if (comment_new > 0L) {
												logbookSectionOrder.put(sectionOrder, sectionText);
												sectionOrder++;							
										}
								} else {
										logbookSectionOrder.put(sectionOrder, sectionText);
										sectionOrder++;
								}
						}
						if (view_only_new.equals("yes")) {
								if (comment_new > 0L) {
										logbookSections.put(keywordName, sectionText);						
								}
						} else {
								logbookSections.put(keywordName, sectionText);					
						}
				}
				if (!logbookSectionKeywords.containsKey(keywordName)) {
						if (view_only_new.equals("yes")) {
								if (comment_new > 0L) {
										logbookSectionKeywords.put(String.valueOf(keywordName), logbookSubsectionDetails);			
								}
						} else {
								logbookSectionKeywords.put(String.valueOf(keywordName), logbookSubsectionDetails);								
						}
				}
				if (view_only_new.equals("yes")) {
						if (comment_new > 0L) {
								logbookEntries.put(itemCount, logbookDetails);				
						}
				} else {
						logbookEntries.put(itemCount, logbookDetails);
				}
		}
} catch (Exception e) {
		messages += e.getMessage();
}//end of building all entries

String keyword_display=keywordName.replaceAll("_"," ");	
request.setAttribute("messages", messages);
if (view_only_new.equals("yes")) {
		thereAreNewComments = "<a href=\"student-logbook.jsp?view_only_new=no&keyword="+keyword+"\">View all entries</a>";
}
request.setAttribute("thereAreNewComments", thereAreNewComments);
request.setAttribute("yesNo", yesNo);
request.setAttribute("addFlag", addFlag);
request.setAttribute("count", count);
request.setAttribute("linksToEach", linksToEach);
request.setAttribute("groupName", groupName);
request.setAttribute("keyword", keyword);
request.setAttribute("keywordName", keyword_display);
request.setAttribute("keywordDescription", keywordDescription);
request.setAttribute("logbookSectionOrder", logbookSectionOrder);
request.setAttribute("logbookSections", logbookSections);
request.setAttribute("logbookSectionKeywords", logbookSectionKeywords);
request.setAttribute("logbookEntries", logbookEntries);
String references = "../references/Reference_"+keyword+".html";
if (keyword.equals("")) {
		references = "../references/Reference_all_entries.html";
} else if (keyword.equals("general")) {
		references = "../references/Reference_general.html";
} 
request.setAttribute("references", references);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
				<title>Enter Logbook</title>
				<link rel="stylesheet" href="styletut.css" type="text/css">
				<script type="text/javascript" src="logbook.js"></script>
  			<script type="text/javascript" src="../include/elab.js"></script>	
		</head>
		
		<body id="student-logbook" onload='self.focus();'>
				<!-- entire page container -->
				<div id="container">	
						<div id="content">
								<c:choose>
										<c:when test="${not empty messages }">
												${messages }
										</c:when>
										<c:otherwise>
												<form method="post" name="log" action="">
														<table class="outerTable">
																<tr>
																		<td valign="top" width="150" nowrap>
																				<div class="leftMenu">
																						<table width="145">
																								<tr>
																										<td valign="center" align="left">
																												<a href="student-logbook.jsp"><font face="Comic Sans MS">
																														<img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="" height="20" width="20"> All Entries</font></a>
																										</td>
																								</tr>
																								<tr>
																										<td style="padding-left: 10px;">
																												<img src="../graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font>
																										</td>
																								</tr>										
																								<tr>
																										<td style="padding-left: 10px;">
																												<img src="../graphics/new_flag.gif" border="0" alt=""><font face="Comic Sans MS"> if new comment exists</font>
																										</td>
																								</tr>
																								<tr>
																										<td>
																												<img src="../graphics/log_entry_${yesNo}.gif" border="0" align="center" alt=""><a href="student-logbook.jsp?keyword=general">
																														<font face="Comic Sans MS">general</font></a> ${addFlag }
																										</td>
																								</tr>
																								<tr>
																										<td>
																												<b><br><font face="Comic Sans MS">Milestones from<br>Research Basics<br>and Study Guide</font></b>
																										</td>
																								</tr>

																								${fn:escapeXml(linksToEach)}
																						</table>
																				</div>
																		</td>
																		<td align="left" width="5" valign="top" nowrap>
																				<div style="width:5px; position: fixed;">
																						<img src="../graphics/blue_square.gif" border="0" width="2" height="600" alt="">
																				</div>
																		</td>
																		<td valign="top" width="300">
																				<div class="references">									
																						<c:catch var="e">
																								<c:import url="${fn:escapeXml(references)}" />
																						</c:catch>
																						<c:if test="${!empty e}">
																								Error: ${e.message}
																						</c:if>
																				</div>
																		</td>
																		<td align="right" width="5" valign="top" nowrap>
																				<div style="width:5px; position: fixed;">								
																						<img src="../graphics/blue_square.gif" border="0" width="2" height="600" alt="">
																				</div>
																		</td>
																		<td valign="top" align="center">	
																				<div style="width: 480px;">	
																						<table width="480">
																								<tr>
																										<td align="right">
																												<img src="../graphics/logbook_large.gif" align="middle" border="0" alt="">
																										</td>
																										<td>
																												<h2><font face="Comic Sans MS">Logbook Entry for Group "${groupName}"</font></h2>
																										</td>
																								</tr>
																						</table>
																						<div class="instructions" id="instructions-v" style="visibility:visible; display">
																								<a href="#" onclick="HideShow('instructions-v');HideShow('instructions-h');return false;"><img src="../graphics/Tright.gif" alt=" " border="0" /><font size="+1" face="Comic Sans MS"> View Instructions</font></a>						
																						</div>
																						<div class="instructions" id="instructions-h" style="visibility:hidden; display: none">
																								<table width="480">
																										<tr>
																												<td align="left">
																														<a href="#" onclick="HideShow('instructions-v');HideShow('instructions-h');return false;"><img src="../graphics/Tdown.gif" alt=" " border="0" /><font size="+1" face="Comic Sans MS"> Hide Instructions</font></a>
																												</td>
																										</tr>
																										<tr>
																												<td><font size="-1" face="Comic Sans MS">
																														<ul>
																																<li>Select a milestone on the left to make a logbook entry associated with it.</li>
																																<li>Use the text box for your new entry.</li>
																																<li>Look for flags <img src="../graphics/new_flag.gif" alt=""></img>indicating new comments by your teacher.</li>
																																<li>Click <strong>Mark as Read</strong> once you read the new comments.</li>		
																																<br />
																																<c:if test="${not empty thereAreNewComments }">
																																		<li><i>Toggle between <strong>'View only entries with new comments'/'View all entries'</strong> to filter the results.</i></li>
																																</c:if>
																														</ul>
																												</font>							
																												</td>
																										</tr>												
																								</table>
																						</div>
																						
																						<table>
																								<tr>
																										<td align="center" height="20"><FONT color="#AA3366" face="Comic Sans MS"><strong>${thereAreNewComments }</strong></FONT></td>
																								</tr>
																						</table>
																						<table width="480">
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
																																												</td>
																																										</tr>
																																										<c:if test='${keyword != ""}'>
																																												<tr>
																																														<th colspan="2"><font face="Comic Sans MS">Your New Log Book Entry</font></th>
																																												</tr>
																																												<tr>
																																														<td colspan="2">
																																																<textarea name="log_text" cols="62" rows="5"></textarea>
																																																<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
																																																<input type="hidden" name="img_src" value='${img_src}'> 
																																																<input type="hidden" name="count" value="${count }">
																																														</td>
																																												</tr>									
																																												<tr>
																																														<td align='left'>
																																																<input type='button' name="plot" onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true'); if(childWindow.opener==null) childWindow.opener=self;" value="Insert a plot"></td>
																																																<td align='right'>
																																																		<input type="submit" name="button" id="button_submit" value="Submit Entry">																				
																																																</td>
																																												</tr>																		
																																										</c:if>
																																										<c:forEach items="${logbookEntries}" var="logbookEntries">
																																												<c:choose>
																																														<c:when test='${ logbookSectionKeywords.key == logbookEntries.value[5]}' >
																																																<tr>
																																																		<td valign="top" width="150" align="right"><font face="Comic Sans MS">${logbookEntries.value[3] }</font></td>
																																																		<td width="300" valign="top" align="left" ><font face="Comic Sans MS" >

																																																				<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																																																				<c:choose>
																																																						<c:when test="${logbookEntries.value[4] != logbookEntries.value[9]}">
																																																								<div id="fullLog${logbookEntries.value[1]}" style="display:none; width: 300px; height: 100%; text-align: left;"><e:whitespaceAdjust text="${logbookEntries.value[4]}"></e:whitespaceAdjust></div>
																																																								<div id="showLog${logbookEntries.value[1]}" style="width: 300px; height: 100%; text-align: left;"><e:whitespaceAdjust text="${logbookEntries.value[9]}" /> . . .<a href='javascript:showFullLog("showLog${logbookEntries.value[1]}","fullLog${logbookEntries.value[1]}");'>Read More</a></div>
																																																						</c:when>
																																																						<c:otherwise>
																																																								<div style="width: 300px; height: 100%; text-align: left;"><e:whitespaceAdjust text="${logbookEntries.value[4]}"></e:whitespaceAdjust></div>
																																																						</c:otherwise>
																																																				</c:choose>																								
																																																		</font></td>
																																																</tr>
																																																<tr>
																																																		<td width="150"> </td>
																																																		<td width="300" align="left" style="background-color: #f2f2f2;">
																																																				<font face="Comic Sans MS">${logbookEntries.value[10]}</font>
																																																				<font face="Comic Sans MS" size=-2 >
																																																						<c:if test="${not empty logbookEntries.value[11] }">
																																																								<c:forEach items="${logbookEntries.value[11] }" var="comments">
																																																										${comments }<br />
																																																								</c:forEach>
																																																						</c:if>
																																																				</font>
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
																																				</c:forEach>														
																																		</c:when>
																																</c:choose>
																														</c:forEach>
																												</c:forEach>
																										</c:when>
																										<c:otherwise>
																												<tr>
																														<th><font face="Comic Sans MS">Your New Log Book Entry</font></th>
																														<th></th>
																												</tr>
																												<tr align="center">
																														<td colspan="2">
																																<font face="Comic Sans MS" size="+1">No entries for<br> "${keywordName}: ${keywordDescription}"</font> 
																														</td>
																												</tr>
																												<tr>
																														<td colspan="2">
																																<textarea name="log_text" cols="62" rows="5"></textarea>
																																<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
																																<input type="hidden" name="img_src" value='${img_src}'> 
																																<input type="hidden" name="count" value="${count }">
																														</td>
																												</tr>									
																												<tr>
																														<td align='left'>
																																<input type='button' name="plot" onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;" value="Insert a plot"></td>
																																<td align='right'><input type="submit" name="button" id="button_${logbookSections.key}" value="Submit Entry"></td>
																												</tr>																		
																												
																										</c:otherwise>
																								</c:choose>
																						</table>
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
