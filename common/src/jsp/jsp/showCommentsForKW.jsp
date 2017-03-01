<%@ page import="java.util.*"%>
<%@ include file="common.jsp"%>
<html>
<head>
<title>Enter Logbook</title>
</head>
<link rel="stylesheet" href="include/styletut.css" type="text/css">
<body>
<center><!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb_ps.jsp"%> <%
 	// This will display all the comments associated with a particular keyword.
 	// e.g. select log.id,log.date_entered,log.log_text,comment.date_entered,comment.id,comment.comment from comment,log,keyword 
 	// where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=17 and log.research_group_id=57 and project_id=1; 
 	String keyword = request.getParameter("keyword");
 	String keyword_description = "";
 	Boolean new_comment; 
 	PreparedStatement sInner = null;
 	ResultSet innerRs = null;
 	Integer keyword_id = null, project_id, research_group_id = null; 

 	// get group ID
 	//groupName defined in common.jsp
 	s = conn.prepareStatement("SELECT id FROM research_group WHERE name = ?;");
 	s.setString(1, groupName); 
 	rs = s.executeQuery();
 	if (rs.next()) {
 		research_group_id = (Integer) rs.getObject("id");
 	}

 	if (research_group_id == null) {
 		%> Problem with ID for research group <%=groupName%><br> <%
		return;
	}
	try { 
		project_id = Integer.valueOf(request.getParameter("project_id"));
	}
	catch (NumberFormatException nfe) {
		project_id = null; 
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
	if (keyword == null) {
		keyword = "general";
	} //default to general keyword if none is included.
	String keyword_text = keyword.replaceAll("_", " ");

	// first make sure a keyword was passed in the call
	s = conn.prepareStatement(
			"SELECT id, description FROM keyword " + 
			"WHERE project_id IN (0,?) AND keyword = ?;");
	s.setInt(1, project_id);
	s.setString(2, keyword);
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
<h1><font face="Comic Sans MS">Comments on Your Logbook
Entries for<br>
"<%=keyword_description%>"</font></h1>
<div style="border-style: dotted; border-width: 1px; width: 500px">
<h2>Instructions</h2>
<p><font face="Comic Sans MS">Comments in <b><font
	color="red">red</font></b> are new. Be sure you read them.</font></p>
<p><img src="graphics/logbook_pencil.gif" border="0" align="middle"
	alt=""><font face="Comic Sans MS"> Button to add a logbook
entry for "<%=keyword_text%>".</font></p>
<p><img src="graphics/logbook_view.gif" border="0" align="middle"
	alt=""><font face="Comic Sans MS"> Button to view your
logbook".</font></p>
</div>
<p>

<table width="800" cellspacing="5" cellpadding="5">
	<%
		// look for any previous log entries for this keyword
		s = conn.prepareStatement(
				"SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS log_date, log.log_text AS log_text, to_char(comment.date_entered,'MM/DD/YYYY HH12:MI') AS comment_date, comment.id AS comment_id, comment.comment AS comment, comment.new_comment AS new_comment FROM comment, log, keyword " +
				"WHERE log.id = comment.log_id AND log.keyword_id = keyword.id AND keyword.id = ? AND log.research_group_id = ? AND log.project_id = ? AND keyword.project_id in (0,?) " +
				"ORDER BY log_id DESC, comment_id DESC;");
		s.setInt(1, keyword_id); 
		s.setInt(2, research_group_id); 
		s.setInt(3, project_id); 
		s.setInt(4, project_id); 
		int itemCount = 0;
		int curLogId = -1;
		rs = s.executeQuery();
		while (rs.next()) {
			int log_id = rs.getInt("log_id");
			String log_date = rs.getString("log_date");
			String log_text = rs.getString("log_text");
			int comment_id = rs.getInt("comment_id");
			String comment_date = rs.getString("comment_date");
			String comment_text = rs.getString("comment");
			new_comment = rs.getBoolean("new_comment");
			itemCount++;
			if (curLogId == log_id) {
				log_text = " ";
				log_date = " ";
			} else {
				curLogId = log_id;
				if (itemCount != 1) {
	%>
	<tr>
		<td colspan="4" align="center">
		<hr width="700" color="#1A8BC8" size="1">
		</td>
	</tr>
	<%
		}
			}
			if (itemCount == 1) {
	%>
	<tr>
		<td align="center">&nbsp;</td>
		<td align="center"><img src="graphics/logbook.gif" alt=""></td>
		<td align="center">&nbsp;</td>
		<td align="center"><img src="graphics/logbook_comments.gif"
			alt=""></td>
	</tr>
	<tr>
		<th align="right" valign="top"><font face="Comic Sans MS">Log
		Date</font></th>
		<th align="left" valign="top"><font face="Comic Sans MS">Log
		Entry</font></th>
		<th align="right" valign="top"><font face="Comic Sans MS">Date</font></th>
		<th align="left" valign="top"><font face="Comic Sans MS">Your
		Teacher's Comments</font> <a href="logEntry.jsp?keyword=<%=keyword%>"><img
			src="graphics/logbook_pencil.gif" border="0" align="middle" alt=""></a></th>
	</tr>
	<%
		} //itemCount
			String commentColor = "black";
			if (new_comment != null && new_comment.equals("t")) {
				commentColor = "red";
			}
	%>
	<tr>
		<td valign="top" width="100" align="right"><font
			face="Comic Sans MS"><%=log_date%><font></font></font></td>
		<td width="300" valign="top"><font face="Comic Sans MS"><e:whitespaceAdjust text="<%=log_text%>"></e:whitespaceAdjust></font></td>
		<td valign="top" width="100" align="right"><font
			face="Comic Sans MS" color="<%=commentColor%>"><%=comment_date%><font></font></font></td>
		<td width="300" valign="top"><font face="Comic Sans MS"
			color="<%=commentColor%>"><%=comment_text%></font></td>
	</tr>
	<%
		if (new_comment != null && new_comment.equals("t")) {
				//reset  new_comment to false
				sInner = conn.prepareStatement("UPDATE comment SET new_comment = 'f' WHERE id = ?;");
				sInner.setInt(1, comment_id); 
				int k = 0;
				try {
					k = sInner.executeUpdate();
				} catch (SQLException se) {
					warn(
							out,
							"There was some error updating your info into the comment table.\n<br>Please contact the database admin with this information:\n<br>SQLstatement: "
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

			} // New comment

		} //while

		if (itemCount == 0) {
	%>
	<tr>
		<td colspan="4" align="center"><font face="Comic Sans MS"
			size="+1">No comments.</font></td>
	</tr>
	<%
		}
	%>
</table>


<br>
<hr width="400" color="#1A8BC8" size="1">
<table>
	<tr>
		<td valign="center" align="center"><a href="showLogbook.jsp"><font
			face="Comic Sans MS" size="+1"><img
			src="graphics/logbook_view.gif" border="0" " align="middle" alt="">
		Show Logbook</font></a></td>
	</tr>
</table>
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
