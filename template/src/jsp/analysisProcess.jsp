<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.template.beans.*" %>
<%@ page import="gov.fnal.elab.vdl2.Workflow" %>
<%@ page import="gov.fnal.elab.vdl2.Workflows" %>
<%@ page import="gov.fnal.elab.vdl2.template.AnalysisWorkflows" %>

<jsp:useBean id="analysisInputFormBean" class="gov.fnal.elab.template.beans.AnalysisBean" scope="session"/>
<jsp:setProperty name="analysisInputFormBean" property="*"/>

<% 
if (session.getAttribute("login") != null ) {
	out.println("Welcome "+session.getAttribute("login"));
}else{
	//redirect to the analisys starting page
	response.sendRedirect( response.encodeRedirectURL(
                "http://" + System.getProperty("host") + System.getProperty("port") + "/elab/template"));
}
%>

<h3 align=center>Analysis Results</h3>

<%

if (!"true".equals(request.getParameter("done"))) {//before the workflow is started
	
	String message = analysisInputFormBean.getInputString();
	out.println("You will process the message "+message +" on the Grid");
	
	String fileOutput = "analysisOutputFile.txt";
	String inputString = "Heloooo";
	
	Workflow wf = AnalysisWorkflows.getDefault().newInstance("Analysis");
	wf.setAttribute("bean", analysisInputFormBean);
	
	wf.addArg("outputData", fileOutput);
	wf.addArg("inputString", inputString);
	//wf.addArg("inputString",analysisInputFormBean.getInputString());
	
	wf.register(session);
	wf.setContinuation("analysisProcess.jsp?done=true&beanName=analysisInputFormBean&workflowID="+wf.getID());
	request.setAttribute("workflowID", wf.getID());
	
	if("true".equals(request.getParameter("process"))){
%>
	<jsp:forward page="workflowStart.jsp"/>
<%
	}
} else { //workflow has ended ??
%>		
	<title>OGRE Study Analysis Results</title>	
<% 

	out.println("INTERNAL RESULT");
}
%>

