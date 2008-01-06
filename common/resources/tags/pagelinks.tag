<%@ tag description="Allows easy, but slightly inefficient display of paged things" %>
<%@ attribute name="start" required="true" type="java.lang.String" description="The current start index" %>
<%@ attribute name="totalSize" type="java.lang.Object" required="true" description="A size or a collection whose size represents the total number of items" %>
<%@ attribute name="pageSize" required="true" description="The number of items on each page" %>
<%@ attribute name="name" required="true" description="The label to use when referring to only one item" %>
<%@ attribute name="names" required="true" description="The label to use when referring to multiple items" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ tag import="gov.fnal.elab.util.*" %>
<%@ tag import="java.util.*" %>

<%
	if (null == start || "".equals(start)) {
		start = "0";
	}
	if (totalSize instanceof java.util.Collection) {
		request.setAttribute("tsz", new Integer(((java.util.Collection) totalSize).size()));
	}
	else {
		request.setAttribute("tsz", totalSize);
	}
	int plprev = Integer.parseInt(start) - Integer.parseInt(pageSize);
	int plnext = Integer.parseInt(start) + Integer.parseInt(pageSize); 
%>

<c:choose>
	<c:when test="${start > 0 && start < pageSize}">
		<a href="<%= ElabUtil.modQueryString(request, "start", 0) %>">Previous ${pageSize} ${names}</a>
	</c:when>
	<c:when test="${start >= pageSize}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plprev) %>">Previous ${pageSize} ${names}</a>
	</c:when>
</c:choose>

<c:choose>
	<c:when test="${start + 2*pageSize > tsz && start + pageSize < tsz}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plnext) %>">Next ${tsz - pageSize - start} ${names}</a>
	</c:when>
	<c:when test="${start + pageSize < tsz}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plnext) %>">Next ${pageSize} ${names}</a>
	</c:when>
</c:choose>
