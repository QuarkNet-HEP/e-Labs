<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>
<%
session.setAttribute("key", "");
session.setAttribute("value", "");
session.setAttribute("date1", "");
session.setAttribute("date2", "");
session.setAttribute("stacked", "");
session.setAttribute("blessed", "");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose data for time of flight study</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<link rel="stylesheet" type="text/css" href="../css/ltbr.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="timeofflight" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>Time of Flight: Choose data for time of flight study.</h1>
<table border="0" id="main">
	<tr>
		<td>
			<div id="ltbr">
				<div id="top-left">
					<jsp:include page="../data/multiselect-search-control.jsp">
						<jsp:param name="type" value="split"/>
					</jsp:include>
					<jsp:include page="../data/search-number.jsp"/>
				</div>
				<div id="right">
					<%@ include file="help.jsp" %>
					<%@ include file="../data/legend.jsp" %>
				</div>
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
