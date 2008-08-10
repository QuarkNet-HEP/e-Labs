<%@ tag body-content="scriptless" description="Produces <code>input</code> HTML 
controls with common metadata parameters for the specified raw data. The metadata 
keys currently handled by this tag are: creationdate, source, detector, rawdate" %>
<%@ attribute name="rawData" required="true" type="java.lang.Object" description="
A set of logical file names for which to produce the metadata" %>

<%@ tag import="java.util.Date" %>
<%@ tag import="java.util.Collection" %>
<%@ tag import="java.util.Collections" %>
<%@ tag import="java.sql.Timestamp" %>
<%@ tag import="gov.fnal.elab.datacatalog.DataTools" %>
<%@ tag import="gov.fnal.elab.util.ElabUtil" %>
<%@ tag import="gov.fnal.elab.Elab" %>

<%
	Elab _elab = (Elab) request.getAttribute("elab");
	//common metadata:
	Collection rd;
	if (rawData instanceof Collection) {
		rd = (Collection) rawData;
	}
	else {
		rd = Collections.singletonList(String.valueOf(rawData));
	}
	String sources = ElabUtil.join(rd, " ");
	String detectorIDs = ElabUtil.join(
	        DataTools.getUniqueValues(_elab, rd, "detectorid"), " ");
	Collection dates = DataTools.getUniqueValues(_elab, rd, "startdate");
	String rawDate;
	if (dates.size() > 0) {
	    rawDate = dates.iterator().next().toString();
	}
	else {
	    rawDate = "N/A";
	}
%>
<creationDataMetadata/>
<input type="hidden" name="metadata" value="source string <%= sources %>"/>
<input type="hidden" name="metadata" value="detectorid string <%= detectorIDs %>"/>
<input type="hidden" name="metadata" value="rawdate date <%= rawDate %>"/>
