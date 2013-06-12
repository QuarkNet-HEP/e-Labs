<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.codec.net.URLCodec" %>

<%
	ResultSet rs = (ResultSet) request.getAttribute("searchResults");
	String message = (String) request.getParameter("msg");
	if (rs != null && !rs.isEmpty()) {
	    out.write("<table id=\"plots\">\n");
	    Map groups = new HashMap();
	    Iterator i = rs.iterator();
	    while (i.hasNext()) {
	        out.write("<tr>\n");
	        for (int c = 0; c < 4 && i.hasNext(); c++) {
	            CatalogEntry e = (CatalogEntry) i.next();
	            String groupName = (String) e.getTupleValue("group");
	            ElabGroup group = (ElabGroup) groups.get(groupName);
	            if (group == null) {
	            	try {
	            		group = elab.getUserManagementProvider().getGroup(groupName);
	            		groups.put(groupName, group);
	            	}
	            	catch (ElabException ex) {
	            	}
	            }
	            
	            URLCodec urlCodec = new URLCodec(); 
	            
	            String fileName = urlCodec.encode(e.getLFN()); 
	            request.setAttribute("f", fileName);
	            request.setAttribute("e", e);
	            if (group != null) {
	            	String plotURL = group.getDirURL("plots");
	            	request.setAttribute("plotURL", plotURL);
	            }
	            %>
	            	<td class="plot-thumbnail">
	            		<a href="view.jsp?filename=${f}">
	            			<c:choose>
	            				<c:when test="${!empty e.tupleMap.thumbnailURL}">
		            				<img class="plot-thumbnail-image" src="${e.tupleMap.thumbnailURL}" alt="Thumbnail not found" /><br/>
		            			</c:when>
		            			<c:otherwise>
		            				<img class="plot-thumbnail-image" src="${plotURL}/${e.tupleMap.thumbnail}" alt="Thumbnail not found" /><br/>
		            			</c:otherwise>
		            		</c:choose>
		            	</a>
		            	${e.tupleMap.name}<br/>
	            		Group: ${e.tupleMap.group}<br/>
	            		Created: ${e.tupleMap.creationdate}<br/>
	            		<a href="../jsp/add-comments.jsp?fileName=${f}&t=plot">View/Add Comments</a><br/>
	            	</td>
	            <%
	        }
			out.write("</tr>\n");
	    }
	    out.write("</table>\n");
	}
	else {
	    out.write("<h3>No results found</h3> " + message);
	}
%>