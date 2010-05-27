<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
		<title>Details (Metadata) for ${param.filename}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-metadata" class="data">
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
		<td id="center">
			<% 
				String filename = request.getParameter("filename");
				if (filename == null) {
				    throw new ElabJspException("Missing file name.");
				}
				CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
				if (entry == null) {
				    throw new ElabJspException("No metadata about " + filename + " found.");
				}
				request.setAttribute("e", entry);
			%>
			
			<c:if test="${e.tupleMap.type == 'plot'}">
				<a href="../plots/view.jsp?filename=${param.filename}&menu=${param.menu}">Show Plot</a>
			</c:if>
			<c:if test="${e.tupleMap.type == 'split'}">
				| <a href="../data/view.jsp?filename=${param.filename}&menu=${param.menu}">Show Data</a>
			</c:if>
			<c:if test="${e.tupleMap.detectorid != null && e.tupleMap.julianstartdate != null}">
				| <a href="../geometry/view.jsp?filename=${param.filename}&menu=${param.menu}">Show Geometry</a>
			</c:if>
			<c:if test="${e.tupleMap.type == 'split'}">
				| <a href="../data/download?filename=${param.filename}&elab=${elab.name}&type=${e.tupleMap.type}">Download</a>
			</c:if>
			<h2>Details (<a href="javascript:glossary('metadata')">Metadata</a>) for ${param.filename}</h2>
			<table border="0">
				<c:forEach items="${e.tupleIterator}" var="tuple">
					<tr>
						<c:if test="${!fn:startsWith(tuple.key, '_')}">
							<td align="right">${tuple.key}:&nbsp;</td>
							<td align="left">
								<c:choose>
									<c:when test="${fn:endsWith(tuple.key, 'URL')}">
										<e:popup href="${tuple.value}" target="ViewURL" width="800" height="850">view</e:popup>
									</c:when>
									<c:when test="${tuple.key == 'provenance'}">
										<e:popup href="../plots/view-provenance.jsp?filename=${param.filename}" target="Provenance" width="800" height="850">${tuple.value}</e:popup>
									</c:when>
									<c:when test="${tuple.key == 'detectorid' && e.tupleMap.julianstartdate != null}">
										<c:forEach items="${fn:split(tuple.value, ' ')}" var="f">
											<a href="../geometry/view.jsp?detectorID=${f}&jd=${e.tupleMap.julianstartdate}">${f}</a>
										</c:forEach>
									</c:when>
									<c:when test="${tuple.key == 'source'}">
										<c:forEach items="${fn:split(tuple.value, ' ')}" var="f">
											<a href="../data/view.jsp?filename=${f}">${f}</a>
										</c:forEach>
									</c:when>
									<c:otherwise>
										${tuple.value}
									</c:otherwise>
								</c:choose>
							</td>
						</c:if>
					</tr>
				</c:forEach>
			</table>
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
