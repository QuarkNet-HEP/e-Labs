<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" %>
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
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"/>
	</head>
	
	<body id="view-plot" class="data">
	<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
	<tr>
		<td id="center">
<%
	String filename = request.getParameter("filename");
	if(filename == null){
	    throw new ElabJspException("Please choose a file to view");
	}

	String pfn = user.getDir("plots") + File.separator + filename;
	String url = user.getDirURL("plots") + '/' + filename;
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	String title="", study = null, provenance = null, dvName = null;
	if (entry != null) {
	    study = (String) entry.getTupleValue("study");
		Timestamp ts = (Timestamp) entry.getTupleValue("creationdate");
		//Feb 2, 2005 20:00
		Timestamp DATE_WHEN_PROVENANCE_WAS_FIXED = new Timestamp(2005-1900, 2-1, 2, 20, 0, 0, 0);
		if (ts != null && ts.compareTo(DATE_WHEN_PROVENANCE_WAS_FIXED) > 0) {
		    provenance = (String) entry.getTupleValue("provenance");
		    if (provenance != null) {
		        provenance = user.getDirURL("plots") + '/' + provenance;
		    }
		}
		//Mar 24, 2005 11:00
		Timestamp DATE_WHEN_DVS_WERE_FIXED = new Timestamp(2005-1900, 3-1, 24, 11, 0, 0, 0);
		if (ts != null && ts.compareTo(DATE_WHEN_DVS_WERE_FIXED) > 0) {
		    dvName = (String) entry.getTupleValue("dvname");
		}
	}
	request.setAttribute("study", study);
	request.setAttribute("provenance", provenance);
	request.setAttribute("dvName", dvName);
	request.setAttribute("url", url);
	%> 
		<h2>${param.filename}</h2><br/>
		<img src="${url}"/><br/>
		<a href="../data/view-metadata.jsp?filename=${param.filename}">Show details (metadata)</a><br/>
		<c:if test="${provenance != null}">
			<e:popup href="${provenance}" target="Provenance" width="800" height="850">Show provenance</e:popup><br/>
		</c:if>
		<c:if test="${dvName != null}">
			<a href="../analysis/rerun.jsp?study=${study}&dvName=${dvName}">Run this study again</a><br/>
		</c:if>
	<%
%>
		</td>
	</tr>
</table>

	</body>
</html>