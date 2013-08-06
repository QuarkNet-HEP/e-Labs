<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>
<script>
	div#img  { width:500px;}
</script>

<%
	String filename = request.getParameter("filename");
	if (filename == null){
	    throw new ElabJspException("Missing file name");
	}
	
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));

	String pfn = plotUser.getDir("plots") + File.separator + filename;
	String url = plotUser.getDirURL("plots") + '/' + filename;
	
	String title="", study = null, svg = null, dvName = null;
	if (entry != null) {
	    svg = (String) entry.getTupleValue("svg");
		if (svg != null) {
		    svg = plotUser.getDirURL("plots") + '/' + svg;
		}
	}
	request.setAttribute("svg", svg);

	%> 
		<c:choose>
			<c:when test="${svg != null}">
                <div id="img">
                    <object height="80%" width="80%" data="${svg}" type="image/svg+xml"></object>
                </div>
			</c:when>
			<c:otherwise>
				<e:error message="No svg available for ${param.filename}"/>
			</c:otherwise>
		</c:choose>
	<%
%>
