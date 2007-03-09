<%@ page import="org.griphyn.vdl.toolkit.VizDAX" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.batik.transcoder.image.PNGTranscoder" %>
<%@ page import="org.apache.batik.transcoder.TranscoderInput" %>
<%@ page import="org.apache.batik.transcoder.TranscoderOutput" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ page import="gov.fnal.elab.vdl2.Workflow" %>
<%@ page import="gov.fnal.elab.vdl2.Workflows" %>
<%@ page import="gov.fnal.elab.vdl2.cosmic.CosmicWorkflows" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common.jsp" %>

<jsp:useBean id="lifetime" scope="session" class="gov.fnal.elab.cosmic.beans.LifetimeBean" />
<jsp:useBean id="analyzingList" scope="session" class="gov.fnal.elab.cosmic.AnalyzingList" />

<%

if (!"true".equals(request.getParameter("done"))) {//before the workflow is started

	//replace new lines from any text boxes with "\n"
	String caption = lifetime.getPlot_caption();
	caption = caption.replaceAll("\r\n?", "\\\\n");
	lifetime.setPlot_caption(caption);

	ElabTransformation et = new ElabTransformation("Quarknet.Cosmic::LifetimeStudy");

	runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
	et.generateOutputDir(runDir);
	et.createDV(lifetime);

	//Setup outputDir name
	String fullOutputDir = et.getOutputDir();
	String outputDir = fullOutputDir.substring(fullOutputDir.lastIndexOf("/") + 1);

	java.util.List nulllist = et.getNullKeys();
	if(!nulllist.isEmpty()){
    	out.println("There are still keys in the Transformation which must be defined:<br>\n");
	    for(Iterator i = nulllist.iterator(); i.hasNext(); ){
    	    String ss = (String)i.next();
	        out.println("null keys: " + ss + "<br>");
    	}
	    out.println("<br><br>bailing out!");
    	return;
	}
	
	//set up the workflow
	Workflow wf = CosmicWorkflows.getDefault().newInstance("LifetimeStudy");
	//the above should be replaced by some VDC lookup
	wf.initializeFromElabTR(et);
	wf.setAttribute("bean", lifetime);
	wf.setAttribute("et", et);
	wf.register(session);
	wf.setContinuation("lifetimeOutput.jsp?done=true&beanName=lifetime&workflowID="+wf.getID());
	request.setAttribute("workflowID", wf.getID());
		
	%> <jsp:forward page="workflowStart.jsp"/> <%
}
else {
	%>
	
		<%@ include file="include/javascript.jsp" %>

		<html>
			<head>
				<title>Lifetime Study Analysis Results</title>
				<!-- header/navigation -->
				<%
					//be sure to set this before including the navbar
					String headerType = "Data";
				%>
				<%@ include file="include/navbar_common.jsp" %>
			<% //hmm. is </head> in navbar_common? %>
			<body>
	<%
	
	Workflow wf = Workflows.getWorkflow(session, request.getParameter("workflowID"));
	if (wf == null) {
		%> <h1>Invalid workflow</h1> <%
		return;
	}
	ElabTransformation et = (ElabTransformation) wf.getAttribute("et");
	
	//Setup outputDir name
	String fullOutputDir = et.getOutputDir();
	String outputDir = fullOutputDir.substring(fullOutputDir.lastIndexOf("/") + 1);

	String plotName = lifetime.getDVValue("plot_outfile_image");
	String plotURLName = runDirURL + outputDir + "/" + plotName;

	// Convert svg image to png, also create a png thumbnail image

	// We create a thumbnail and an image whose size is specified by the user.
	String pixelHeight = request.getParameter("plot_size");
	if (pixelHeight == null){
    	pixelHeight = "500";
	}
	String thumbHeight = "150";


	String pngPlotName = plotName.replaceAll(".svg", ".png");               //for metadata
	String thumbPngPlotName = plotName.replaceAll(".svg", "_thm.png");      //for metadata
	String fullSizeURL = runDirURL + outputDir + "/" + pngPlotName;         //for img src
	String fullSizePath = fullOutputDir + "/" + pngPlotName;                //for svg2png
	String thumbPath = fullOutputDir + "/" + thumbPngPlotName;              //for svg2png
	//String thumbPathURL = runDirURL + outputDir + "/" + thumbPngPlotName;   //unused

	svg2png(fullOutputDir + "/" + plotName, fullSizePath, thumbPath, pixelHeight, thumbHeight);

	%>

		<!-- TODO: remove sometime or another... -->
		<!-- fullOutputDir: <%=et.getOutputDir()%> -->

		<center>
			<img src="<%=fullSizeURL%>">
		</center>
		<p align="center">
			<a href="lifetime.jsp?plot_size=<%=pixelHeight%>&submit=Change">Change</a> your parameters.
		</p>
		<p align="center">
			<b>OR</b>
		</p>
		<p align="center">To save this plot permanently, enter the new name you want.<br>
			Then click <b>Save Plot</b>.<br>

			<center>
				<FORM name="SaveForm" ACTION="save.jsp"  method="post" target="saveWindow" onSubmit='return openPopup("",this.target,500,200);' align="center">
					<%
					    //Metadata section
					    //there seems to be an unwritten rule to use lowercase for metadata...
				    	//pass any arguments to write as metadata in the "metadata" form variable as tuple strings
				
						//set rawData variable before including common_metadata_to_save
					
						java.util.List rawDataReference = lifetime.getRawData();
						java.util.List rawData = new java.util.ArrayList(rawDataReference);
										
					%>

					<%@ include file="include/common_metadata_to_save.jsp" %>

					<input type="hidden" name="beanName" value="lifetime">
					<input type="hidden" name="metadata" value="transformation string Quarknet.Cosmic::LifeTimeStudy" >
					<input type="hidden" name="metadata" value="study string lifetime" >
					<input type="hidden" name="metadata" value="type string plot" >

				    <input type="hidden" name="metadata" value="title string <%=lifetime.getPlot_title()%>" >
				    <input type="hidden" name="metadata" value="caption string <%=lifetime.getPlot_caption()%>">

				    <input type="hidden" name="outputDir" value="<%=outputDir%>" >
				    <input type="hidden" name="pngFile" value="<%=pngPlotName%>" >
				    <input type="hidden" name="pngThumb" value="<%=thumbPngPlotName%>" >
				    <input type="text" name="permanentFile"  size="20" maxlength="30">.png
				    <input type="hidden" name="fileType" value="png" >
				    <input name="save" type="submit" value="Save Plot">
				</form>
			</center>
		</body>
	</html>
	<%
}
%>