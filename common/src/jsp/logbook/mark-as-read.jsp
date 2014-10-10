<%@ page import="java.util.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.logbook.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp"%>
<%
//check if we are marking entries as read
String messages = "";
String mark_as_read = request.getParameter("mark_as_read");
if (mark_as_read != null && mark_as_read.equals("yes")) {
	Integer logMark = Integer.parseInt(request.getParameter("log_id"));
	String markWhat = request.getParameter("markWhat");
	
	try {
		if (markWhat.equals("comments")) {
			LogbookTools.updateResetCommentsforLogbookEntry(logMark, elab);			
		} else {
			LogbookTools.updateResetLogbookEntry(logMark, elab);
		}
	} catch (Exception e) {
		messages += e.getMessage();
	}
}
%>