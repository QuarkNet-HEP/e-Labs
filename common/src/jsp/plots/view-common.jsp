<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- fn: taglib used to secure GET parameters from XSS attacks - JG --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
String filename = request.getParameter("filename");
if(filename == null){
	  throw new ElabJspException("Please choose a file to view");
}

CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
if (entry == null) {
		throw new ElabJspException("No entry found in the data catalog for " + filename + ".");
}
ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));

String pfn = plotUser.getDir("plots") + File.separator + filename;
String url = plotUser.getDirURL("plots") + '/' + filename;

String title="", study = null, provenance = null, dvName = null, name = null, eventCandidates = null;
if (entry != null) {
	  study = (String) entry.getTupleValue("study");
		Timestamp ts = (Timestamp) entry.getTupleValue("creationdate");
		//Mar 24, 2005 11:00
		Timestamp DATE_WHEN_DVS_WERE_FIXED = new Timestamp(2005-1900, 3-1, 24, 11, 0, 0, 0);
		if (ts != null && ts.compareTo(DATE_WHEN_DVS_WERE_FIXED) > 0) {
		    dvName = (String) entry.getTupleValue("dvname");
		}
		name = (String) entry.getTupleValue("name");
    //EPeronja-07/2/2013: Bug 320: view.jsp and view-metadata.jsp display internal file name
    String project = (String) entry.getTupleValue("project");
    if (entry != null && project.equals("ligo")) {
        if (name == null || name.equals("")){
	        	name = (String) entry.getTupleValue("title");
        }
    }		
		
}
String dt = (String) entry.getTupleValue("deltaTIDs");
request.setAttribute("name", name);
request.setAttribute("study", study);
request.setAttribute("provenance", entry.getTupleValue("provenance"));
request.setAttribute("svg", entry.getTupleValue("svg"));
//EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot
request.setAttribute("eventCandidates", entry.getTupleValue("eventCandidates"));
request.setAttribute("eventNum", entry.getTupleValue("eventNum"));
request.setAttribute("eventStart", entry.getTupleValue("eventStart"));
request.setAttribute("dvName", dvName);
request.setAttribute("url", url);
request.setAttribute("deltaTIDs", dt);
%> 
<h2>
		<c:choose>
				<c:when test="${name != null}">
						${name}
				</c:when>
				<c:otherwise>
						<c:out value="${param.filename}" />
				</c:otherwise>
		</c:choose>
</h2><br/>
<img src="${url}"/><br/>
<a href="../data/view-metadata.jsp?filename=${fn:escapeXml(param.filename)}&menu=${fn:escapeXml(param.menu)}">Show details (metadata)</a><br/>
<c:if test="${provenance != null}">
		<e:popup href="../plots/view-provenance.jsp?filename=${fn:escapeXml(param.filename)}" target="Provenance" width="800" height="850">Show provenance</e:popup><br/>
</c:if>
<!-- EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot -->
<c:if test="${eventCandidates != null }">
		<a href="../plots/view-events.jsp?filename=${fn:escapeXml(param.filename)}">Show Event Candidates</a><br/>
</c:if>
<c:if test="${svg != null }">
		<a href="../plots/view-svg.jsp?filename=${fn:escapeXml(param.filename)}">Show SVG Plot</a><br/>
</c:if>
<c:if test="${dvName != null}">
		<c:choose>
				<c:when test="${deltaTIDs != null }">
						<a href="../analysis/rerun.jsp?study=${study}&dvName=${dvName}&deltaTIDs=${deltaTIDs}">Run this study again</a><br/>
				</c:when>
				<c:otherwise>
						<a href="../analysis/rerun.jsp?study=${study}&dvName=${dvName}">Run this study again</a><br/>
				</c:otherwise>
			</c:choose>
		</c:if>
	<%
%>
