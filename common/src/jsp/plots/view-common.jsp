<%
	String filename = request.getParameter("filename");
	if(filename == null){
	    throw new ElabJspException("Please choose a file to view");
	}
	
	CatalogEntry entry = elab.getDataCatalogProvider().getEntry(filename);
	ElabGroup plotUser = elab.getUserManagementProvider().getGroup((String) entry.getTupleValue("group"));

	String pfn = plotUser.getDir("plots") + File.separator + filename;
	String url = plotUser.getDirURL("plots") + '/' + filename;
	
	String title="", study = null, provenance = null, dvName = null;
	if (entry != null) {
	    study = (String) entry.getTupleValue("study");
		Timestamp ts = (Timestamp) entry.getTupleValue("creationdate");
		//Mar 24, 2005 11:00
		Timestamp DATE_WHEN_DVS_WERE_FIXED = new Timestamp(2005-1900, 3-1, 24, 11, 0, 0, 0);
		if (ts != null && ts.compareTo(DATE_WHEN_DVS_WERE_FIXED) > 0) {
		    dvName = (String) entry.getTupleValue("dvname");
		}
				
	}
	request.setAttribute("study", study);
	request.setAttribute("provenance", entry.getTupleValue("provenance"));
	request.setAttribute("dvName", dvName);
	request.setAttribute("url", url);
	%> 
		<h2>${param.filename}</h2><br/>
		<img src="${url}"/><br/>
		<a href="../data/view-metadata.jsp?filename=${param.filename}">Show details (metadata)</a><br/>
		<c:if test="${provenance != null}">
			<e:popup href="../plots/view-provenance.jsp?filename=${param.filename}" target="Provenance" width="800" height="850">Show provenance</e:popup><br/>
		</c:if>
		<c:if test="${dvName != null}">
			<a href="../analysis/rerun.jsp?study=${study}&dvName=${dvName}">Run this study again</a><br/>
		</c:if>
	<%
%>
