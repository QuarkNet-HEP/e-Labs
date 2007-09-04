<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>


<%
	String filename = request.getParameter("filename");
	if (filename == null){
	    throw new ElabJspException("Missing file name");
	}
	
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));

	String pfn = plotUser.getDir("plots") + File.separator + filename;
	String url = plotUser.getDirURL("plots") + '/' + filename;
	
	String title="", study = null, provenance = null, dvName = null;
	if (entry != null) {
	    study = (String) entry.getTupleValue("study");
		Timestamp ts = (Timestamp) entry.getTupleValue("creationdate");
		//Feb 2, 2005 20:00
		Timestamp DATE_WHEN_PROVENANCE_WAS_FIXED = new Timestamp(2005-1900, 2-1, 2, 20, 0, 0, 0);
		if (ts != null && ts.compareTo(DATE_WHEN_PROVENANCE_WAS_FIXED) > 0) {
		    provenance = (String) entry.getTupleValue("provenance");
		    if (provenance != null) {
		        provenance = plotUser.getDirURL("plots") + '/' + provenance;
		    }
		}
	}
	request.setAttribute("provenance", provenance);

	%> 
		<c:choose>
			<c:when test="${provenance != null}">
				<img src="${provenance}" alt="provenance"/>
			</c:when>
			<c:otherwise>
				<e:error message="No provenance available for ${param.filename}"/>
			</c:otherwise>
		</c:choose>
	<%
%>
