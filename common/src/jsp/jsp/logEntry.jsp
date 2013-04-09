<%@ page import="java.util.*"%>
<%@ page import="gov.fnal.elab.util.*"%>
<%@ include file="common.jsp"%>
<%@ include file="../login/login-required.jsp"%>
<html>
<head>
<title>Enter Logbook</title>
</head>
<script language='javascript' type="text/javascript">
function insertImgSrc()
{
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

<link rel="stylesheet" href="include/styletut.css" type="text/css">
<body>
<center><!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb_ps.jsp"%> <%
 	//start jsp by defining submit
 	String role = (String) session.getAttribute("role");
 	if (role.equals("teacher")) {
 		out.write("This page is only available to student research groups.");
 		return;
 	}
 	String submit = request.getParameter("button");
 	String log_text = request.getParameter("log_text");
 	String img_src = request.getParameter("img_src");
	String keyword = request.getParameter("keyword");

 	Integer log_id, research_group_id, keyword_id = null, project_id;
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
 		count = Integer.parseInt(request.getParameter("count"));
 	}
 	catch (NumberFormatException nfe) {
 		count = 0;
 	}
 	if (img_src == null)
 		img_src = "";
 	
 	String buttonText = "Add Your Logbook Entry";
 	String currentEntries = "";

 	if (research_group_id == null) {
 		// get group ID
 		//groupName defined in common.jsp
 		s = conn.prepareStatement("SELECT id FROM research_group WHERE name = ?;");
 		s.setString(1, groupName);
 		rs = s.executeQuery();
 		if (rs.next()) {
 			research_group_id = (Integer) rs.getObject("id");
 		}

 		if (research_group_id == null) {
 			%> Problem with ID for research group <%=groupName%><br><%
		return;
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
	// Always pass keyword, not id so we can pick off the description
	String keyword_description = "";
	if (keyword == null) {
		keyword = "general";
	} //default to general keyword if none is included.

	// first make sure a keyword was passed in the call
	s = conn.prepareStatement("SELECT id, description FROM keyword WHERE keyword = ?;");
	s.setString(1, keyword);
	rs = s.executeQuery();
	while (rs.next()) {
		keyword_id = (Integer) rs.getObject("id");
		keyword_description = rs.getString("description");
	}
	if (keyword_id == null) {
		%> Problem with id for log. <%=keyword%><br><%
		return;
	}
%>

<table width="600" align="center">
	<tr>
		<td align="center"><img src="graphics/logbook_large.gif"
			align="middle" border="0" alt=""><font size="+2"
			face="Comic Sans MS" align="left"> For "<%=keyword_description%>"</font></td>
	</tr>
</table>



<%

	// second version

	// look for any previous log entries for this keyword
	s = conn.prepareStatement(
			"SELECT log.id AS cur_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log.log_text AS cur_text FROM log " + 
			"WHERE project_id = ? AND keyword_id = ? AND research_group_id = ? AND role = 'user' " +
			"ORDER BY cur_id DESC;");
	s.setInt(1, project_id);
	s.setInt(2, keyword_id); 
	s.setInt(3, research_group_id); 
	
	PreparedStatement sInner = null; // for comment query
	ResultSet innerRs = null; // for comment query
	int itemCount = 0;
	String hrHtml = "";
	//out.write(query);
	rs = s.executeQuery();
	while (rs.next()) {
		int cur_log_id = rs.getInt("cur_id");
		String log_date = rs.getString("date_entered");
		String cur_log_text = ElabUtil.whitespaceAdjust(rs.getString("cur_text"));
		String log_date_show = log_date;
		String log_text_show = cur_log_text;
		itemCount++;
		currentEntries = currentEntries + hrHtml;
		if (itemCount == 1) {
			currentEntries = currentEntries
					+ "<tr><th valign='center' align='right'><IMG SRC='graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"
					+ groupName
					+ "\'s log entries</th><th><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
		} //itemCount

		// look for comments associated with this log item

		sInner = conn.prepareStatement(
				"SELECT to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') AS comment_date, comment.comment AS comment FROM comment WHERE log_id = ?;");
		sInner.setInt(1, cur_log_id);
		//out.write("\r\r"+innerQuery);
		innerRs = sInner.executeQuery();
		int commentCount = 0;
		String comment_date = "";
		String comment_existing = "";
		while (innerRs.next()) {
			comment_date = innerRs.getString("comment_date");
			comment_existing = innerRs.getString("comment");
			commentCount++;
			if (commentCount > 1) {
				log_text_show = " ";
				log_date_show = " ";
				hrHtml = "";
			} else {
				hrHtml = "<tr><td colspan='5'><HR color='#1A8BC8'></td></tr>";
			}

			currentEntries = currentEntries
					+ "<tr><td valign='top' width='100' align='right'>"
					+ log_date_show
					+ "</td><td width='300'  valign='top'>"
					+ log_text_show + "</td>";
			// out.write ("Comment Count ="+commentCount);
			// out.write ("comment_existing="+comment_existing);
			currentEntries = currentEntries
					+ "<td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>"
					+ comment_date
					+ "</td><td width='300'  valign='top'>"
					+ comment_existing + "</td></tr>";

		} //while for comments
		if (commentCount == 0) {
			currentEntries = currentEntries
					+ "<tr><td valign='top' width='100' align='right'>"
					+ log_date
					+ "</td><td width='300'  valign='top'>"
					+ cur_log_text
					+ "</td><td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
		}

		if (itemCount == 0) {
			currentEntries = currentEntries
					+ "<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
		}
	} //while for log

	// end of second version

	if ((submit != null) && !(log_text.equals(""))) {
		// need to update or insert an entry yet
		String log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
				+ log_text + "</div>";

		//EPeronja-04/08/2013: Changed the split to look for a tab char instead of a comma
		//					   If this needs to be changed, please also change logEntryT.jsp and 
		//					   search-results-pick.jsp
		String parsed[] = img_src.split("\\t");

		for (int i = 0; i < parsed.length; i++) {
			log_enter = log_enter.replaceAll("\\(--Image " + i
					+ "--\\)", parsed[i]);
		}
		log_enter = log_enter.replaceAll("'", "''");

		if (log_id == null && log_text != "") {
			//we have to insert a new row into table
			int i = 0;
			s = conn.prepareStatement(
					"INSERT INTO log (project_id, research_group_id, keyword_id, role, log_text, new_log) VALUES (?, ?, ?, 'user', ?, 't');");
			s.setInt(1, project_id);
			s.setInt(2, research_group_id);
			s.setInt(3, keyword_id);
			s.setString(4, log_enter); 
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
					"WHERE research_group_id = ? AND project_id = ? and keyword_id = ? AND role = 'user' " + 
					"ORDER BY id DESC;");
			s.setInt(1, research_group_id);
			s.setInt(2, project_id);
			s.setInt(3, keyword_id);
			rs = s.executeQuery();
			if (rs.next()) {
				log_id = (Integer) rs.getObject("id");
			}
			if (log_id == null) {
				%> Problem with ID for log entered.<br><%
				return;
			}
%>
<h2><font face="Comic Sans MS">Your log was successfully
entered. You can edit it and update it.<br>
Click <font color="#1A8BC8">Show Logbook</font> to access all entries in
your logbook.</font></h2>
<%
	} else if (!log_enter.equals("")) {
			//we need to update row with id=log_id 
			s = conn.prepareStatement("UPDATE log SET log_text = ? WHERE  id = ?;");
			s.setString(1, log_enter);
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
<h2><font face="Comic Sans MS">Your log was successfully
updated. You can edit it some more and update it.<br>
Click <font color="#1A8BC8">Show Logbook</font> to access all entries in
your logbook.</font></h2>
<%
	}
		buttonText = "Update Our Logbook Entry";
		log_enter = log_enter.replaceAll("''", "'");
%><table border="1">
	<tr>
		<td align='left'><%=log_enter%></td>
	</tr>
</table>

<%
	}
	if (log_text == null) {
		log_text = "";
	}
%>
<p>
<form method="post" name="log" action="">
<table width='400'>
	<tr>
		<th><font face="Comic Sans MS">Your New Log Book Entry</font></th>
		<th></th>
		<%
			if (log_id != null) {
		%>
		<tr>
			<td colspan='2'><input type="hidden" name="log_id"
				value="<%=log_id%>"></td>
		</tr>
		<%
			}
		%>
		<tr>
			<td colspan='2'><input type="hidden" name="project_id"
				value="<%=project_id%>"></td>
		</tr>
		<tr>
			<td colspan='2'><input type="hidden" name="research_group_id"
				value="<%=research_group_id%>"></td>
		</tr>
		<tr>
			<td colspan='2'><input type="hidden" name="keyword"
				value="<%=keyword%>"></td>
		</tr>
		<tr>
			<td colspan='2'><input type="hidden" name="role"
				value="<%=role%>"></td>
		</tr>
		<tr>
			<td colspan='2'><textarea name="log_text" cols="80" rows="10"><%=log_text%></textarea></td>
		</tr>
		<tr>
			<td align='left'><input type='button' name="plot"
				onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;"
				value="Insert a plot"></td>
			<td align='right'><input type="submit" name="button"
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
		<td valign="center" align="center"><a href="showLogbook.jsp"><font
			face="Comic Sans MS" size="+1"><img
			src="graphics/logbook_view.gif" border="0" " align="middle" alt="">
		Show Logbook</font></a></td>
	</tr>
</table>

<p>
<%
	if (!currentEntries.equals("")) {
%>
<hr width="400" color="#1A8BC8" size="3">
<table width="600" cellspacing="5" cellpadding="5">
	<%=currentEntries%>
</table>



<%
	}
%>
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
