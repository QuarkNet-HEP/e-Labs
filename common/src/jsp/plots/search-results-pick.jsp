<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.util.*" %>

<script language='javascript'>
<!--
function Send(url, link)
{
    var count = parseInt(opener.document.log.count.value);
    opener.document.log.log_text.value += "(--Image " + count + "--)";
    opener.document.log.count.value = (count + 1)+"";
    opener.document.log.img_src.value += "<a href='" + link + "' target='_blank'>";
    opener.document.log.img_src.value += "<IMG height='100' width='100' SRC='";
    opener.document.log.img_src.value += url;
    opener.document.log.img_src.value += "' border=0></a>,";
    self.close();
    opener.focus();
    return false;
};
// -->
</script>   

<%
	ResultSet rs = (ResultSet) request.getAttribute("searchResults");
	if (rs != null && !rs.isEmpty()) {
	    out.write("<table id=\"plots\">\n");
	    Iterator i = rs.iterator();
	    while (i.hasNext()) {
	        out.write("<tr>\n");
	        for (int c = 0; c < 4 && i.hasNext(); c++) {
	            CatalogEntry e = (CatalogEntry) i.next();
	            request.setAttribute("e", e);
	            ElabGroup posterUser = elab.getUserManagementProvider().getGroup((String) e.getTupleValue("group"));
				String plotURL = posterUser.getDirURL("plots") + '/';
	            request.setAttribute("pfn", plotURL + e.getLFN());
	            %>
	            	<td class="plot-thumbnail">
	            		<a href="#" onClick="return Send('${pfn}', '../plots/view.jsp?filename=${e.LFN}');">
		            		<img src="<%= user.getDirURL("plots") + "/" + e.getTupleValue("thumbnail") %>" width="150" height="150"/><br/>
		            	</a>
		            	${e.tupleMap.name}<br/>
	            		Group: ${e.tupleMap.group}<br/>
	            		Created: ${e.tupleMap.creationdate}<br/>
	            		<a href="../jsp/add-comments.jsp?fileName=${e.LFN}&t=plot">View/Add Comments</a><br/>
	            	</td>
	            <%
	        }
			out.write("</tr>\n");
	    }
	    out.write("</table>\n");
	}
	else {
	    out.write("<h3>No results found</h3>");
	}
%>