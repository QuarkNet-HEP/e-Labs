<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.util.*"%>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp"%>
<%
 	String messages = "";
	String display = "";
	String role = user.getRole();
 	if (role.equals("teacher")) {
 		messages += "This page is only available to student research groups.";
 	}
 	String groupName = user.getName();
 	String submit = request.getParameter("button");
 	String log_text = request.getParameter("log_text");
 	if (log_text == null) {
 		log_text = "";
 	}
 	String img_src = request.getParameter("img_src");
	String keyword = request.getParameter("keyword");
	// Always pass keyword, not id so we can pick off the description
	String keyword_description = "";
	if (keyword == null) {
		keyword = "general";
	} //default to general keyword if none is included.
 	Integer keyword_id = null;
	String count_string= request.getParameter("count");
	Integer count = 0;
	Integer log_id = 0;
	if (count_string != null) {
 	  count = Integer.parseInt(count_string); 
	}
 	int project_id = elab.getId();	
 	String log_id_string = request.getParameter("log_id");
 	if (log_id_string != null) {
	 	log_id = Integer.parseInt(log_id_string);
 	}	
 	int research_group_id = user.getId();

 	String buttonText = "Add Your Logbook Entry";
 	String currentEntries = "";

	// first make sure a keyword was passed in the call
	ResultSet rs = LogbookTools.getKeywordDetails(keyword, elab);
	while (rs.next()) {
		keyword_id = (Integer) rs.getObject("id");
		keyword_description = rs.getString("description");
	}
	if (keyword_id == null) {
		messages += "Problem with id for log "+ keyword;
	}

	// look for any previous log entries for this keyword
	try {
	    currentEntries = LogbookTools.buildLogbookEntriesPlusComments(project_id, keyword_id, research_group_id, groupName, elab);
	} catch (Exception e) {
		messages += e.getMessage();
	}
	
	String log_enter = "";
	if ((submit != null) && !(log_text.equals(""))) {
		// need to update or insert an entry yet
		log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
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

		if (log_text != "") {
			try {
				LogbookTools.insertLogbookEntry(project_id, research_group_id, keyword_id, log_enter, "user", elab);
				log_id = LogbookTools.getLogId(research_group_id, project_id, keyword_id, "user", elab);
				display = "<h2><font face=\"Comic Sans MS\">Your log was successfully entered. You can edit it and update it.<br>"+
						   "Click <font color=\"#1A8BC8\">Show Logbook</font> to access all entries in your logbook.</font></h2>";
			} catch (Exception e) {
				messages += e.getMessage();
			}
		} else if (!log_enter.equals("")) {
			//we need to update row with id=log_id 
			try {
				int k = LogbookTools.updateLogbookEntry(log_enter, log_id, elab);
				display = "<h2><font face=\"Comic Sans MS\">Your log was successfully updated. You can edit it some more and update it.<br> Click <font color=\"#1A8BC8\">Show Logbook</font> to access all entries in your logbook.</font></h2>";
			} catch (Exception e) {
				messages += e.getMessage();
			}
		}			
		buttonText = "Update Our Logbook Entry";
		log_enter = log_enter.replaceAll("''", "'");
	}
	request.setAttribute("messages", messages);
	request.setAttribute("display", display);
	request.setAttribute("keyword_description", keyword_description);
	request.setAttribute("log_text", log_text);
	request.setAttribute("log_enter", log_enter);
	request.setAttribute("buttonText", buttonText);
	request.setAttribute("count", count);
	request.setAttribute("log_id", log_id);
	request.setAttribute("project_id", project_id);
	request.setAttribute("research_group_id", research_group_id);
	request.setAttribute("keyword", keyword);
	request.setAttribute("role", role);
	request.setAttribute("img_src", img_src);
    request.setAttribute("currentEntries", currentEntries);
    
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
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
		<link rel="stylesheet" href="styletut.css" type="text/css">
	</head>
	<body id="log-entry">
		<!-- entire page container -->
		<div id="container">
			<div id="content">			
			<c:choose>
				<c:when test="${not empty messages }">
					${messages }
				</c:when>
				<c:otherwise>
					<center>
						<table width="600" align="center">
							<tr>
								<td align="center"><img src="../graphics/logbook_large.gif" align="middle" border="0" alt=""><font size="+2" face="Comic Sans MS" align="left"> For "${keyword_description }"</font></td>
							</tr>
						</table>
						<p>
						<c:choose>
							<c:when test="${not empty display }">
								${display }<br />
								<table border="1">
									<tr>
										<td align='left'>${log_enter }</td>
									</tr>
								</table>
								
							</c:when>
						</c:choose>
						<form method="post" name="log" action="">
							<table width='400'>
								<tr>
									<th><font face="Comic Sans MS">Your New Log Book Entry</font></th>
									<th></th>
									<tr>
										<td colspan='2'><textarea name="log_text" cols="80" rows="10">${log_text }</textarea></td>
									</tr>
									<tr>
										<td align='left'><input type='button' name="plot"
											onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;"
											value="Insert a plot"></td>
										<td align='right'><input type="submit" name="button" value="${buttonText }"></td>
									</tr>
								</tr>
							</table>
							<input type="hidden" name="log_id" value="${log_id}">
							<input type="hidden" name="project_id" value="${project_id}">
							<input type="hidden" name="research_group_id" value="${research_group_id}">
							<input type="hidden" name="keyword" value="${keyword}">
							<input type="hidden" name="role" value="${role}">
							<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
							<input type="hidden" name="img_src" value='${img_src}'> <input type="hidden" name="count" value="${count }">
						</form>
				<br>
					<table>
						<tr>
							<td valign="center" align="center"><a href="show-logbook.jsp"><font face="Comic Sans MS" size="+1"><img src="../graphics/logbook_view.gif" border="0" " align="middle" alt="">Show Logbook</font></a></td>
						</tr>
					</table>
					<p>
						<c:choose>
							<c:when test="${not empty currentEntries }">
								<hr width="400" color="#1A8BC8" size="3">
								<table width="600" cellspacing="5" cellpadding="5">
									<%=currentEntries%>
								</table>
							</c:when>
						</c:choose>
					</p>
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
