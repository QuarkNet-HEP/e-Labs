<%@ tag description="Allows easy, but slightly inefficient display of paged things" %>
<%@ attribute name="crt" required="true" description="The current item's index" %>
<%@ attribute name="totalSize" type="java.lang.Object" required="true" description="A size or a collection whose size represents the total number of items" %>
<%@ attribute name="pageSize" required="true" description="The number of items on each page" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	String start = request.getParameter("start");
	if (null == start || "".equals(start)) {
		start = "0";
	}
	request.setAttribute("start", start);
%>

<c:if test="${crt >= start && crt <= start + pageSize}">
	<jsp:doBody/>
</c:if>