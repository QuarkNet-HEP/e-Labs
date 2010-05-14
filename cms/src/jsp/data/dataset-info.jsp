<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="java.util.*" %>
<%@ include file="../include/elab.jsp" %>
<% System.out.println("Dataset info " + request.getParameter("dataset")); %>
<c:choose>
	<c:when test="${empty datasets[param.dataset]}">
		<% System.out.println("Loading dataset " + request.getParameter("dataset")); %>
		<c:choose>
			<c:when test="${param.dataset == 'mc09'}">
				<c:set var="dsfile" value="mc09/data.xml"/>
			</c:when>
			<c:when test="${param.dataset == 'tb04'}">
				<c:set var="dsfile" value="tb04/data.xml"/>
			</c:when>
			<c:otherwise>
				<e:error message="Invalid dataset requested: ${param.dataset}"/>
			</c:otherwise>
		</c:choose>
		<%
			request.setAttribute("datapath", pageContext.getServletContext().getRealPath(elab.getName() + "/data"));
		%>
		<c:import var="xmldd" url="file://${datapath}/${dsfile}"/>
		<x:parse varDom="currentDataset" scopeDom="request" doc="${xmldd}"/>
		<%
			Map datasets = (Map) session.getAttribute("datasets");
			if (datasets == null) {
			    datasets = new HashMap();
			    session.setAttribute("datasets", datasets);
			}
			datasets.put(request.getParameter("dataset"), request.getAttribute("currentDataset"));
		%>
	</c:when>
	<c:otherwise>
		<%
			Map datasets = (Map) session.getAttribute("datasets");
			request.setAttribute("currentDataset", datasets.get(request.getParameter("dataset")));
		%>
	</c:otherwise>
</c:choose>
