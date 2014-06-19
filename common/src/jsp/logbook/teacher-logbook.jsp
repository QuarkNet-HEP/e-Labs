<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = ""; //to collect exception/feedback messages
	String ref_rg_name = request.getParameter("ref_rg_name"); // this is the name we are referring to in the logbook
	Integer project_id = elab.getId();
	Integer research_group_id = user.getGroup().getId();
    String teacher_name = user.getTeacher();
	String role = user.getRole();
	//get research group links for the left hand side menu
	String linksToEachGroup = "";
	try {
		linksToEachGroup = LogbookTools.buildGroupLinks(user,"teacher-logbook.jsp?ref_rg_name=");		
	} catch (Exception e) {
		messages += e.getMessage();
	}

	//check whether to display all entries
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

	//check if we are saving an entry
	String submit = request.getParameter("button");
	int itemCount = 0;
	ResultSet rs = null;
	String log_text = request.getParameter("log_text");
	String img_src = request.getParameter("img_src");
	String count_string= request.getParameter("count");
	Integer count = 0;
	if (count_string != null) {
 	  count = Integer.parseInt(count_string); 
	}
	if (log_text == null) {
		log_text = "";
	}
	String log_enter;
	if (submit != null && !log_text.equals("")) {
  		log_text = ElabUtil.stringSanitization(log_text, elab, "Logbook user: "+user.getName());
		log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
				+ log_text + "</div>";
		String parsed[] = img_src.split("\\t");
		for (int i = 0; i < parsed.length; i++) {
			log_enter = log_enter.replaceAll("\\(--Image " + i
					+ "--\\)", parsed[i]);
		}
		log_enter = log_enter.replaceAll("'", "''");
		try {
			LogbookTools.insertLogbookEntryTeacher(project_id, research_group_id, ref_rg_id, log_enter, role, elab);
		} catch (Exception e) {
			messages += e.getMessage();
		}
	}//end of submit
	
	String subtitle = "";
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
			String logText = rs.getString("log_text");
			if (logText == null) {
				logText = "";
			}
			String log_id = rs.getString("log_id");
			ref_rg_id = rs.getInt("ref_rg_id");
			itemCount++;
			String log_text_truncated;
			log_text_truncated = logText.replaceAll(
						"\\<(.|\\n)*?\\>", "");
			if (log_text_truncated.length() > 40) {
				log_text_truncated = log_text_truncated.substring(0, 25);
			} else {
				log_text_truncated = logText;
			}
			logbookDetails.add(dateText); //0
			logbookDetails.add(logText);
			logbookDetails.add(log_id);
			logbookDetails.add(log_text_truncated); //3
			logbookResults.put(String.valueOf(ref_rg_id)+"-"+String.valueOf(itemCount), logbookDetails);
			String gn = LogbookTools.getGroupNameFromId(ref_rg_id, elab);
			ArrayList userDetails = new ArrayList();
			userDetails.add(gn);
			userDetails.add(String.valueOf(research_group_id));
			userDetails.add(String.valueOf(ref_rg_id)); //5
			ids.put(String.valueOf(ref_rg_id), userDetails);			
		}//end looping through resultset
	}//end of checking rs for null
	
	request.setAttribute("messages", messages);
	request.setAttribute("linksToEachGroup", linksToEachGroup);
	request.setAttribute("subtitle", subtitle);
    request.setAttribute("ref_rg_name", ref_rg_name);
    request.setAttribute("research_group_id", research_group_id);
    request.setAttribute("ref_rg_id", ref_rg_id);    
	request.setAttribute("ids", ids);
	request.setAttribute("logbookResults", logbookResults);
	request.setAttribute("count", count);
	request.setAttribute("img_src", img_src);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Show Research Group Logbook for Teacher</title>
		<link rel="stylesheet" href="styletut-teacher.css" type="text/css">
		<script language='javascript' type="text/javascript">
			function insertImgSrc() {
			    var raw = document.log.img_src.value;
			    var parsed = raw.split(",");
			    for (var i = 0; i < parsed.length; i++)
			    {
			        var txt = document.log.log_text.value;
			        txt = txt.replace("(--Image "+i+"--)", parsed[i]);
			        document.log.log_text.value = txt;
			    }
			};
		</script>
		<script>
			function showFullLog(showDivId, fullDivId) {
				var showDiv = document.getElementById(showDivId);
				var fullDiv = document.getElementById(fullDivId);
				showDiv.innerHTML = fullDiv.innerHTML;
			}
		</script>
	</head>
	<body id="teacher-logbook">
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
						<form method="get" name="log" action="">
						<table width="800" cellpadding="0" border="0" align="left">
							<tr>
								<td valign="top" width="150" nowrap>
									<div style="height:700px; width:150px; position: fixed; overflow:auto;">
									<table width="145">
										<tr>
											<td valign="center" align="left"><b>Student Logbooks</b></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a href="../logbook/teacher-logbook-keyword.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt=""><font color="#1A8BC8">By Milestone</font></a></td>
										</tr>
										<tr>
											<td valign="center" align="left"><a	href="../logbook/teacher-logbook-group.jsp"><img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt=""><font color="#1A8BC8">By Group</font></a></td>
										</tr>
										<tr>
											<td><b>Your Logbook:<br />
												<a href="teacher-logbook.jsp?ref_rg_name=general">general</a><br /><br />Select a Research Group</b></td>
										</tr>
										${linksToEachGroup}
										<tr>
											<td valign="center" align="left"><a href="teacher-logbook.jsp">All Groups</a></td>
										</tr>
									</table>
									</div>
								</td>
								<td align="left" width="20" valign="top">
									<div style="overflow:auto; width:20px; position: fixed;">
										<img src="../graphics/red_square.gif" border="0" width="2" height="650" alt="">
									</div>
								</td>								
								<td valign="top" align="center">
									<div style="border-style: dotted; border-width: 1px; width: 550px"">
										<table width="550">
											<tr>
												<td align="left" colspan="4">
													<font size="+1" face="Comic Sans MS">Instructions</font>
												</td>
											<tr>
												<td><font size="-1" face="Comic Sans MS">
													<ul>
														<li>Select a group on the left to make an entry in your private logbook.</li>
														<li>Click "By Milestone" to see all logbook entries of your groups for a particular milestone.</li>
														<li>Click "By Group" to see the logbook entries of an individual group.</li>
													</ul>
												</font></td>
											</tr>												

											</tr>
										</table>
									</div>
									<h2>${subtitle }</h2>
									<table>
										<c:choose>
											<c:when test="${not empty ids }">
												<c:forEach items="${ids }" var="ids">
													<tr align="center">
														<td colspan="2"><font size="+1">${ids.value[0] }</font>
														</td>
													</tr>
													<tr align="center">
														<td colspan="2">
														<c:if test="${not empty ref_rg_name }">
																<table width="400">
																	<tr>
																		<th colspan="2"><font face="arial MS">Your New Log Book Entry</font></th>
																	</tr>
																	<tr>
																		<td colspan="2"><textarea name="log_text" cols="70" rows="5"></textarea></td>
																	</tr>
																	<tr>
																		<td align='left'>
																			<input type='button' name="plot" onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;" value="Insert a plot"></td>
																		<td align="right"><input type="submit" name="button" value="Submit Entry"></td>
																	</tr>
																</table>
																<input type="hidden" name="ref_rg_name" value="${ref_rg_name }"> 
																<input type="hidden" name="research_group_id" value="${research_group_id }"> 
																<input type="hidden" name="ref_rg_id" value="${ids.value[5] }"> 
																<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
																<input type="hidden" name="img_src" value='${img_src }'> 
																<input type="hidden" name="count" value="${count }">
														</c:if>														
														</td>
													</tr>
													<c:choose>
														<c:when test="${not empty logbookResults }">
															<c:forEach items="${logbookResults }" var="logbookResults">
																<c:if test='${ids.key == fn:substring(logbookResults.key, 0, fn:indexOf(logbookResults.key,  "-"))}'>
																	<tr>
																		<td valign="top" width="175" align="right">${logbookResults.value[0] }</td>
																		<td width="400" valign="top">
																			
																						<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
																						<c:choose>
																							<c:when test="${logbookResults.value[1] != logbookResults.value[3]}">
																								<div id="fullLog${logbookResults.value[2]}" style="display:none;"><e:whitespaceAdjust text="${logbookResults.value[1]}"></e:whitespaceAdjust></div>
																								<div id="showLog${logbookResults.value[2]}"><e:whitespaceAdjust text="${logbookResults.value[3]}" /> . . .<a href='javascript:showFullLog("showLog${logbookResults.value[2]}","fullLog${logbookResults.value[2]}");'>Read More</a></div>
																						    </c:when>
																						    <c:otherwise>
																							    <e:whitespaceAdjust text="${logbookResults.value[1]}"></e:whitespaceAdjust>
																						    </c:otherwise>
																						 </c:choose>	
																			
																			</td> 
																	</tr>
																</c:if>		
															</c:forEach>
														</c:when>
													</c:choose>
												</c:forEach>
											</c:when>
											<c:otherwise>
												<tr><td colspan="2"><font size="+1">No entries.</font>
														<table width="400">
															<tr>
																<th colspan="2"><font face="arial MS">Your New Log Book Entry</font></th>
															</tr>
															<tr>
																<td colspan="2"><textarea name="log_text" cols="70" rows="5"></textarea></td>
															</tr>
															<tr>
																<td align='left'>
																	<input type='button' name="plot" onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;" value="Insert a plot"></td>
																<td align="right"><input type="submit" name="button" value="Submit Entry"></td>
															</tr>
														</table>
														<input type="hidden" name="ref_rg_name" value="${ref_rg_name }"> 
														<input type="hidden" name="research_group_id" value="${research_group_id }"> 
														<input type="hidden" name="ref_rg_id" value="${ids.value[5] }"> 
														<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
														<input type="hidden" name="img_src" value='${img_src }'> 
														<input type="hidden" name="count" value="${count }">
												</td></tr>
											</c:otherwise>										
										</c:choose>
									</table>
								</td>
							</tr>
						</table>
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
