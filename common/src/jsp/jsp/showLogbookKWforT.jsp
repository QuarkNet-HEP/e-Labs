<%@ page import="java.util.*"%>
<%@ include file="common.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<link rel="stylesheet" href="include/styletut.css" type="text/css">
<html>
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
 	String role = (String) session.getAttribute("role");
 	if (role.equals("student") || role.equals("upload")) {
 		out.write("This page is only available to teachers");
 		return;
 	}
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
 	String research_group_name = groupName; // set in common.jsp
 	String keyColor = "";
 	String keyword = request.getParameter("keyword");
 	
 	Integer teacher_id = null;
 	// get project ID
 	//eLab defined in common.jsp
 	Integer project_id = null;
 	
 	Integer passed_log_id;
 	try {
 		passed_log_id = Integer.valueOf(request.getParameter("log_id"));
 	}
 	catch (NumberFormatException nfe) {
 		passed_log_id = null; 
 	}
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

	if (keyword == null) {
		keyword = "general";
	} // default to showing entries for "general" if no keyword is passed.
%>
<table width="800" cellpadding="0" border="0" align="left">
	<tr>
		<td valign="top" align="150">
		<table width="140">
			<tr>
				<td><a href="showLogbookRGforT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt="">By Group</a></td>
			</tr>

			<tr>
				<td valign="center" align="left"><a href="showLogbookT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt="">My Logbook</a></td>
			</tr>
			<tr>
				<td><a href="showLogbookKWforT.jsp?keyword=general">general</a></td>
			</tr>
			<tr>
				<td><b>Select a Milestone:</b></td>
			</tr>


			<%
				//provide access to all possible items to view logs on.
				s = conn.prepareStatement(
						"SELECT id, keyword, description, section, section_id FROM keyword " + 
						"WHERE keyword.project_id in (0,?) ORDER BY section, section_id;");
				s.setInt(1, project_id);
				rs = s.executeQuery(); 
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
			%>
			<%=linksToEach%>

		</table>


		</td>

		<td align="left" width="20" valign="top"><img
			src="graphics/blue_square.gif" border="0" width="2" height="475"
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
						align="center" border="0" alt=""></td>
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
				// Always pass keyword, not id so we can pick off the description
				//   String keyword_description="";
				keyword_id = null;
				// first make sure a keyword was passed in the call
				s = conn.prepareStatement(
						"SELECT id, keyword, description FROM keyword " +
						"WHERE project_id in (0,?) AND keyword = ?;");
				s.setInt(1, project_id);
				s.setString(2, keyword);
				rs = s.executeQuery();
				if (rs.next()) {
					keyword_id = (Integer) rs.getObject("id");
					keyword_description = rs.getString("description");
				}
				if (keyword_id == null) {
					%>Problem with id for log.<%=keyword%><br><%
					return;
				}

				// Get teacher_id of this user.
				s = conn.prepareStatement("SELECT teacher_id FROM research_group WHERE name = ?;");
				s.setString(1, groupName);

				rs = s.executeQuery();
				if (rs.next()) {
					teacher_id = (Integer) rs.getObject("teacher_id");
				}
				if (teacher_id == null) {
					%>Problem with id for teacher.<br><%
					return;
				}
			%>





			<h2>All logbook entries for your research groups<br>
			for "<%=keyword_description%>"</h2>
			<p>

			<table width="600" cellspacing="5">
				<%
					// look for any previous log entries for this keyword and all research groups
					PreparedStatement sInner = null;
					ResultSet innerRs = null;

					int itemCount = 0;
					boolean showFullLog = false;
					String current_rg_name = "";
					String elipsis = "";
					String linkText = "";
					s = conn.prepareStatement(
							"SELECT research_group.name AS rg_name, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log.log_text AS log_text,log.id AS log_id,log.new_log AS new FROM log, research_group " +
							"WHERE log.keyword_id = ? AND research_group.id = log.research_group_id AND research_group.teacher_id = ? AND research_group.role IN ('user', 'upload') " + 
							"ORDER BY research_group.name, log.id DESC;"); 
					s.setInt(1, keyword_id);
					s.setInt(2, teacher_id);
					rs = s.executeQuery();
					while (rs.next()) {
						String dateText = rs.getString("date_entered");
						String log_text = rs.getString("log_text");
						int log_id = rs.getInt("log_id");
						showFullLog = false;
						if (passed_log_id != null && log_id == passed_log_id) {
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
						sInner = conn.prepareStatement("SELECT COUNT(id) AS comment_count FROM comment WHERE log_id = ?;");
						sInner.setInt(1, log_id);
						//  Do a query for this log entry to see if there are any unread comments on it and if it has comments on it.
						innerRs = sInner.executeQuery();
						if (innerRs.next()) {
							comment_count = (Long) innerRs.getObject("comment_count");
						}
						sInner = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new FROM comment WHERE comment.new_comment = 't' AND log_id = ?;");
						sInner.setInt(1, log_id);
						//  out.write(innerQuery);
						innerRs = sInner.executeQuery();
						
						if (innerRs.next()) {
							comment_new = (Long) innerRs.getObject("comment_new");
						}
						if (new_log != null && new_log.equals("t") && !showFullLog) {
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
						if (!(current_rg_name.equals(rg_name))) {
							current_rg_name = rg_name;
							if (itemCount > 1) {
				%>
			</table>
			<p>
			<%
				}
			%>
			<table cellpadding="5">
				<tr align="center">
					<td colspan="2"><font size="+1">Group: "<%=rg_name%>"</font></td>
				</tr>
				<%
					}
				%>
				<tr>
					<td valign="top" width="175" align="right"><a
						href="logCommentEntry.jsp?log_id=<%=log_id%>&amp;keyword=<%=keyword%>&amp;research_group_name=<%=rg_name%>&amp;path=KW"><img
						src="graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>
					<%=dateText%><%=comment_info%></td>
					<td width="400" valign="top">
					<!-- EPeronja-04/12/2013: implemented javascript instead of resubmitting -->
					<div id="fullLog<%=log_id %>" style="display:none;"><e:whitespaceAdjust text="<%=log_text%>"></e:whitespaceAdjust></div>
					<div id="showLog<%=log_id%>"><e:whitespaceAdjust
						text="<%=log_text_truncated%>" /><%=elipsis%><a href='javascript:showFullLog("showLog<%=log_id%>","fullLog<%=log_id%>");'>Read More</a></div></td>
						
				</tr>
				<%
					if (showFullLog) {
						sInner = conn.prepareStatement("UPDATE log SET new_log = 'f' WHERE id = ?;");
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
				%>

				<tr align="center">
					<td colspan="2"><font size="+1">No entries for this
					milestone.</font></td>
				</tr>
				<%
					}
				%>

			</table>
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
