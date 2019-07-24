<%@ include file="../include/elab.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.lang.*" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
TreeMap<String,String> links = new TreeMap<String,String>();
try {

	
	String dataDir = elab.getProperties().getDataDir();
	File gpsDir = new File(dataDir + "/gps");
	File[] list = gpsDir.listFiles();
	for (int i = 0; i < list.length; i++) {
		String linkString = list[i].toString();
		String linkName = linkString.substring(linkString.lastIndexOf("/")+1, linkString.length() );
		String linkKey = linkName.substring(0, linkName.lastIndexOf("."));
		links.put(linkKey,linkName);
	}
} catch (Exception ex) {
	
}
request.setAttribute("links", links);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>GPS Roll Over Note v3</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="gps" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				
<h1>GPS Roll Over Note v3</h1>
<c:if test="${not empty links}">
	<table border="0" id="main">
		<tr><th>Download instructions to fix the incorrect date produced by GPS hardware</th></tr>
		<c:forEach items="${links }" var="links">
			<tr>
				<td>
					<ul>
						<li><a href="../data/download?filename=${fn:escapeXml(links.value) }&elab=${fn:escapeXml(elab.name)}&type=gps">${fn:escapeXml(links.key) }</a></li>
					</ul>
				</td>
			</tr>
		</c:forEach>
	</table>
</c:if>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
