<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>

<%
	ResultSet rs = (ResultSet) request.getAttribute("searchResults");
	if (rs != null) {
	    out.write("<table id=\"plots\">\n");
	    Iterator i = rs.iterator();
	    while (i.hasNext()) {
	        out.write("<tr>\n");
	        for (int c = 0; c < 4 && i.hasNext(); c++) {
	            CatalogEntry e = (CatalogEntry) i.next();
	            %>
	            	<td class="plot-thumbnail">
	            		<a href="view.jsp?filename=<%= e.getLFN() %>">
		            		<img src="<%= user.getDirURL("plots") + "/" + e.getTupleValue("thumbnail") %>"/><br/>
		            	</a>
	            		<%= e.getTupleValue("name") %><br/>
	            		Group: <%= e.getTupleValue("group") %><br/>
	            		Created: <%= e.getTupleValue("creationdate") %><br/>
	            		<a href="">View/Add Comments</a><br/>
	            	</td>
	            <%
	        }
			out.write("</tr>\n");
	    }
	    out.write("</table>\n");
	}
%>