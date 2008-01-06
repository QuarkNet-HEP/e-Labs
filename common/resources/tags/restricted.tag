<%@ tag body-content="tagdependent" description="Restricts access to the contents of the tag to a specified role" %>
<%@ attribute name="role" type="java.lang.String" 
	required="true" description="The role to restrict to (can be user, upload, teacher, or admin)" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ tag import="gov.fnal.elab.*" %>

<%
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	if (user != null && user.isA(role)) {
%>
	<jsp:doBody/>
<%
	}
%>