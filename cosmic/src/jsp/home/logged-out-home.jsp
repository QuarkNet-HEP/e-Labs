<%
	response.setStatus(java.net.HttpURLConnection.HTTP_MOVED_PERM);
	response.setHeader("Location", "index.jsp");
%>