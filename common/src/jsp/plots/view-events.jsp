<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>

<!-- 
	EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot
			This page displays the events from the eventCandidates file saved with the plot
 -->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Event Candidates List for ${param.filename}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-metadata" class="data">
		<!-- entire page container -->
		<div id="container">
			<c:if test="${param.menu != 'no'}">
				<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			</c:if>
			
			<div id="content">
<%
	//get plot saved
	String filename = request.getParameter("filename");
	if (filename != null) {
		//get entries
		CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
		ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));
		String eventCandidates = null, eventNum = null, es = null, ecDir = null, ecUrl = null, ecFullPath = null;
		int eventStart = 1;
		Collection rows;
		if (entry != null) {
			//get attributes that we need to retrieve the event candidates
        	eventCandidates = (String) entry.getTupleValue("eventCandidates");
	        ecUrl = plotUser.getDirURL("plots") + '/' + eventCandidates;
	        Long en = (Long) entry.getTupleValue("eventnum");
    	    eventNum = Long.toString(en);
        	ecDir = (String) entry.getTupleValue("ecDir");
        	ecFullPath = ecDir + '/' + eventCandidates;
        	File ecFile = new File(ecFullPath);
        	String ecPath = ecFile.getAbsolutePath();
        	String outputDir = ecPath.replaceAll("eventCandidates", "");
        	File multiplicitySummary = new File(outputDir + "multiplicitySummary");		
        	EventCandidates ec = EventCandidates.read(ecFile, multiplicitySummary, 1, -1, eventStart, eventNum);
        	rows = ec.getRows();
        	request.setAttribute("rows", rows);
        	request.setAttribute("ecUrl", ecUrl);

%>
			<h3>Shower study candidates (<%=rows.size()%>)</h3>
			<p><a href="${ecUrl}">Event Candidates File</a></p>
			<table id="shower-events">
				<tr>
					<th width="98%">Event Date</th>
					<th width="1%">Event Coincidence</th>
					<th width="1%">Detector Coincidence</th>
				</tr>
				<c:forEach items="${rows}" var="row" varStatus="li">
					<tr bgcolor="${row.eventNum == eventNum ? '#aaaafc' : (li.count % 2 == 0 ? '#e7eefc' : '#ffffff')}">
						<td>${row.dateF}</td>
						<td>${row.eventCoincidence}</td>
						<td>${row.numDetectors}</td>
					</tr>
				</c:forEach>
			</table>
<%
        }//end of entry check
	}//end of filename check
%>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
