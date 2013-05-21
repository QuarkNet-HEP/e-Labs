<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%
	ElabGroup user = ElabGroup.getUser(session);
	//hmm
	request.setAttribute("request", request);
	
	if (user == null) {
		%>
			<c:set var="postParams" scope="session" value="${request.parameterMap}"/>
			<c:choose>
				<c:when test="${request.queryString != null}">
					<jsp:include page="../login/login.jsp">
						<jsp:param name="prevPage" value="${elab.properties['elab.url']}/${pageContext.servletContext.servletContextName}${request.servletPath}?${request.queryString}"/>
						<jsp:param name="message" value="Access to this page is restricted to logged in users"/>
					</jsp:include>
				</c:when>
				<c:otherwise>
					<jsp:include page="../login/login.jsp">
						<jsp:param name="prevPage" value="${elab.properties['elab.url']}/${pageContext.servletContext.servletContextName}${request.servletPath}"/>
						<jsp:param name="message" value="Access to this page is restricted to logged in users"/>
					</jsp:include>
				</c:otherwise>
			</c:choose>
		<%
		return;
	}
	request.setAttribute("user", user);
%>