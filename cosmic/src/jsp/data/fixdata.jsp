<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.query.CatalogEntry" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<html>
<head></head>
<body>
<%
	/*	STEPS TO FIX METADATA
		1. Read in the file /disks/data/splitFix/metaLog
		2. Iterate through the file, determine which we can process
			a. Files with detector IDs belonging to unique schools are go 
			b. Files with detector IDs/filenames that are pre-existing and not (a) 
			c. Files with DIDs that do not fit (a) or (b) and may be assigned to multiple schools
		3. Process files in 2A, 2B 
			a. Read the metadata file, insert by LFN [ do we need to delete first? Investigate ] 
		4. Display files in 2C - need to deal with those another way. 
	
		LOG EVERYTHING
	*/
	
	/*
	
	final String METALOG = "/disks/data/splitFix/metaLog"; 
	List<String> metaFileList = new ArrayList<String>(); 
	BufferedReader br = null; 
	
	File metaLog = new File(METALOG); 
	if (metaLog.canRead()) { 
		br = new BufferedReader(new FileReader(metaLog));
		String thisLine = null; 
		while ((thisLine = br.readLine()) != null) {
			metaFileList.add(thisLine);
		}
		br.close();
		
		for (String metaFile : metaFileList) { 
			br = new BufferedReader(new FileReader(metaFile));
			String line = null;
	        String currLFN = null;
	        String currPFN = null;
		}
	}
	
	*/
	
	CatalogEntry ce = elab.getDataCatalogProvider().getEntry("6148.2009.0403.0");
	
	if (ce != null) {
		elab.getDataCatalogProvider().delete("6148.2009.0403.0");
	}
	
%>
</body>
</html>