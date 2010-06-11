<%@ page import="java.util.*"%>
<%@ include file="common.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<link rel="stylesheet" href="include/styletut.css" type="text/css">
<html>
<head>
<title>For Teachers: Show Logbooks of Student Research Group</title>
</head>
<body>

<table width="800">
	<tr>
		<td width="150">&nbsp;</td>
		<td align="right" width="100"><img
			src="graphics/logbook_view_large.gif" align="middle" border="0"
			alt=""></td>
		<td width="550"><font size="+2">Teachers: View and Comment
		on<br>
		Logbooks of Student Research Groups</font></td>
	</tr>
</table>
<center><!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb_ps.jsp"%> <%
 	// invoked with optional research_group_name and keyword
 	// if no research_group_name is passed, 
 	String role = (String) session.getAttribute("role");
 	if (!role.equals("teacher")) {
 		out.write("This page is only available to teachers");
 		return;
 	}
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
 	
 	Integer keyword_id, passed_log_id, project_id = null; 
 	
 	if (!(research_group_name == null)) {
 		if (research_group_name.startsWith("pd_")
 				|| research_group_name.startsWith("PD_")) {
 			typeConstraint = "AND keyword.type IN ('SW','W') ";
 		}
 	}
 	if (keyword == null) {
 		keyword = "";
 	} // note - display all entries
 	 	
 	try { 
 		passed_log_id = Integer.valueOf(request.getParameter("log_id"));
 	}
 	catch (NumberFormatException nfe) {
 		passed_log_id = null; 
 	}
 	
 	// get project ID
 	//eLab defined in common.jsp
 	s = conn.prepareStatement("SELECT id FROM project WHERE name = ?;");
 	s.setString(1, eLab);
 	rs = s.executeQuery();
 	if (rs.next()) {
 		project_id = (Integer) rs.getObject("id");
 	}
 	if (project_id == null) {
 		%> Problem with id for project <%=eLab%><br><%
		return;
	}
	
	s = conn.prepareStatement(
			"SELECT id, name FROM research_group, research_group_project " + 
			"WHERE role IN ('user', 'upload') AND research_group_project.project_id = ? AND research_group_project.research_group_id = research_group.id AND research_group.teacher_id " +
			"IN (SELECT teacher_id FROM research_group WHERE research_group.name = ?);");
	s.setInt(1, project_id); 
	s.setString(2, groupName); 
	rs = s.executeQuery();
	while (rs.next()) {
		String rg_name = rs.getString("name");
		linksToEachGroup = linksToEachGroup
				+ "<tr><td><A HREF='showLogbookRGforT.jsp?research_group_name="
				+ rg_name + "'>" + rg_name + "</A></td></tr>";
	}
%>

