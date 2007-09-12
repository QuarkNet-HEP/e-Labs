<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Detector information</title>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="detector-info" class="data">
		<!-- entire page container -->
		<div id="container">			
			<div id="content">

<%
	String id = request.getParameter("id");
	if (id == null) {
	    throw new ElabJspException("Missing ID parameter");
	}
	//relatively lousy way to do this, but it should do for now:
	//look for a data file with a specific detector id
	And and = new And();
    and.add(new Equals("project", elab.getName()));
    and.add(new Equals("type", "split"));
    and.add(new Equals("detectorid", id));
    ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
    if (rs.size() > 0) {
        CatalogEntry e = (CatalogEntry) rs.iterator().next();
        request.setAttribute("entry", e.getTupleMap());
    }
%>

<c:choose>
	<c:when test="${entry == null}">
		<div class="warning">Could not find any information about detector ${param.id}</div>
	</c:when>
	<c:otherwise>
		<h1>Information about detector ${entry.detectorid}</h1>
		<table id="detector-info-table">
			<tr>
				<td>State:</td>
				<td>${entry.state}</td>
			</tr>
			<tr>
				<td>City:</td>
				<td>${entry.city}</td>
			</tr>
			<tr>
				<td>School:</td>
				<td>${entry.school}</td>
			</tr>
		</table>
	</c:otherwise>
</c:choose>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
