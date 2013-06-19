<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>

<!-- This page displays results from searches done with searchcontrol.jsp -->
<!-- Don't include it if you haven't included searchcontrol.jsp           -->

<%
	StructuredResultSetDisplayer srsd = (StructuredResultSetDisplayer) request.getAttribute("searchResultsDisplayer");
	StructuredResultSet srs = (StructuredResultSet) session.getAttribute("srs");
	String msg = (String) session.getAttribute("msg");
	if (srs != null && !srs.isEmpty()) {
    	int start, pageNo;
		try {
			start = Integer.parseInt(request.getParameter("start"));
			pageNo  = start / 10;
		}
		catch (NumberFormatException e) {
			start = 0; 
			pageNo = 0;
		}
		
		/* Get known checked values, generate a string for jQuery to parse*/
		HashMap<Integer, String[]> h = (HashMap) session.getAttribute("rawDataMap");
		if (h != null) {
			String [] ids = h.get(pageNo);
			String s = "";
			if (h.get(pageNo) != null) {
				for (int i = 0; i < ids.length; ++i) {
					s += "input[value='" + ids[i] + "']";
					if (i != ids.length - 1) {
						s += ", ";
					}
			 	}
		 	}
			
			/* Check the needed checkboxes, walk the DOM tree to find the open/close links, fire their events
			/* Something of a hack, but it appears to work ... so long as our tree doesn't change.  */
			%>
			<!-- BEGIN JQUERY VOODOO --> 
			<script type="text/javascript"> 
			$(document).ready(function() { 
				$("<%=s%>").attr('checked',true).parents().filter(function() { 
					return $(this).attr("id").substring(0, 12) == "srsdisplayer"; 
				}).parent().prev().children().children("a").click();
			}) 
			</script> 
			<!-- END JQUERY VOODOO -->
			<%
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
		    	<input type="hidden" name="start" value="<%=start%>" />
		    	<input type="submit" name="action" value="Previous Results" />
		    <%
		}
		if ((links & StructuredResultSetDisplayer.NEXT_LINK) != 0) {
		    %>
   		    	<input type="hidden" name="start" value="<%=start%>" />
		    	<input type="submit" name="action" value="Next Results" />
		    <%
		}
		%>
			</div>
		<%
	}
	else if (srs == null || srs.isEmpty()) {
		%> <h3>No results</h3> ${msg}<%
	}
	else if (request.getParameter("submit") != null) {
	    %> <h3>No results</h3> ${msg}<%
	}
	else if (request.getParameter("submit") == null) {
		// Pass to controller
		
	}
%>