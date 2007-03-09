<%@ page import="org.griphyn.vdl.toolkit.VizDAX" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ page import="gov.fnal.elab.vdl2.Workflow" %>
<%@ page import="gov.fnal.elab.vdl2.Workflows" %>
<%@ page import="gov.fnal.elab.vdl2.cosmic.CosmicWorkflows" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common.jsp" %>

<jsp:useBean id="shower" scope="session" class="gov.fnal.elab.cosmic.beans.ShowerBean" />

<%

if (!"true".equals(request.getParameter("done"))) {//before the workflow is started
	//replace new lines from any text boxes with "\n"
	String caption = shower.getPlot_caption();
	caption = caption.replaceAll("\r\n?", "\\\\n");
	shower.setPlot_caption(caption);
	
	String snen = request.getParameter("setNewEventNum");
	if(snen != null && snen.equals("1")){
    	shower.setEventNum("1");    //arbitrarily set to 1 here so the shower bean is valid. will choose a better value after analysis
	}
	
	ElabTransformation et = new ElabTransformation("Quarknet.Cosmic::ShowerStudy");

	runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
	et.generateOutputDir(runDir);
	et.createDV(shower);

	//dvName is created for passing to save.jsp
	String fullOutputDir = et.getOutputDir();
	String outputDir = fullOutputDir.substring(fullOutputDir.lastIndexOf("/") + 1);
	//String dvName = groupName + "-" + outputDir;
	//et.setDVName(dvName);

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

	Workflow wf = CosmicWorkflows.getDefault().newInstance("ShowerStudy");
	//the above should be replaced by some VDC lookup
	wf.initializeFromElabTR(et);
	wf.setAttribute("bean", shower);
	wf.setAttribute("et", et);
	wf.register(session);
	wf.setContinuation("showerOutput.jsp?done=true&beanName=shower&workflowID="+wf.getID()+"&setNewEventNum="+snen);
	request.setAttribute("workflowID", wf.getID());
		
	%> <jsp:forward page="workflowStart.jsp"/> <%
}
else{
	
	Workflow wf = Workflows.getWorkflow(session, request.getParameter("workflowID"));
	if (wf == null) {
		%> <h1>Invalid workflow</h1> <%
		return;
	}
	ElabTransformation et = (ElabTransformation) wf.getAttribute("et");

	//Setup outputDir name
	String fullOutputDir = et.getOutputDir();
	String outputDir = fullOutputDir.substring(fullOutputDir.lastIndexOf("/") + 1);

	
	String eventNum = null;
	
	String snen = request.getParameter("setNewEventNum");
	//if we need to set a new eventNum
	if("1".equals(snen)){
		
		//find the "most interesting" event (one with highest event coincidence)
	    String eventCandidates = et.getDVValue("eventCandidates");
    	runDir = runDir.substring(0, runDir.length()-1);    //FIXME: runDir has a trailing / on it
	    File ecFile = new File(fullOutputDir, eventCandidates);
    	BufferedReader br = new BufferedReader(new FileReader(ecFile));

	    String str = null;
    	while((str = br.readLine()) != null){
        	
			if(str.matches("^.*#.*")){
            	continue;   //ignore comments in the file
        	}
        	
			String arr[] = str.split("\\s");
	        eventNum = arr[0];
    	    break;
    	}
	}
	else{
    	eventNum = shower.getEventNum();
	}
	
	String pixelHeight = request.getParameter("plot_size");
	if (pixelHeight == null){
    	pixelHeight = "500";
	}

	//parameter creation for next page link
	StringBuffer sb = new StringBuffer();
	sb.append("outputDir="); 
	sb.append(outputDir);
	sb.append("&eventCandidates=");
	sb.append(et.getDVValue("eventCandidates"));
	sb.append("&eventNum=");
	sb.append(eventNum);
	sb.append("&eventStart=1");
	sb.append("&plot_size=");
	sb.append(pixelHeight);
	sb.append("&groupStart=1");
	
	String params = sb.toString();
	
	pageContext.forward("showerPlot.jsp?" + params);
}
%>