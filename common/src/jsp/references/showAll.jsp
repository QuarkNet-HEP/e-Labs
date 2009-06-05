<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>

<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>

<%
	String type = request.getParameter("t");
	String prefix;
	String h1Text;
	if ("reference".equals(type)) {
		prefix = "Reference";
		h1Text= "References: View the references associated with the milestones.";
	}
	else if ("glossary".equals(type)) {
		prefix = "Glossary";
		h1Text= "Glossary: Look up unfamiliar words.";
	}
	else {
		throw new ElabJspException("Unknown reference type: " + type);
	}
	
	String path = "/" + elab.getName() + "/references/";
	Collection files = application.getResourcePaths(path);
	if (files == null) {
		files = Collections.EMPTY_SET;
	}
	Map sorted = new TreeMap();
	Iterator i = files.iterator();
	while (i.hasNext()) {
		String file = (String) i.next();
		file = file.substring(path.length());
		if (file.startsWith(prefix)) {
			String name = file.substring(prefix.length() + 1);
			name = name.substring(0, name.length() - 5);
			name = name.replaceAll("_", " ");
			sorted.put(name, file);
		}
	}
	
	request.setAttribute("files", sorted);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="show-all-references" class="library">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<h1><%=h1Text%></h1>

<!-- 
<p align="center">
	<a href="../references/showAll.jsp?t=reference">View References for Study Guide</a>
	-
	<a href="../references/showAll.jsp?t=glossary">Glossary: Look up unfamiliar words.</a>
</p>
 -->

<table id="references-table" cellpadding="4" cellspacing="4">
	<c:forEach items="${files}" var="file">
		<tr>
			<td valign="top" width="20%">${file.key}</td>
			<td class="reference-text"><jsp:include page="../references/${file.value}"/></td>
		</tr>
	</c:forEach>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
