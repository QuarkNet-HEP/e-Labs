<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Posters: Search posters.</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="search-posters" class="posters">
		<!-- entire page container -->
		<div id="container">
			
			<div id="content">
				
<h1>View Posters: Search for and view posters as posters.</h1>

<table border="0" id="main">
	<tr>
		<td id="center">
		   PAPERS<BR>
		   <%@ include file="search-controlPapers.jsp" %>
		   <%@ include file="search-resultsPapers.jsp" %>
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
