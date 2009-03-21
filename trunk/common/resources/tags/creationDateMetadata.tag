<%@ tag body-content="scriptless" description="Produces <code>input</code> HTML 
controls with the current date (creationdate)" %>

<%@ tag import="java.util.Date" %>
<%@ tag import="java.sql.Timestamp" %>
<%@ tag import="gov.fnal.elab.datacatalog.DataTools" %>
<%@ tag import="gov.fnal.elab.util.ElabUtil" %>
<%@ tag import="gov.fnal.elab.Elab" %>

<%
	Date now = new Date();
	long millisecondsSince1970 = now.getTime();
	Timestamp timestamp = new Timestamp(millisecondsSince1970);
	String creationDate = timestamp.toString();
%>
<input type="hidden" name="metadata" value="creationdate date <%= creationDate %>"/>
