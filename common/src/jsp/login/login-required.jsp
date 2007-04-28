<%@ page import="gov.fnal.elab.ElabUser" %>
<%
	ElabUser user = ElabUser.getUser(session);
	if (user == null) { 
		%>
			<jsp:include page="../login/login.jsp">
				<jsp:param name="prevPage" value="<%= request.getRequestURL() + "?" + request.getQueryString() %>"/>
				<jsp:param name="message" value="Access to this page is restricted to logged in users"/>
			</jsp:include>
		<%
		return;
	}
	request.setAttribute("user", user);
%>