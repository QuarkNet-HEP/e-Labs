<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.util.URLEncoder" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%

String subject = "LIGO classroom activity";
String body = URLEncoder.encode("Please complete each of the fields below:"
	+ "\n\n"
	+ "First Name:\n\n"
	+ "Last Name:\n\n"
	+ "State:\n\n"
	+ "URL (or add attachment):\n\n"
	+ "Comments:\n");

request.setAttribute("subject", subject);
request.setAttribute("body", body);

%>
<html>
	<head>
		<title> LIGO e-Lab Classroom Activities</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	</head>

	<body id="community">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>

			<div id="content">
				<h1>Classroom Activities from Teachers and Staff</h1>   
				<a href="mailto:e-labs@fnal.gov?Subject=${subject}&Body=${body}">Submit a LIGO classroom activity</a><br /><br />
				<strong>Activities Submitted</strong>
				<ul>
					<li><a href="../classroom-activities/ligo_activity_2012.pdf">Using LIGO's e-Lab as a Stepping Stone to Research</a></li>
					<li><a href="../classroom-activities/ligo_activity_feb_2014.pdf">Looking for seismic events in LIGO data</a></li>
					<li><a href="../classroom-activities/Restless_Earth.pdf">Restless Earth</a></li>
				</ul>
				
			</div>
			<!-- end content -->

			<div id="footer">

			</div>
		
		</div>
		<!-- end page container -->
	</body>
</html>
