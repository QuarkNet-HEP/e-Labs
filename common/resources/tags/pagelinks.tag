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
	//EPeronja-08/07/2015: The paging did not work because when start and pageSize where compared below,
	//	they were compared as strings and 120 was not > than 30... lack of testing!!!
	int startIntValue = Integer.parseInt(start);
	int pageSizeIntValue = Integer.parseInt(pageSize);
	request.setAttribute("startIntValue", startIntValue);
	request.setAttribute("pageSizeIntValue", pageSizeIntValue);
%>

<c:choose>
	<c:when test="${startIntValue > 0 && startIntValue < pageSizeIntValue}">
		<a href="<%= ElabUtil.modQueryString(request, "start", 0) %>">Previous ${pageSizeIntValue} ${names}</a>
	</c:when>
	<c:when test="${startIntValue > 0 && startIntValue >= pageSizeIntValue}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plprev) %>">Previous ${pageSizeIntValue} ${names}</a>
	</c:when>
</c:choose>

<c:choose>
	<c:when test="${startIntValue + 2*pageSizeIntValue > tsz && startIntValue + pageSizeIntValue < tsz}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plnext) %>">Next ${tsz - pageSizeIntValue - startIntValue} ${names}</a>
	</c:when>
	<c:when test="${startIntValue + pageSizeIntValue < tsz}">
		<a href="<%= ElabUtil.modQueryString(request, "start", plnext) %>">Next ${pageSizeIntValue} ${names}</a>
	</c:when>
</c:choose>
