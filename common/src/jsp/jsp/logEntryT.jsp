<%@ page import="java.util.*"%>
<%@ include file="common.jsp"%>
<html>
<head>
<title>Enter Logbook</title>
</head>
<link rel="stylesheet" href="include/styletutT.css" type="text/css">
<body>
<center><!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb_ps.jsp"%> <%
 	// called from showLogbookT.jsp where research_group_id is group id of teacher
 	//  ref_rg_id is id of student research group for which teacher is adding log entry.

 	//start jsp by defining submit
 	String role = (String) session.getAttribute("role");
 	if (!role.equals("teacher")) {
 		out.write("This page is only available to teachers.");
 		return;
 	}
 	String submit = request.getParameter("button");
 	String log_text = request.getParameter("log_text");
 	String img_src = request.getParameter("img_src");
 	String ref_rg_name = "";
 	String buttonText = "Add Your Logbook Entry";
 	
 	Integer log_id, research_group_id, keyword_id, project_id, ref_rg_id;
 	int count; 
 	
 	try { 
 		project_id = Integer.valueOf(request.getParameter("project_id"));
 	}
 	catch (NumberFormatException nfe) { 
 		project_id = null;
 	}
 	try { 
 		log_id = Integer.valueOf(request.getParameter("log_id"));
 	}
 	catch (NumberFormatException nfe) { 
 		log_id = null;
 	}
 	try { 
 		research_group_id = Integer.valueOf(request.getParameter("research_group_id"));
 	}
 	catch (NumberFormatException nfe) { 
 		research_group_id = null;
 	}
 	try { 
 		ref_rg_id = Integer.valueOf(request.getParameter("ref_rg_id"));
 	}
 	catch (NumberFormatException nfe) { 
 		ref_rg_id = null;
 	}
 	try {
 		count = Integer.parseInt(request.getParameter("count"));
 	}
 	catch (NumberFormatException nfe) {
 		count = 0;
 	}
 	if (img_src == null)
 		img_src = "";

 	if (research_group_id == null) {
 		// get group ID
 		//groupName defined in common.jsp
 		s = conn.prepareStatement("SELECT id FROM research_group WHERE name = ?;");
 		s.setString(1, eLab);
 		rs = s.executeQuery();
 		if (rs.next()) {
 			research_group_id = (Integer) rs.getObject("id");
 		}

 		if (research_group_id == null) {
 			%> Problem with ID for research group <%=groupName%><br><%
		return;
		}
	}
	if (ref_rg_id == null) {
		// this is not optional; we have to know which student group it is.
		%> No student research group passed.<br><%
		return;
	} 
	else {
		// get name of student research group
		//groupName defined in common.jsp
		if (ref_rg_id.equals(research_group_id)) {
			ref_rg_name = "General Notes";
		} 
		else {
			s = conn.prepareStatement("SELECT name FROM research_group WHERE id = ?;");
			s.setInt(1, ref_rg_id);
			rs = s.executeQuery();
			if (rs.next()) {
				ref_rg_name = rs.getString("name");
			}
			if (ref_rg_name.equals("")) {
				%> Problem with ID for student research group,<br><%
				return;
			}
		}
	}

	if (project_id == null) {
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
	}
%>

<table width="800" align="center">
	<tr>
		<td align="right"><img src="graphics/logbook_large.gif"
			align="middle" border="0" alt=""></td>
		<td><font size="+2" face="arial MS" align="left">Your <b>Private</b>
		logbook entries for "<%=ref_rg_name%>"</font></td>
	</tr>
