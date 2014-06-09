<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.*"%>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%
	String messages = "";
	String role = user.getRole();
	String submit = request.getParameter("submitButton");
	int log_id_param = -1;
	int comment_id = -1;
	if (request.getParameter("log_id") != null) {
		log_id_param = Integer.parseInt(request.getParameter("log_id"));
	}
	if (request.getParameter("comment_id") != null) {
		comment_id = Integer.parseInt(request.getParameter("comment_id"));
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
	try {
		ResultSet rs = LogbookTools.getKeywordDetailsByProject(project_id, keyword, elab);
		while (rs.next()) {
			keyword_id = (Integer) rs.getObject("id");
			keyword_description = rs.getString("description");
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}

	// This will display all the comments associated with a particular keyword research_group, both passed.
	String currentEntries = "";
	try {
		currentEntries = LogbookTools.buildExistingComments(keyword_id, research_group_id, project_id, research_group_name, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
		
  	// look for any previous log entries for this keyword
  	String display = "";
 	if (submit != null && !(comment_text.equals(""))) {
  		// need to update or insert an entry yet
  		String comment_enter = comment_text.replaceAll("'", "''");
  		if (comment_id == -1) {
  			//we have to insert a new row into table
  			try {
	  			LogbookTools.insertComment(log_id_param, comment_enter, elab);
	  			// get the comment_id of the entry you just entered
	  			comment_id = LogbookTools.getCommentId(log_id_param, comment_enter, elab);
	  			display = "<h2><font color=\"#1A8BC8\">Your comment was successfully "+
	  					  "entered. You can edit it and update it.<br>"+
	  					  "Use the buttons under the form to display the Research Group's Logbook</font></h2>";
  			} catch (Exception e) {
  				messages += e.getMessage();
  			}
  	 	 } else if (!comment_text.equals("")) {
			//we need to update row with id=comment_id 
			try {
				int k = LogbookTools.updateComment(comment_id, comment_enter, elab);
				display = "<h2><font color=\"#1A8BC8\">Your comment was successfully " +
						  "updated. You can edit it some more and update it.<br> "+
						  "Use the buttons under the form to display the Research Group's Logbook</font></h2>";
			} catch (Exception e) {
				messages += e.getMessage();
			}	
	  	 }
 		buttonText = "Update Your Comment on a Log Entry";
 	} 
 	String cur_log_text = "";	
 	try {
	  	ResultSet rs = LogbookTools.getCommentEntryById(log_id_param, elab);
	 	if (rs.next()) {
	 		cur_log_text = rs.getString("log_date")
	 				+ " - "
	 				+ ElabUtil.whitespaceAdjust(rs.getString("cur_log_text"));
	 	}
 	} catch (Exception e) {
 		messages += e.getMessage();
 	}
 	if (comment_text == null) {
 		comment_text = "";
 	}		

 	request.setAttribute("messages", messages);
 	request.setAttribute("research_group_name", research_group_name);
 	request.setAttribute("keyword", keyword);
 	request.setAttribute("keyword_text", keyword_text);
 	request.setAttribute("keyword_description", keyword_description);
 	request.setAttribute("cur_log_text", cur_log_text);
	request.setAttribute("log_id_param", log_id_param);
	request.setAttribute("comment_id", comment_id);
 	request.setAttribute("comment_text", comment_text);
 	request.setAttribute("buttonText", buttonText);
 	request.setAttribute("currentEntries", currentEntries);
	request.setAttribute("display", display);
	request.setAttribute("path", path);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="log-comment">
		<!-- entire page container -->
		<div id="container">
			<div id="content">			
			<c:choose>
				<c:when test="${not empty messages }">
					${messages }
				</c:when>
				<c:otherwise>
					<center>
						<h1>Comments on group ${research_group_name}'s logbook entries for<br>"${keyword_text }: ${keyword_description }"</h1>
						<p>
						<form method="get" name="log" action="">
						<table width="400">
							<tr>
								<th>Your new comment for</th>
							</tr>
							<tr>
								<td align="left">${cur_log_text }</td>
							</tr>
							<tr>
								<td><textarea name="comment_text" cols="80" rows="10">${comment_text }</textarea></td>
							</tr>
							<tr>
								<td align="center"><input type="submit" name="submitButton" value="${buttonText }"></td>
							</tr>
						</table>
						<input type="hidden" name="comment_id" value="${comment_id }">
						<input type="hidden" name="log_id" value="${log_id_param }">
						<input type="hidden" name="research_group_name" value="${research_group_name }">
						<input type="hidden" name="keyword" value="${keyword }">
		
					</form>

					<br>
					<table width="500">
						<c:choose>
							<c:when test='${path == "KW"}'>
								<tr>
									<td valign="center" align="center">
										<a href="show-logbook-keyword-teacher.jsp?research_group_name=${research_group_name }&amp;keyword=${keyword }">
											<img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">Go Back<br> For "${keyword }" for group "${research_group_name }"
										</a>
									</td>
								</tr>
							</c:when>
							<c:otherwise>
								<tr>
									<td valign="center" align="center">
										<a href="show-logbook-group-teacher.jsp?research_group_name=${research_group_name }&amp;keyword=${keyword }">
											<img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">Go Back<br> For "${keyword }" for group "${research_group_name }"
										</a>
									</td>						
								</tr>
							</c:otherwise>
						</c:choose>
					</table>
					<table>
						<c:choose>
							<c:when test='${path == "KW"}'>
								<tr>
									<td valign="center" align="center">
										<a href="show-logbook-keyword-teacher.jsp?keyword=${keyword}">
											<img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">Go Back<br />For "${keyword }" for all research groups.
										</a>
									</td>
								</tr>
							</c:when>
							<c:otherwise>
								<tr>
									<td valign="center" align="center">
										<a href="show-logbook-group-teacher.jsp?research_group_name=${research_group_name }">
											<img src="../graphics/logbook_view_small.gif" border="0" " align="middle" alt="">Go Back<br>For all keywords for group "${research_group_name }".
										</a>
									</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</table>
 					<br>
					<table width="800" cellspacing="5" cellpadding="5">
						<tr>
							<th colspan="5" align="center">${research_group_name }'s log entries and teacher's comments entered previously</th>
						</tr>
						${currentEntries }
					</table>					
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
