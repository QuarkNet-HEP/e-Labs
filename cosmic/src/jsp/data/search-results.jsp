<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>

<!-- This page displays results from searches done with searchcontrol.jsp -->
<!-- Don't include it if you haven't included searchcontrol.jsp           -->

<%
	StructuredResultSetDisplayer srsd = (StructuredResultSetDisplayer) request.getAttribute("searchResultsDisplayer");
	StructuredResultSet srs = (StructuredResultSet) request.getAttribute("searchResultsStructured");
	if (srs != null && !srs.isEmpty()) {
	    int start = 0;
		try {
			start = Integer.parseInt(request.getParameter("start"));
		}
		catch (NumberFormatException e) {
		}
	    %>
			<p class="search-result-bar">
				Results <strong><%= start+1 %> - <%= Math.min(start + 11, srs.getSchoolCount()) %></strong> 
				of <strong><%= srs.getSchoolCount() %></strong>
				for <%= srs.getKey() %> <strong><%= srs.getValue() %></strong>
				(Searched <strong><%= srs.getDataFileCount() %></strong> files in 
				<strong><%= srs.getTime() %></strong> seconds)
			</p>
		<%
		if (srsd == null) {
		    srsd = new StructuredResultSetDisplayer();
		}
		srsd.setResults(srs);
		srsd.setStart(start);
		int links = srsd.display(out);
		%> 
			<div class="search-nav">
		<%
		if ((links & StructuredResultSetDisplayer.PREV_LINK) != 0) {
		    %>
		    	<a href="<%= ElabUtil.modQueryString(request, "start", start - 10) %>">&lt;&lt;previous results</a>
		    <%
		}
		if ((links & StructuredResultSetDisplayer.NEXT_LINK) != 0) {
		    %>
		    	<a href="<%= ElabUtil.modQueryString(request, "start", start + 10) %>">next results&gt;&gt;</a>
		    <%
		}
		%>
			</div>
		<%
	}
	else if (request.getParameter("submit") != null) {
	    %> <h3>No results</h3> <%
	}
%>