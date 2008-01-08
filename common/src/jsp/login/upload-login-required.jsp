<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%
	ElabGroup user = ElabGroup.getUser(session);
	request.setAttribute("request", request);
	if (user == null || !user.isUpload()) {
%>
			<c:choose>
				<c:when test="${request.queryString != null}">
					<jsp:include page="../login/login.jsp">
						<jsp:param name="prevPage" value="/${pageContext.servletContext.servletContextName}${request.servletPath}?${request.queryString}"/>
						<jsp:param name="message" value="You must have the upload role in order to access this page"/>
					</jsp:include>
				</c:when>
				<c:otherwise>
					<jsp:include page="../login/login.jsp">
						<jsp:param name="prevPage" value="/${pageContext.servletContext.servletContextName}${request.servletPath}"/>
						<jsp:param name="message" value="You must have the upload role in order to access this page"/>
					</jsp:include>
				</c:otherwise>
			</c:choose>
		<%
		return;
	}
	request.setAttribute("user", user);
	
%>