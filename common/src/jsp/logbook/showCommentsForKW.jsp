<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.HTMLEscapingWriter"%>
<%@ page import="gov.fnal.elab.logbook.LogbookTools" %>
<%@ include file="../login/login-required.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>
<%
	String messages = "";
	// This will display all the comments associated with a particular keyword.
	// e.g. select log.id,log.date_entered,log.log_text,comment.date_entered,comment.id,comment.comment from comment,log,keyword 
	// where log.id=comment.log_id and log.keyword_id=keyword.id and keyword.id=17 and log.research_group_id=57 and project_id=1; 
	String keyword = request.getParameter("keyword");
	String keyword_description = "";
	Boolean new_comment; 
	PreparedStatement sInner = null;
	ResultSet innerRs = null;
	Integer keyword_id = null; 
	int research_group_id = user.getId();
	int project_id = elab.getId();

	// Always pass keyword, not id so we can pick off the description
	if (keyword == null) {
		keyword = "general";
	} //default to general keyword if none is included.
	String keyword_text = keyword.replaceAll("_", " ");

	// first make sure a keyword was passed in the call
	ResultSet rs = LogbookTools.getEntriesByKeyword(project_id, keyword, elab);
	while (rs.next()) {
		keyword_id = (Integer) rs.getObject("id");
		keyword_description = rs.getString("description");
	}

	// look for any previous log entries for this keyword

	rs = LogbookTools.getCommentDetails(keyword_id, research_group_id, project_id, elab);
    int itemCount = 0;
	int curLogId = -1;
	TreeMap<String, ArrayList> commentInfo = new TreeMap<String, ArrayList>();
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
				
			}
			if (itemCount == 1) {
				
			}
		}
		String commentColor = "black";
		if (new_comment != null && new_comment.equals("t")) {
			commentColor = "red";
		}
		if (new_comment != null && new_comment.equals("t")) {
			//reset  new_comment to false
			int k = LogbookTools.updateComment(comment_id, elab);
		} // New comment
		ArrayList details = new ArrayList();
		details.add(log_id);
		details.add(log_date);
		details.add(log_text);
		details.add(comment_id);
		details.add(comment_date);
		details.add(comment_text);
		details.add(new_comment);
		details.add(commentColor);
		commentInfo.put(String.valueOf(itemCount), details);
	} //while

	
	request.setAttribute("messages", messages);
	request.setAttribute("commentInfo", commentInfo);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="showcommentsforKW">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<center>
					<h1><font face="Comic Sans MS">Comments on Your Logbook Entries for<br>"<%=keyword_description%>"</font></h1>
					<div style="border-style: dotted; border-width: 1px; width: 500px">
						<h2>Instructions</h2>
						<p><font face="Comic Sans MS">Comments in <b><font color="red">red</font></b> are new. Be sure you read them.</font></p>
						<p><img src="../graphics/logbook_pencil.gif" border="0" align="middle" alt=""><font face="Comic Sans MS"> Button to add a logbook entry for "<%=keyword_text%>".</font></p>
						<p><img src="../graphics/logbook_view.gif" border="0" align="middle" alt=""><font face="Comic Sans MS"> Button to view your logbook".</font></p>
					</div>
					<p>
					<table width="800" cellspacing="5" cellpadding="5">
					</table>
					<br>
					<hr width="400" color="#1A8BC8" size="1">
					<table>
						<tr>
							<td valign="center" align="center"><a href="showLogbook.jsp"><font face="Comic Sans MS" size="+1"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="">Show Logbook</font></a></td>
						</tr>						
					</table>
					<table>
						<tr>
							<td align="center">&nbsp;</td>
							<td align="center"><img src="../graphics/logbook.gif" alt=""></td>
							<td align="center">&nbsp;</td>
							<td align="center"><img src="../graphics/logbook_comments.gif" alt=""></td>
						</tr>
						<tr>
							<th align="right" valign="top"><font face="Comic Sans MS">Log Date</font></th>
							<th align="left" valign="top"><font face="Comic Sans MS">Log Entry</font></th>
							<th align="right" valign="top"><font face="Comic Sans MS">Date</font></th>
							<th align="left" valign="top"><font face="Comic Sans MS">Your Teacher's Comments</font> <a href="logEntry.jsp?keyword=<%=keyword%>"><img src="../graphics/logbook_pencil.gif" border="0" align="middle" alt=""></a></th>
						</tr>
						<c:choose>
							<c:when test="${not empty commentInfo }">
								<c:forEach items="${commentInfo}" var="commentInfo">
									<tr>
										<td valign="top" width="100" align="right"><font face="Comic Sans MS">${commentInfo.value[1] }<font></font></font></td>
										<td width="300" valign="top"><font face="Comic Sans MS"><e:whitespaceAdjust text="${commentInfo.value[2] }"></e:whitespaceAdjust></font></td>
										<td valign="top" width="100" align="right"><font face="Comic Sans MS" color="${commentInfo.value[7] }">${commentInfo.value[4] }<font></font></font></td>
										<td width="300" valign="top"><font face="Comic Sans MS" color="${commentInfo.value[7] }">${commentInfo.value[5] }</font></td>
									</tr>						
								
								</c:forEach>
							</c:when>
						</c:choose>		
					</table>
					</p>
				</center>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->		
	</body>
</html>
