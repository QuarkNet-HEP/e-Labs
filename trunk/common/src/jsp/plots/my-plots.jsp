<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<jsp:include page="../plots/search.jsp">
	<jsp:param name="key" value="group"/>
	<jsp:param name="value" value="${user.name}"/>
	<jsp:param name="uploaded" value="true"/>
	<jsp:param name="submit" value="Search Data"/>
</jsp:include>