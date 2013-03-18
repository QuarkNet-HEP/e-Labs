<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Saving Plot...</title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
		<table width="100%" cellpadding="0" cellspacing="0" align="center">
			<%
					String id = request.getParameter("id");
					if (id == null) {
					    throw new ElabJspException("Missing run id parameter");
					}
					AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, id);
					if (run == null) {
					    throw new ElabJspException("Invalid analysis id: " + id);
					}
					String rundirid = request.getParameter("rundirid");
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
					String srcFile = new File(request.getParameter("srcFile")).getName();
					//original thumbnail file to copy
					String srcThumb  = new File(request.getParameter("srcThumb")).getName();
					//filename from user input
					String userFilename = request.getParameter("name");
					//file extension
					String srcFileType = request.getParameter("srcFileType");
					String outputDir = run2.getOutputDir();
					//EPeronja-03/15/2013: Bug466- Retrieve parameters to save event candidates with plot
					String eventNum = request.getParameter("eventNum");
					String eventStart = "1";
                    String srcEcFile = request.getParameter("eventCandidates");
                    String ecDir = request.getParameter("eventDir");
                    if (!ecDir.equals("")) {
                    	ecDir = ecDir.substring(0, ecDir.indexOf("eventCandidates"));
                    }
					if ( userFilename == null || userFilename.equals("") ) {
					    throw new ElabJspException("You forgot to specify the name of your file. Please close this window and enter it.");
					}
					
				    //generate a unique filename to save as (savedimage-group-date.extension format)
				    //NOTE: this timestamp is also used for the Derivation name
				    GregorianCalendar gc = new GregorianCalendar();
				    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
				    String date = sdf.format(gc.getTime());
				
				    String dstFile = "savedimage-" + groupName + "-" + date + "." + srcFileType;
				    String dstThumb = "savedimage-" + groupName + "-" + date + "_thm." + srcFileType;
				    String provenanceFile = "savedimage-" + groupName + "-" + date + "_provenance." + srcFileType;
                    String dstEcFile = "";
				    if (!ecDir.equals("")) {
						dstEcFile = "savedevents-" + groupName + "-" + date;
                    }			    
				    File f = new File(plotDir, dstFile);
				    if (f.exists()) {
				        throw new ElabJspException("Error: A unix file by that name already exists. (this should never happen)." + 
				                "Please contact the administrator with this text: Unix file exists when trying to save plot: " + 
				                f.getAbsolutePath());
				    }
				
					ElabUtil.copyFile(outputDir, srcFile, plotDir, dstFile);
					ElabUtil.copyFile(outputDir, srcThumb, plotDir, dstThumb);
					//EPeronja-03/15/2013: Bug466- Save Event Candidates files with plot
                    if (!ecDir.equals("")) {
						ElabUtil.copyFile(ecDir, srcEcFile, plotDir, dstEcFile);
                    }				
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
					AnalysisCatalogProvider acp = elab.getAnalysisCatalogProvider();
					DataCatalogProvider dcp = elab.getDataCatalogProvider();
					//TODO have a namespace
					acp.insertAnalysis(newDVName, analysis);
					
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
					//EPeronja-03/15/2013: Bug466- Add metadata
                    if (!ecDir.equals("")) {
						meta.add("eventCandidates string " + dstEcFile);
						meta.add("ecDir string " + plotDir);
                    }
					meta.add("dvname string " + newDVName);
					
					//additional metadata should be passed in the metadata parameter (of course this can have multiple values)
					String[] metadata = request.getParameterValues("metadata");
					meta.addAll(Arrays.asList(metadata));

					dcp.insert(DataTools.buildCatalogEntry(dstFile, meta));
			%>
	            	<p>You saved your plot permanently as file <%= userFilename %> 
	            	<!--filesystem name: <%= plotDir + dstFile %> --></p>
	            <%
			%>
		</table>
			
		<a href=# onclick="window.close()">Close</A>
	</body>
</html>
