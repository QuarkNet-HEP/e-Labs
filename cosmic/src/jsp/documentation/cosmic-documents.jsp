<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="org.apache.commons.io.FileUtils" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
	try {
		TreeMap<String,String> docFiles = new TreeMap<String,String>();
		String path = getServletContext().getRealPath("/") + "cosmic/documentation/";
		java.io.File dir = new java.io.File(path);
		String[] files = dir.list();
		for (int i = 0; i < files.length; i++) {
			if (files[i].endsWith(".txt")) {
				int extensionbegin = files[i].indexOf(".txt");
				String filename = files[i].substring(0, extensionbegin);
				docFiles.put(filename, files[i]);
			}
		}
		
		request.setAttribute("docFiles",docFiles);

	} catch (Exception e) {
		System.out.println(e.getMessage());
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Documents</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="cosmic-documents" class="teacher">
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
				<h2>Documentation about cosmic processes and analyses.</h2>
				<table>
					<c:forEach items="${docFiles}" var="docFiles"> 
						<tr>
							<td><a href="view.jsp?filename=${docFiles.value }">${docFiles.key}</a></td>
						</tr>
					</c:forEach>
				</table>
			</div>
		</div>
	</body>
</html>