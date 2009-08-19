<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<%
	List l = new ArrayList();
	Enumeration e = request.getParameterNames();
	while (e.hasMoreElements()) {
	    String name = (String) e.nextElement();
	    if (name.startsWith("remove-")) {
	        l.add(name.substring("remove-".length()));
	    }
	}
	
	if ("Remove".equals(request.getParameter("confirm"))) {
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		Iterator i = l.iterator();
		while (i.hasNext()) {
		    String name = (String) i.next();
		    dcp.delete(name);
		}
		request.setAttribute("deleted", new Integer(l.size()));
	}
	else if ("Keep".equals(request.getParameter("confirm"))) {
	    request.setAttribute("deleted", new Integer(-1));
	}
	else {
	    request.setAttribute("deleted", null);
	}
	request.setAttribute("l", l);
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Remove Confirmation</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
	
<c:choose>
	<c:when test="${deleted == -1}">	
		<h1>Delete canceled</h1>
		<p>Go back to the <a href="../data/check-missing.jsp">missing files page</a></p>
	</c:when>
	
	<c:when test="${deleted != null}">
		<h1>${deleted} files deleted</h1>
		<p>Go back to the <a href="../data/check-missing.jsp">missing files page</a></p>
	</c:when>

	<c:otherwise>
			
		<h1>Confirmation needed</h1>
		
		<p>This operation cannot be undone!</p>
		<p>Are you sure you want to remove the following entries?</p>
		<form method="POST" action="../data/remove-entries.jsp">
			<ol>
				<c:forEach items="${l}" var="i">
					<li>
						${i}
						<input type="hidden" name="remove-${i}" value="true" />
					</li>
				</c:forEach>
			</ol>
		
			<input type="submit" name="confirm" value="Keep" />
			<input type="submit" name="confirm" value="Remove" />
		</form>

	</c:otherwise>
</c:choose>

		 	</div>
		</div>
	</body>
</html>