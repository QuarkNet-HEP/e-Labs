<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>

<% 
	//create the file for the dynamic charts
	String message = "";
	String fluxJsonFile = results.getOutputDir() + "/FluxBlessRange";
	File[] pfns = null;
	String[] filenames = null;
	try {
		//this code is for admin to be able to see the graph
		File f = new File(fluxJsonFile);
		if (!f.exists()) {
			String userParam = (String) request.getParameter("user");
			if (userParam == null) {
				userParam = (String) session.getAttribute("userParam");
			}
			session.setAttribute("userParam", userParam);
			ElabGroup auser = user;
			if (userParam != null) {
			    if (!user.isAdmin()) {
			    	throw new ElabJspException("You must be logged in as an administrator" 
			        	+ "to see the status of other users' analyses");
			    }
			    else {
			        auser = elab.getUserManagementProvider().getGroup(userParam);
			    }
			}
			ArrayList fileArray = (ArrayList) results.getAttribute("inputfiles");
			Collections.sort(fileArray);
		
			if (fileArray != null) {
				pfns = new File[fileArray.size()];
				filenames = new String[fileArray.size()];
				for (int i = 0; i < fileArray.size(); i++) {
					if (!fileArray.get(i).equals("[]") && !fileArray.get(i).equals("")) {
						String temp = (String) fileArray.get(i);				
						String cleanname = temp.replace(" ","");
						String pfn = RawDataFileResolver.getDefault().resolve(elab, cleanname) + ".bless";
						pfns[i] = new File(pfn);
						filenames[i] = cleanname;
					}
				}			
				if (pfns.length > 0) {
					BlessDataRange bdr = new BlessDataRange(elab,pfns,filenames,results.getOutputDir());
					//BlessDataRange bdr = new BessDataRange(elab, pfns, filenames, results.getOutputDir());	
				}
			}
		}
	} catch (Exception e) {
			message = e.getMessage();
	}
	
	//create the file for the dynamic charts
	String fluxPlotJsonFile = results.getOutputDir() + "/FluxPlotFlot";
	try {
		//this code is for admin to be able to see the graph
		File f = new File(fluxPlotJsonFile);
		if (!f.exists()) {
			   String fileName = results.getOutputDir()+"/sort.out";
			   File file = new File(fileName);
		       String binValue = results.getAnalysis().getParameter("flux_binWidth").toString();
		       Double bV = Double.valueOf(binValue);
		       if (bV <= 0) {
		    	   message = "Please enter a positive number for the bin width.";
		       } else {
			       FluxPlotDataStream fpds = new FluxPlotDataStream(elab, file, bV, results.getOutputDir(),pfns,filenames);
		       }
		}
	} catch (Exception e) {
			message = e.getMessage();
	}	
	
	request.setAttribute("message", message);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Flux Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="flux-study-output" class="data, analysis-output" onload="populateInputs()">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<div class="toolbox" align="center">
	<h3>Toolbox</h3>
	<hr />
	<div class="info">
		Run time:<br />
			<div class="indented">${results.formattedEstimatedRunTime} (est.)</div>
			<div class="indented">${results.formattedRunTime} (actual)</div>
	</div> 
	<hr />
<% if (!user.isGuest()) { %>
	<form name="SaveForm" action="../analysis/save.jsp"  method="post" target="saveWindow" onsubmit="window.open('',this.target,'width=500,height=200,resizable=1');" align="center" class="framed">
		<e:commonMetadataToSave rawData="${results.analysis.parameters['rawData']}"/>
		<e:creationDateMetadata/>
		<input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::FluxStudy"/>
		<input type="hidden" name="metadata" value="study string flux"/>
		<input type="hidden" name="metadata" value="type string plot"/>

		<input type="hidden" name="metadata" value="title string ${results.analysis.parameters['plot_title']}"/>
		<input type="hidden" name="metadata" value="caption string ${results.analysis.parameters['plot_caption']}"/>

		<input type="hidden" name="srcFile" value="plot.png"/>
		<input type="hidden" name="srcThumb" value="plot_thm.png"/>
		<input type="hidden" name="srcSvg" value="plot.svg"/>
		<input type="hidden" name="srcFileType" value="png"/>
		<input type="hidden" name="id" value="${results.id}"/>
		<input type="text" name="name" size="20" maxlength="30" placeholder="Type plot name here" 
			onfocus = "if (this.getAttribute('placeholder') == this.value) {this.value = ''; this.style.color = 'black';}"/>
		<a class="button" href="javascript: document.SaveForm.submit()">Save Plot</a>
	</form>
	<hr />
<% } %>
	<e:rerun type="flux" id="${results.id}" label="Change parameters" cclass="button"/>
	<e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true" cclass="button">Analysis directory...</e:popup>
</div>
<p>
	<a href="../analysis-blessing/bless-plots-range.jsp?id=${results.id }">View blessing plots</a>
</p>

<p>
	<a href="flux-plot.jsp?id=${results.id }&message=${message}">View interactive Flux plots</a> (Beta Version)<br />
</p>
<p>
	<img src="${results.outputDirURL}/plot.png"/>
</p>
			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