</table>
<%
	String currentEntries = "";
	boolean first = true;

	// look for any previous log entries for this keyword
	s = conn.prepareStatement(
			"SELECT id AS cur_id, to_char(date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text AS cur_text FROM log " + 
			"WHERE project_id = ? AND research_group_id = ? AND ref_rg_id = ? AND role = ? " +
			"ORDER BY cur_id;");
	s.setInt(1, project_id);
	s.setInt(2, research_group_id);
	s.setInt(3, ref_rg_id); 
	s.setString(4, role); 
	rs = s.executeQuery();
	
	while (rs.next()) {
		int curLogId = rs.getInt("cur_id");
		if ((log_id == null) || !(curLogId == log_id)) { 
			String curDate = rs.getString("date_entered");
			String curText = rs.getString("cur_text");
			if (first) {
				first = false;
				currentEntries = currentEntries
						+ "<tr><th align='center' colspan='2'><FONT FACE='arial MS'>Your Current Entries</font></th></tr>";

			}
			currentEntries = currentEntries
					+ "<tr><td valign='top' width='150' align='right'><FONT FACE='arial MS'>"
					+ curDate
					+ "<FONT></td><td width='450'><FONT FACE='arial MS'>"
					+ curText + "</FONT></td></tr>";
		}
	}

	if (submit != null && !log_text.equals("")) {
		// need to update or insert an entry yet
		String log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
				+ log_text + "</div>";
		//EPeronja-04/08/2013: Changed the split to look for a semicolon instead of a comma
		//					   If this needs to be changed, please also change logEntry.jsp and 
		//					   search-results-pick.jsp
		String parsed[] = img_src.split(";");
		for (int i = 0; i < parsed.length; i++) {
			log_enter = log_enter.replaceAll("\\(--Image " + i
					+ "--\\)", parsed[i]);
		}
		log_enter = log_enter.replaceAll("'", "''");
		if (log_id == null) {
			//we have to insert a new row into table
			int i = 0;
			s = conn.prepareStatement(
					"INSERT INTO log (project_id, research_group_id, ref_rg_id, role, log_text) " +
					"VALUES (?, ?, ?, ?, ?);");
			s.setInt(1, project_id);
			s.setInt(2, research_group_id);
			s.setInt(3, ref_rg_id); 
			s.setString(4, role);
			s.setString(5, log_enter); 
			try {
				i = s.executeUpdate();
			} catch (SQLException se) {
				warn(
						out,
						"There was some error entering your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: "
								+ s);
				return;
			}
			if (i != 1) {
				warn(
						out,
						"Weren't able to add your info to the database! "
								+ i
								+ " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: "
								+ s);
				return;
			}
			// get the log_id of the entry you just entered
			s = conn.prepareStatement(
					"SELECT id FROM log " + 
					"WHERE research_group_id = ? AND project_id = ? AND ref_rg_id = ? and role = ? " + 
					"ORDER BY id DESC; ");
			s.setInt(1, research_group_id);
			s.setInt(2, project_id); 
			s.setInt(3, ref_rg_id); 
			s.setString(4, role); 
			rs = s.executeQuery();
			if (rs.next()) {
				log_id = (Integer) rs.getObject("id");
			}
			if (log_id == null) {
				%> Problem with ID for log entered.<br><%
				return;
			}
%>
<h2><font face="arial MS">Your log was successfully entered.
You can edit it and update it.<br>
Click <font color="#1A8BC8">Show Logbook</font> to access all entries in
your logbook.</font></h2>
<%
	} else if (!log_text.equals("")) {
			//we need to update row with id=log_id 
			s = conn.prepareStatement("UPDATE log SET log_text = ? WHERE id = ?;");
			s.setString(1, log_text);
			s.setInt(2, log_id); 
			int k = 0;
			try {
				k = s.executeUpdate();
			} catch (SQLException se) {
				warn(
						out,
						"There was some error entering your info into the log table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: "
								+ s);
				return;
			} // try-catch for updating survey table
			if (k != 1) {
				warn(
						out,
						"Weren't able to add your info to the database! "
								+ k
								+ " rows updated.\n<br>Please alert the database admin with this information:\n<br>SQLstatement: "
								+ s);
				return;
			} //!k=1 test
%>
<h2><font face="arial MS">Your log was successfully updated.
You can edit it some more and update it.<br>
Click <font color="red">Show Logbook</font> to access all entries in
your logbook.</font></h2>
<%
	}
		buttonText = "Update Our Logbook Entry";
		log_enter = log_enter.replaceAll("''", "'");
%><table border="1">
	<tr>
		<td align="left"><%=log_enter%></td>
	</tr>
</table>
<%
	}
	if (log_text == null) {
		log_text = "";
	}
%>
<p>
<form method="get" name="log" action="">
<table width="400">
	<tr>
		<th><font face="arial MS">Your New Log Book Entry</font></th>
		<th></th>
		<tr>
			<td colspan="2">
			<%
				if (log_id != null) {
			%> <input type="hidden" name="log_id"
				value="<%=log_id%>"> <%
 	}
 %> <input type="hidden"
				name="project_id" value="<%=project_id%>"> <input
				type="hidden" name="research_group_id"
				value="<%=research_group_id%>"> <input type="hidden"
				name="ref_rg_id" value="<%=ref_rg_id%>"> <input
				type="hidden" name="role" value="<%=role%>"> <textarea
				name="log_text" cols="80" rows="10"><%=log_text%></textarea></td>
		</tr>
		<tr>
			<td align='left'><input type='button' name="plot"
				onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;"
				value="Insert a plot"></td>
			<td align="right"><input type="submit" name="button"
				value="<%=buttonText%>"></td>
		</tr>
	</tr>
</table>
<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
<input type="hidden" name="img_src" value='<%=img_src%>'> <input
	type="hidden" name="count" value="<%=count%>"></form>

<br>
<table>
	<tr>
		<td valign="center" align="center"><a href="showLogbookT.jsp"><font
			face="arial MS" size="+1"><img src="graphics/logbook_view.gif"
			border="0" align="middle" alt=""> Show Logbook</font></a></td>
	</tr>
</table>
<p>
<%
	if (!currentEntries.equals("")) {
%>
<hr width="400" color="#F76540" size="3">
<table width="600" cellspacing="5" cellpadding="5">
	<%=currentEntries%>
</table>



<%
	}
%>








<table></table>
</p>
</p>
</center>
</body>
<%
	if (s != null)
		s.close();
	if (conn != null)
		conn.close();
%>
</html>
