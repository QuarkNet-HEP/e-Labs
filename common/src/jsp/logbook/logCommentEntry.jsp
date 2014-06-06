<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.*"%>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	//start jsp by defining submit
	// sample sql - INSERT INTO comment (log_id,comment) VALUES (22,'I like how you solved this.');
	// parameters passed are log_id, optional comment_text, 

	String role = user.getRole();
	String submit = request.getParameter("button");
	int log_id_param = -1;
	int comment_id = -1;
	if (request.getParameter("log_id") != null) {
		log_id_param = Integer.parseInt(request.getParameter("log_id"));
	}
	if (request.getParameter("comment_id") != null) {
		log_id_param = Integer.parseInt(request.getParameter("comment_id"));
	}	
	String path = request.getParameter("path");
	if (path == null) {
		path = "RG";
	}
	String comment_text = request.getParameter("comment_text");
	String research_group_name = request.getParameter("research_group_name");
	Integer keyword_id = null;
	String keyword_text = "";
	String buttonText = "Add Your Comment to a Logbook Entry";

	ElabGroup eg = user.getGroup(research_group_name);
	int research_group_id = eg.getId();
	int project_id = elab.getId();
	
	// Always pass keyword, not id so we can pick off the description
	String keyword_description = "";
	String keyword = request.getParameter("keyword");
	if (keyword == null) {
		keyword = "general";
	} //default to general keyword if none is included.
	keyword_text = keyword.replaceAll("_", " ");

	// first make sure a keyword was passed in the call	
	ResultSet rs = LogbookTools.getEntriesByKeyword(project_id, keyword, elab);
	while (rs.next()) {
		keyword_id = (Integer) rs.getObject("id");
		keyword_description = rs.getString("description");
	}
	// This will display all the comments associated with a particular keyword research_group, both passed.
	// e.g. select log.id,log.date_entered,log.log_text,comment.date_entered,comment.id,comment.comment from comment,log,keyword 
	// where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=17 and log.research_group_id=57 and project_id=1; 

	String currentEntries = "";
  	// look for any previous log entries for this keyword
  	rs = LogbookTools.getEntryDetails(keyword_id, research_group_id, project_id, elab);
  	
  	int itemCount = 0;
  	String hrHtml = "";
  	ResultSet sInner = null;
  	while (rs.next()) {
  		int log_id = rs.getInt("log_id");
  		String log_date = rs.getString("log_date");
  		String log_text = ElabUtil.whitespaceAdjust(rs.getString("log_text"));
  		String log_date_show = log_date;
  		String log_text_show = log_text;
  		itemCount++;
  		currentEntries = currentEntries + hrHtml;
  		if (itemCount == 1) {
  			currentEntries = currentEntries
  					+ "<tr><th valign='center' align='right'><IMG SRC='../graphics/logbook.gif' align='middle'></th><th valign='center' align='left'>"
  					+ research_group_name
  					+ "\'s log entries</th><th><IMG SRC='../graphics/blue_square.gif' width='1' height='20' align='top'></th><th valign='center' align='right'><IMG SRC='../graphics/logbook_comments.gif' align='middle'></th><th valign='center' align='left'>teacher\'s comments</th></tr><tr><td colspan='5'><HR  color='#1A8BC8'></td></tr>";
  		} //itemCount

  		// look for comments associated with this log item
  		sInner = LogbookTools.getCommentDetails(log_id, elab);
  		int commentCount = 0;
  		String comment_date = ""; // this makes baby dieties cry 
  		String comment_existing = "";
  		while (sInner.next()) {
  			comment_date = sInner.getString("comment_date");
  			comment_existing = ElabUtil.whitespaceAdjust(sInner.getString("comment"));
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
  					+ log_text
  					+ "</td><td><IMG SRC='graphics/blue_square.gif' width='1' height='20' align='top'><td valign='top' width='100' align='right'>&nbsp;</td><td width='300'  valign='top'>No comments.</td></tr>";
  		}

  		if (itemCount == 0) {
  			currentEntries = currentEntries
  					+ "<tr><td colspan='4' align='center'><FONT  size='+1'>No comments on this item.</FONT></td></tr>";
  		}
  	} //while for log
	String display = "";
 	if (submit != null && !(comment_text.equals(""))) {
  		// need to update or insert an entry yet

  		String comment_enter = comment_text.replaceAll("'", "''");
  		if (comment_id != -1) {
  			//we have to insert a new row into table
  			LogbookTools.insertComment(log_id_param, comment_enter, elab);
  			// get the comment_id of the entry you just entered
  			comment_id = LogbookTools.getCommentId(log_id_param, comment_enter, elab);
  			display = "<h2><font color=\"#1A8BC8\">Your comment was successfully "+
  					  "entered. You can edit it and update it.<br>"+
  					  "Use the buttons under the form to display the Research Group's Logbook</font></h2>";
  	 	 } else if (!comment_text.equals("")) {
			//we need to update row with id=comment_id 
			int k = LogbookTools.updateComment(comment_id, comment_enter, elab);
			display = "<h2><font color=\"#1A8BC8\">Your comment was successfully " +
					  "updated. You can edit it some more and update it.<br> "+
					  "Use the buttons under the form to display the Research Group's Logbook</font></h2>";
	
	  	 }
 		buttonText = "Update Your Comment on a Log Entry";
 	} 
  	rs = LogbookTools.getCommentEntries(log_id_param, elab);
 	String cur_log_text = "";
 	if (rs.next()) {
 		cur_log_text = rs.getString("log_date")
 				+ " - "
 				+ ElabUtil.whitespaceAdjust(rs.getString("cur_log_text"));
 	}

 	if (comment_text == null) {
 		comment_text = "";
 	}
  			
 	request.setAttribute("messages", messages);
	request.setAttribute("display", display);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body>
		<!-- entire page container -->
		<div id="container">
			<div id="content">			
			<c:choose>
				<c:when test="${not empty messages }">
					${messages }
				</c:when>
				<c:otherwise>
					<center>
						<h1>Comments on group <%=research_group_name%>'s logbook entries for<br>"<%=keyword_text%>: <%=keyword_description%>"</h1>
						<p>
						<form method="get" name="log" action="">
						<table width="400">
							<tr>
								<th>Your new comment for</th>
							</tr>
							<tr>
								<td align="left"><%=cur_log_text%></td>
							</tr>
							<tr>
								<td><textarea name="comment_text" cols="80" rows="10"><%=comment_text%></textarea></td>
							</tr>
							<tr>
								<td align="center"><input type="submit" name="button"
									value="<%=buttonText%>"></td>
							</tr>
						</table>
						<input type="hidden" name="comment_id" value="<%=comment_id%>">
						<input type="hidden" name="log_id" value="<%=log_id_param%>">
						<input type="hidden" name="research_group_name" value="<%=research_group_name%>">
						<input type="hidden" name="keyword" value="<%=keyword%>">
					</form>

					<br>
					<table width="500">
						<tr>
							<td valign="center" align="center"><a
								href="showLogbook<%=path%>forT.jsp?research_group_name=<%=research_group_name%>&amp;keyword=<%=keyword%>"><img
								src="../graphics/logbook_view_small.gif" border="0" " align="middle"
								alt="">Go Back<br>
							For "<%=keyword%>" for group "<%=research_group_name%>"</a></td>
					
							<%
						if (path.equals("KW")) {
					%>
							<td valign="center" align="center"><a
								href="showLogbook<%=path%>forT.jsp?keyword=<%=keyword%>"><img
								src="../graphics/logbook_view_small.gif" border="0" " align="middle"
								alt="">Go Back<br>
							For "<%=keyword%>" for all research groups.</a></td>
						</tr>
					</table>
					
					<%
						} else {
					%>
					<td valign="center" align="center"><a
						href="showLogbook<%=path%>forT.jsp?research_group_name=<%=research_group_name%>"><img
						src="../graphics/logbook_view_small.gif" border="0" " align="middle"
						alt="">Go Back<br>
					For all keywords for group "<%=research_group_name%>".</a></td>
					<tr></tr>
					</table>

 					<br>
					<table width="800" cellspacing="5" cellpadding="5">
						<tr>
							<th colspan="5" align="center"><%=research_group_name%>'s log entries and teacher's comments entered previously</th>
						</tr>
						<%=currentEntries%>
					</table>
					


					</p></p>
					</center>
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
