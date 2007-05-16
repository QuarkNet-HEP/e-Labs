<%@ tag body-content="tagdependent" description="Throws an ElabJspException" %>
<%@ attribute name="message" type="java.lang.String" 
	required="false" description="An exception message." %>
<%@ attribute name="cause" type="java.lang.Throwable" 
	required="false" description="A cause to chain to this exception." %>
<%@ tag import="gov.fnal.elab.ElabJspException" %>

<%
	throw new ElabJspException(message, cause);
%>