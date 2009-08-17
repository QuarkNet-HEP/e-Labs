<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Plot</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-plot" class="data">
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
			
<table border="0" id="main">
	<tr>
		<c:if test="${param.menu != 'no'}">
			<td id="left">
				<%@ include file="../include/left-alt.jsp" %>
			</td>
		</c:if>
		<td id="center">
			<%@ include file="view-common.jsp" %>
		</td>
	</tr>
</table>

			</div>
			
			<div id="footer">
				<%@ include file="../include/nav-footer.jsp" %>
			</div>
		</div>
	</body>
</html>