<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>

<%
	//DataCatalogProvider dcp = elab.getDataCatalogProvider();
	//int fileCount = dcp.getUniqueCategoryCount("split");
	//int schoolCount = dcp.getUniqueCategoryCount("school");
	//int stateCount = dcp.getUniqueCategoryCount("state");
	String fileCount = (String) session.getAttribute("cosmicFileCount");
	String schoolCount = (String) session.getAttribute("cosmicSchoolCount");
	String stateCount = (String) session.getAttribute("cosmicStateCount");
	
%>
<p>
	Searching <%= fileCount %> data files from <%= schoolCount %> schools in 
	<%= stateCount %> states.
</p>