<table width="800" cellpadding="0" border="0" align="left">
	<tr>
		<td valign="top" align="150">
		<table width="140">
			<tr>
				<td valign="center" align="left"><a
					href="showLogbookKWforT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt="">By Milestone</a></td>
			</tr>
			<tr>
				<td valign="center" align="left"><a href="showLogbookT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt="">My Logbook</a></td>
			</tr>
			<tr>
				<td><b>Select a Research Group</b></td>
			</tr><%=linksToEachGroup%>

			<%
				if (!(research_group_name == null)) {
					String yesNo = "no";
					s = conn.prepareStatement(
							"SELECT DISTINCT keyword_id FROM log, research_group, keyword " +
							"WHERE keyword.keyword = 'general' and keyword.id = log.keyword_id and research_group.name = ? AND research_group.id = log.research_group_id AND log.project_id = ?;");
					s.setString(1, research_group_name); 
					s.setInt(2, project_id); 
					rs = s.executeQuery();
					if (rs.next()) {
						yesNo = "yes";
					}
			%>

			<tr>
				<td><br>
				<b>Entries for "<%=research_group_name%>"</b></td>
			</tr>

			<tr>
				<td valign="center" align="left"><a
					href="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>"><img
					src="graphics/logbook_view.gif" border="0" " align="middle" alt="">
				All Entries</a></td>
			</tr>
			<tr>
				<td align="center"><img src="graphics/log_entry_yes.gif"
					border="0" alt=""><font face="Comic Sans MS"> if entry
				exists</font></td>
			</tr>

			<tr>
				<td><img src="graphics/log_entry_<%=yesNo%>.gif" border="0"
					align="center" alt=""><a
					href="showLogbookRGforT.jsp?research_group_name=<%=research_group_name%>&amp;keyword=general">general</a></td>
			</tr>


			<%
				HashMap keywordTracker = new HashMap();
					s = conn.prepareStatement(
							"SELECT DISTINCT keyword_id FROM log, research_group " + 
							"WHERE research_group.name = ? AND research_group.id = log.research_group_id AND project_id = ?;");
					s.setString(1, research_group_name); 
					s.setInt(2, project_id); 
					rs = s.executeQuery();
					while (rs.next()) {
						keyword_id = (Integer) rs.getObject("keyword_id");
						keywordTracker.put(keyword_id, true);
					}

					//provide access to all possible items to view logs on. 
					s = conn.prepareStatement(
							"SELECT id, keyword, description, section, section_id FROM keyword " + 
							"WHERE keyword.project_id IN (0,?) " + 
							typeConstraint +
							"ORDER BY section, section_id;");
					s.setInt(1, project_id);
					rs = s.executeQuery();
					while (rs.next()) {
						keyword_id = (Integer) rs.getObject("id");
						keyword_loop = rs.getString("keyword");
						keyword_text = keyword_loop.replaceAll("_", " ");
						keyword_description = rs.getString("description");
						String this_section = (String) (rs.getString("section"));
						yesNo = "no";
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

							// More work to do if we haven't seen this one yet.
							if (keywordTracker.containsKey(keyword_id)) {
								yesNo = "yes";
							}

							keyColor = "";
							if (keyword.equals(keyword_loop)) {
								keyColor = "color=\"#AA3366\"";
							}
							linksToEach = linksToEach
									+ "<tr><td><img src=\"graphics/log_entry_"
									+ yesNo
									+ ".gif\" border=0 align=center><A HREF='showLogbookRGforT.jsp?research_group_name="
									+ research_group_name + "&keyword="
									+ keyword_loop + "'><FONT  " + keyColor + ">"
									+ keyword_text + "</font></A></td></tr>";
						}

					}
			%>
			<tr>
				<td><br>
				<b>Select a Milestone:</b></td>
			</tr>
			<%=linksToEach%>
			<%
				} //end of conditional list of keywords.
			%>

		</table>


		</td>

		<td align="left" width="20" valign="top"><img
			src="graphics/blue_square.gif" border="0" width="2" height="650"
			alt=""></td>

		<td valign="top" align="center">
		<div style="border-style: dotted; border-width: 1px;">
		<table width="600">
			<tr>
				<td align="left" colspan="4"><font size="+1"
					face="Comic Sans MS">Instructions</font></td>
			</tr>
			<table>
				<tr>
					<td align="right">&nbsp;</td>
					<td align="left">Click <b>Read more</b> to read full log entry
					and reset "new log" status.</td>
				</tr>
				<tr>
					<td align="right"><img src="graphics/logbook_pencil.gif"
						align="middle" border="0" alt=""></td>
					<td align="left">Button to add and view comments on a logbook
					entry.</td>
				</tr>

				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td align="right" colspan="2"><font size="-2">Log
					Status: New log entries are marked as <img
						src="graphics/new_flag.gif" border="0" align="center" alt="">
					<font color="#AA3366">New log entry</font>. Number of your comments
					(<font color="#AA3366"> number unread by students. </font>)</font><font></font>
					</td>
				</tr>

			</table>
			<div></div>
			<%
				if (!(research_group_name == null)) {

					// get group ID
					//groupName defined in common.jsp
					Integer research_group_id = null;
					s = conn.prepareStatement("SELECT id FROM research_group WHERE name = ?");
					s.setString(1, research_group_name);
					rs = s.executeQuery();
					if (rs.next()) {
						research_group_id = (Integer) rs.getObject("id");
					}

					if (research_group_id == null) {
			%>
			Problem with ID for research group
			<%=research_group_id%><br>
			<%
				return;
					}

					// Always pass keyword, not id so we can pick off the description
					//   String keyword_description="";
					keyword_id = null;
					if (!keyword.equals("")) {
						// first make sure a keyword was passed in the call
						s = conn.prepareStatement(
								"SELECT id, keyword, description FROM keyword WHERE project_id IN (0,?) AND keyword = ?;");
						s.setInt(1, project_id); 
						s.setString(2, keyword);
						rs = s.executeQuery();
						if (rs.next()) {
							keyword_id = (Integer) rs.getObject("id");
							keyword_description = rs.getString("description");
						}
						if (keyword_id == null) {
			%>
			Problem with id for log.
			<%=keyword%><br>
			<%
				return;
						}

					}

					querySort =  "ORDER BY keyword.section, keyword.section_id, log.id DESC;";
					queryItems = "SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text, keyword.description AS description, keyword.id AS data_keyword_id, keyword.keyword AS keyword_name, keyword.section AS section, keyword.section_id AS section_id, log.new_log AS new FROM log, keyword ";
					
					if (keyword_id == null) {
						%><h2>All logbook entries for group "<%=research_group_name%>"</h2><%
						
						s = conn.prepareStatement(
								queryItems + 
								"WHERE log.project_id = ? AND keyword.project_id IN (0, ?) AND log.keyword_id = keyword.id AND research_group_id = ? AND role = 'user' " +
								querySort);
						s.setInt(1, project_id); 
						s.setInt(2, project_id);
						s.setInt(3, research_group_id);

						keyword_description = "";
					} 
					else {
						%><h2>Logbook entry for group "<%=research_group_name%>"</h2><%
						
						s = conn.prepareStatement(
								queryItems +
								"WHERE log.project_id = ? AND keyword.project_id IN (0, ?) AND log.keyword_id = keyword.id AND research_group_id = ? AND role = 'user' AND keyword_id = ?" + 
								querySort);
						s.setInt(1, project_id); 
						s.setInt(2, project_id);
						s.setInt(3, research_group_id);
						s.setInt(4, keyword_id); 

					}
			%>

			<p>

			<table width="600" cellspacing="5">
				<%
					// look for any previous log entries for this keyword

						PreparedStatement sInner = null;
						ResultSet innerRs = null;

						int itemCount = 0;
						boolean showFullLog = false;
						String elipsis = "";
						String linkText = "";
						Integer current_keyword_id = null;
						String sectionText = "";
						current_section = "";
						rs = s.executeQuery();
						while (rs.next()) {
							Integer data_keyword_id = (Integer) rs.getObject("data_keyword_id");
							String dateText = rs.getString("date_entered");
							keyword_description = rs.getString("description");
							String log_text = rs.getString("log_text");

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
							String keyword_name = rs.getString("keyword_name");
							String keyword_display = keyword_name.replaceAll("_", " ");
							String section = rs.getString("section");
							Integer section_id = (Integer) rs.getObject("section_id");
							Long comment_count = null;
							Long comment_new = null;
							String comment_info = "";
							//  Do a query for this log entry to see if there are any unread comments on it and if it has comments on it.
							sInner = conn.prepareStatement("SELECT COUNT(id) AS comment_count FROM comment WHERE log_id = ?;");
							sInner.setInt(1, log_id);
							innerRs = sInner.executeQuery();
							if (innerRs.next()) {
								comment_count = (Long) innerRs.getObject("comment_count");
							}

							sInner = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new FROM comment WHERE comment.new_comment = 't' and log_id = ?;");
							sInner.setInt(1, log_id);
							innerRs = sInner.executeQuery();
							if (innerRs.next()) {
								comment_new = (Long) innerRs.getObject("comment_new");
							}
							if (new_log != null && new_log == true && !showFullLog) {
								comment_info = comment_info
										+ "<BR><IMG SRC=\'graphics/new_flag.gif\' border=0 align=\'center\'> <FONT color=\"#AA3366\" size=\"-2\"><b>New log entry</b></font>";
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
							if (!showFullLog) {
								linkText = "<A HREF=\"showLogbookRGforT.jsp?research_group_name="
										+ research_group_name
										+ "&keyword="
										+ keyword
										+ "&log_id="
										+ log_id
										+ "#"
										+ log_id
										+ "\">Read more</A>";
							}

							itemCount++;
							if (current_keyword_id == null || !(current_keyword_id.equals(data_keyword_id))) {
								current_keyword_id = data_keyword_id;
								if (itemCount > 1) {
				%>
			</table>
			<p>
			<%
				}
							if (keyword_name.equals("general")
									|| (current_section.equals(section))) {
								sectionText = "";
							} else {
								sectionText = "";
								char this_section_char = section.charAt(0);
								switch (this_section_char) {
								case 'A':
									sectionText = "Research Basics";
									break;
								case 'B':
									sectionText = "A: Get Started";
									break;
								case 'C':
									sectionText = "B: Figure it Out";
									break;
								case 'D':
									sectionText = "C: Tell Others";
									break;
								}
								current_section = section;
							}
			%>
			<table cellpadding="5">

				<%
					if (!sectionText.equals("")) {
				%>
				<tr align="left">
					<td colspan="2"><font size="+1"><%=sectionText%></font></td>
				</tr>
				<%
					}
				%>
				<tr align="left">
					<td colspan="2"><font size="+1" color="#AA3366"><%=keyword_display%></font>
					- <%=keyword_description%><font></font></td>
				</tr>
				<%
					}
				%>

				<tr>
					<td valign="top" width="175" align="right"><a
						href="logCommentEntry.jsp?log_id=<%=log_id%>&amp;keyword=<%=keyword_name%>&amp;research_group_name=<%=research_group_name%>&amp;path=RG"><img
						src="graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>
					<%=dateText%><%=comment_info%></td>
					<td width="400" valign="top"><a name="<%=log_id%>"><e:whitespaceAdjust
						text="<%=log_text_truncated%>" /></a><%=elipsis%><%=linkText%></td>
				</tr>
				<%
					if (showFullLog) {
								sInner = conn.prepareStatement("UPDATE log SET new_log = 'f' WHERE id = ?");
								sInner.setInt(1, log_id);
								int k = 0;
								try {
									k = sInner.executeUpdate();
								} catch (SQLException se) {
									warn(
											out,
											"There was some error updating your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: "
													+ sInner);
									return;
								} // try-catch for updating survey table
								if (k != 1) {
									warn(
											out,
											"Weren't able to update your info to the database! "
													+ k
													+ " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: "
													+ sInner);
									return;
								} //!k=1 test 

							}

						}
						if (itemCount == 0) {
							String noEntries = "No entries";
							if (!keyword_description.equals("")) {
								String keyword_name = keyword.replaceAll("_", " ");
								noEntries = noEntries + " for \"" + keyword_name + ": "
										+ keyword_description + "\"";
							}
				%>

				<tr align="center">
					<td colspan="2"><font size="+1"><%=noEntries%>.</font></td>
				</tr>
				<%
					}
				%>

			</table>

			<%
				} //for displaying right column - when research_group has been chosen
				else {
			%>
			<table width="600" cellspacing="5">
				<tr>
					<td width="590">&nbsp;</td>
				</tr>
			</table>


			<%
				}
			%>


			<td></td>
			<tr></tr>
			</p>
			</p>
		</table>





		<center></center>
		</div>
		</td>
	</tr>
</table>
</center>
</body>
<%
	if (s != null)
		s.close();
	if (conn != null)
		conn.close();
%>
</html>
