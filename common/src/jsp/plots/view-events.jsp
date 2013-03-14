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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis files</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>

	<body id="analysis-files" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="content">
<h3>Event Candidates</h3>
<%
        String filename = request.getParameter("filename");
        CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
        ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));
        String eventCandidates = null, eventNum = null;
        int eventStart = null;
        if (entry != null) {
        	eventCandidates = (String) entry.getTupleValue("eventCandidates");
        	eventNum = (String) entry.getTupleValue("eventNum");
        	eventStart = Integer.parseInt((String) entry.getTupleValue("eventStart"));
        	File ecFile = new File(eventCandidates);
        	String ecPath = ecFile.getAbsolutePath();
        	EventCandidates ec = EventCandidates.read(ecFile, 1, -1, eventStart, eventNum);
        	Collection rows = ec.getRows();
       	
//        	if (eventCandidates != null) {
//                eventCandidates = plotUser.getDirURL("plots") + '/' + eventCandidates;
//                }
        }
//        try {
//                FileInputStream fstream = new FileInputStream("/home/quarkcat/sw/tomcat/webapps" + eventCandidates);
//                DataInputStream dstream = new DataInputStream(fstream);
//                BufferedReader br  = new BufferedReader(new InputStreamReader(dstream));
//                String strLine;
//                while ((strLine = br.readLine()) != null) {
%>
                        <p><%=rows.size() %></p>
<%
//                }
//                dstream.close();
//                } catch (Exception e) {
//                }
%>
		 	</div>
		</div>
	</body>
</html>

