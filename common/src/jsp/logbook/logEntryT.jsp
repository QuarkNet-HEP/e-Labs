<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ include file="../login/teacher-login-required.jsp"%>
<%@ include file="../include/elab.jsp"%>
<%

	String messages = "";

	// called from showLogbookT.jsp where research_group_id is group id of teacher
	//  ref_rg_id is id of student research group for which teacher is adding log entry.
	String submit = request.getParameter("button");
	String log_text = request.getParameter("log_text");
	String img_src = request.getParameter("img_src");
	String ref_rg_name = "";
	String buttonText = "Add Your Logbook Entry";
	
	Integer keyword_id = 0;
	int count = -1;
	if (request.getParameter("count") != null) {
		count = Integer.parseInt(request.getParameter("count")); 
	}
	int project_id = elab.getId();
	int log_id = -1;
	if (request.getParameter("log_id") != null) {
		log_id =  Integer.parseInt(request.getParameter("log_id"));
	}
	int research_group_id = Integer.parseInt(request.getParameter("research_group_id"));
	int ref_rg_id = Integer.parseInt(request.getParameter("ref_rg_id"));
	String role = user.getRole();
	
	if (img_src == null)
		img_src = "";
	String groupName = user.getName();
	// get name of student research group
	//groupName defined in common.jsp
	if (ref_rg_id == research_group_id) {
		ref_rg_name = "General Notes";
	} 
	String currentEntries = "";
	boolean first = true;
	// look for any previous log entries for this keyword
	try {
		ResultSet rs = LogbookTools.getLogbookEntriesTeacher(project_id, ref_rg_id, research_group_id, role, elab);
		while (rs.next()) {
			int curLogId = rs.getInt("cur_id");
			if (!(curLogId == log_id)) { 
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
	    currentEntries = currentEntries.replace("''","'");
	} catch (Exception e) {
		messages += e.getMessage();
	}
	String display = "";
	String log_enter = "";
	if (submit != null && !log_text.equals("")) {
		// need to update or insert an entry yet
		log_enter = "<div style=\"white-space:pre;font-family:'Comic Sans MS'\">"
				+ log_text + "</div>";
		//EPeronja-04/08/2013: Changed the split to look for a tab char instead of a comma
		//					   If this needs to be changed, please also change logEntry.jsp and 
		//					   search-results-pick.jsp
		String parsed[] = img_src.split("\\t");

		for (int i = 0; i < parsed.length; i++) {
			log_enter = log_enter.replaceAll("\\(--Image " + i
					+ "--\\)", parsed[i]);
		}
		log_enter = log_enter.replaceAll("'", "''");
		if (log_enter.equals("")) {
			try {
				LogbookTools.insertLogbookEntry(project_id, research_group_id, keyword_id, role, log_enter, elab);
				log_id = LogbookTools.getLogId(research_group_id, project_id, keyword_id, elab);
				display = "<h2><font face=\"arial MS\">Your log was successfully entered. You can edit it and update it.<br> "+
						  " Click <font color=\"#1A8BC8\">Show Logbook</font> to access all entries in your logbook.</font></h2>";
			} catch (Exception e) {
				messages += e.getMessage();
			}
			buttonText = "Update Our Logbook Entry";
			log_enter = log_enter.replaceAll("''", "'");
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
	if (log_text == null) {
		log_text = "";
	}
	request.setAttribute("messages", messages);
	request.setAttribute("currentEntries", currentEntries);
	request.setAttribute("display", display);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Enter Logbook</title>
		<link rel="stylesheet" href="styletutT.css" type="text/css">
	</head>

	<body id="logentry">
		<!-- entire page container -->
		<div id="container">
			<div id="content">		
				<c:choose>
					<c:when test="${not empty messages }">
						${messages }
					</c:when>
					<c:otherwise>
			
							<center>				
							<table width="800" align="center">
								<tr>
									<td align="right"><img src="../graphics/logbook_large.gif"
										align="middle" border="0" alt=""></td>
									<td><font size="+2" face="arial MS" align="left">Your <b>Private</b> logbook entries for "<%=ref_rg_name%>"</font></td>
								</tr>
							</table>
							<c:choose>
								<c:when test="${not empty display }">
									${display}<br />
									<table border="1">
										<tr>
											<td align="left"><%=log_enter%></td>
										</tr>
									</table>
								</c:when>
							</c:choose>
							<p>
							<form method="get" name="log" action="">
								<table width="400">
									<tr>
										<th><font face="arial MS">Your New Log Book Entry</font></th>
										<th></th>
									</tr>
									<tr>
										<td colspan="2"><textarea name="log_text" cols="80" rows="10"><%=log_text%></textarea></td>
									</tr>
									<tr>
										<td align='left'><input type='button' name="plot"
											onclick="window.open('../plots/pick.jsp','win2', 'scrollbars=1,resizeable=true');if(childWindow.opener==null)childWindow.opener=self;"
											value="Insert a plot"></td>
										<td align="right"><input type="submit" name="button" value="<%=buttonText%>"></td>
									</tr>
									</tr>
								</table>
								<input type="hidden" name="log_id"value="<%=log_id%>"> 
								<input type="hidden" name="project_id" value="<%=project_id%>"> 
								<input type="hidden" name="research_group_id" value="<%=research_group_id%>"> 
								<input type="hidden" name="ref_rg_id" value="<%=ref_rg_id%>"> 
								<input type="hidden" name="role" value="<%=role%>"> 
								<!-- //EPeronja-04/08/2013: replace " by ', string was not showing correctly -->
								<input type="hidden" name="img_src" value='<%=img_src%>'> 
								<input type="hidden" name="count" value="<%=count%>">
							</form>						
							<br>
							<table>
								<tr>
									<td valign="center" align="center"><a href="showLogbookT.jsp"><font
										face="arial MS" size="+1"><img src="graphics/logbook_view.gif"
										border="0" align="middle" alt=""> Show Logbook</font></a></td>
								</tr>
							</table>
							<p>
			
							<c:choose>
								<c:when test="${not empty currentEntries }">
									<hr width="400" color="#F76540" size="3">
									<table width="600" cellspacing="5" cellpadding="5">
										${currentEntries}
									</table>	
								</c:when>
							</c:choose>
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
