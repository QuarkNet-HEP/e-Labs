<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Study - Save All Events</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-study-save-all" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
		<p>Saving all events... hold on...</p>
<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	
	String showerId = request.getParameter("showerId");
	AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
	request.setAttribute("showerResults", showerResults);
	System.out.println("About to start looping through events \n");
	for (int i=0; i < showerResults.length; i++) {
		AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, showerResults[i].id);
		if (run == null) {
		    throw new ElabJspException("Invalid analysis id: " + showerResults[i].id);
		}

		String rundirid = results.id;
		AnalysisRun run2;
		if (rundirid == null) {
			run2 = run;
		}
		else {
			//allow distinction between what analysis is saved and 
			//what run produced the plot to accomodate multi-run
			//analyses (like cosmic shower)
			run2 = AnalysisManager.getAnalysisRun(elab, user, rundirid);
		}
		String groupName = user.getGroup().getName();
		String plotDir = user.getDir("plots");
		//Original file to copy. Avoid the ability to point to arbitrary files
		//String srcFile = new File(request.getParameter("srcFile")).getName();
		String srcFile = "plot.png";
		//original thumbnail file to copy
		//String srcThumb  = new File(request.getParameter("srcThumb")).getName();
		String srcThumb = "plot_thm.png";
		//filename from user input
	    //generate a unique filename to save as (savedimage-group-date.extension format)
	    //NOTE: this timestamp is also used for the Derivation name
	    GregorianCalendar gc = new GregorianCalendar();
	    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
	    String date = sdf.format(gc.getTime());
	    
		//String userFilename = request.getParameter("name");
		String userFilename = "AllEvents_"+ groupName + "_" + date + "_" + String.valueOf(i);
		//file extension
		//String srcFileType = request.getParameter("srcFileType");
		String srcFileType = "png";
		String outputDir = run2.getOutputDir();
		
	
	    String dstFile = "savedimage-" + groupName + "-" + date + "." + srcFileType;
	    String dstThumb = "savedimage-" + groupName + "-" + date + "_thm." + srcFileType;
	    String provenanceFile = "savedimage-" + groupName + "-" + date + "_provenance." + srcFileType;
		
	    File f = new File(plotDir, dstFile);
	    if (f.exists()) {
	        throw new ElabJspException("Error: A unix file by that name already exists. (this should never happen)." + 
	                "Please contact the administrator with this text: Unix file exists when trying to save plot: " + 
	                f.getAbsolutePath());
	    }
	
		ElabUtil.copyFile(outputDir, srcFile, plotDir, dstFile);
		ElabUtil.copyFile(outputDir, srcThumb, plotDir, dstThumb);
		                
        //copy the provenance image to the user's plot directory
        String provenanceDir = run.getOutputDir();
		
        // Transform the provenance information stored by doAnalysis_TR_call.jsp.
        // Start by making the SVG image using dot.
		        
        String dotCmd = elab.getProperties().getProperty("dot.location", "/usr/bin/dot") + 
	            " -Tsvg -o \"" + provenanceDir + "/dv.svg\" \"" + provenanceDir + "/dv.dot\"";
        ElabUtil.runCommand(elab, dotCmd);
        ElabUtil.SVG2PNG(provenanceDir + File.separator + "dv.svg", plotDir + File.separator + provenanceFile);
		            
		//use previously computed timestamp to create a Derivation name
		String newDVName = groupName + "-" + sdf.format(gc.getTime());
		
		//save Derivation used to create this plot
		ElabAnalysis analysis = run.getAnalysis();
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		//TODO have a namespace
		dcp.insertAnalysis(newDVName, analysis);
		
		// *** Metadata section ***
		ArrayList meta = new ArrayList();
		ElabGroup group = user.getGroup();
		
		// Default metadata for all files saved
		meta.add("city string " + group.getCity());
		meta.add("group string " + group.getName());
		meta.add("name string " + userFilename);
		meta.add("project string " + elab.getName());
		meta.add("school string " + group.getSchool());
		meta.add("state string " + group.getState());
		meta.add("teacher string " + group.getTeacher());
		meta.add("year string " + group.getYear());
		meta.add("provenance string " + provenanceFile);
		meta.add("thumbnail string " + dstThumb);
		
		meta.add("dvname string " + newDVName);
		
		//additional metadata should be passed in the metadata parameter (of course this can have multiple values)
		String[] metadata = request.getParameterValues("metadata");
		meta.addAll(Arrays.asList(metadata));

		dcp.insert(DataTools.buildCatalogEntry(dstFile, meta));
	}

%>
		<p>All events saved</p>
		</div>
		<!-- end container -->
	</body>
</html>