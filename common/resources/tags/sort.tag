<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ tag body-content="scriptless" description="Generates a sort column link" %>
<%@ attribute name="key" required="true" description="The metadata key to be used for sorting." %>
<%@ tag import="gov.fnal.elab.util.*" %>
<c:choose>
	<c:when test="${param.desc != 'true' && param.order == key}">
		<a href="<%= ElabUtil.modQueryString(request, "desc", "true") %>"><span class="current-sort-column"><jsp:doBody/></span></a>
	</c:when>
	<c:when test="${param.order == key}">
		<a href="<%= ElabUtil.modQueryString(request, "desc", "false") %>"><span class="current-sort-column"><jsp:doBody/></span></a>
	</c:when>
	<c:otherwise>
		<a href="<%= ElabUtil.modQueryString(request, "order", key) %>"><jsp:doBody/></a>
	</c:otherwise>
</c:choose>