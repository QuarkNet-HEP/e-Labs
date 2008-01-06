<%@ tag body-content="tagdependent" description="Formats cosmic metadata" %>
<%@ attribute name="key" type="java.lang.String" 
	required="true" description="the metadata key to format (this determines the format)" %>
<%@ attribute name="value" type="java.lang.Object" 
	required="true" description="The value to format" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:choose>
	<c:when test="${key == 'blessed'}">
		<c:if test="${value}">
			<img border="0" alt="Blessed data" src="../graphics/star.gif"/>
		</c:if>
	</c:when>
	<c:when test="${key == 'stacked'}">
		<c:choose>
			<c:when test="${value}">
				<img border="0" alt="Stacked data" src="../graphics/stacked.gif"/>
			</c:when>
			<c:otherwise>
				<img border="0" alt="Unstacked data"  src="../graphics/unstacked.gif"/>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:when test="${key == 'startdate'}">
		<fmt:formatDate value="${value}" pattern="MMMM dd"/>
	</c:when>
	<c:when test="${key == 'enddate'}">
		<fmt:formatDate value="${value}"/>
	</c:when>
	<c:when test="${key == 'enddate'}">
		<fmt:formatDate value="${value}" pattern="MMMM dd"/>
	</c:when>
	<c:otherwise>
		${value}
	</c:otherwise>
</c:choose>
<c:forEach start="1" end="4" var="i">
	<c:if test="${fn:substring(key, 0, 4) == 'chan' && fn:substring(key, 4, 1) == i}">
		<c:choose>
			<c:when test="${value > 0}">
				<img src="../graphics/chan${i}-on.png"/>
			</c:when>
			<c:otherwise>
				<img src="../graphics/chan${i}-off.png"/>
			</c:otherwise>
		</c:choose>
	</c:if>
</c:forEach>
