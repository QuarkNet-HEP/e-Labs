<%@ page import="java.util.*" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="gov.fnal.elab.vds.*" %>
<%@ page import="gov.fnal.elab.cms.beans.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.beans.*" %>
<%@ page import="gov.fnal.elab.vdl2.Workflow" %>
<%@ page import="gov.fnal.elab.vdl2.Workflows" %>
<%@ page import="gov.fnal.elab.vdl2.cms.CMSWorkflows" %>
<%@ include file="common.jsp" %>

<jsp:useBean id="formHandler" class="gov.fnal.elab.cms.beans.OgreBean" scope="session"/>

<jsp:setProperty name="formHandler" property="*"/>
 
<%

String cmsDataPath="/var/tmp/quarknet-m/vds";
String scriptString="";
String ogreOutputFile="";
String ogreRawFile="";

if (!"true".equals(request.getParameter("done"))) {//before the workflow is started
	String script=formHandler.invokeWorkflow();
	scriptString=script;
	String randFileName=formHandler.getTempDir()+"/Script-"+formHandler.getRandFileID()+".C";

	out.println("<h3>Resulting Root Script</h3><pre>"+script+"</pre>");

	FileWriter writer=new FileWriter(randFileName);
	writer.write(script);
	
	writer.close();
	
	ogreOutputFile="canvas-"+formHandler.getRandFileID()+"."+formHandler.getType();
	ogreRawFile="raw-data-"+formHandler.getRandFileID()+".txt";
	
	Workflow wf = CMSWorkflows.getDefault().newInstance("OGRE");
	wf.setAttribute("bean", formHandler);
	//NOTE: the outputFile name needs to be synchronized with what the OgreBean is set to produce in the invokeWorkflow process
	wf.addArg("outputFile", ogreOutputFile);
	//wf.addArg("outputFile",formHandler.getCmsDataPath()+"canvas-"+formHandler.getRandFileID()+"."+formHandler.getType());
	//wf.addArg("outputFile","/var/tmp/quarknet-m/tomcat/webapps/elab/cms/output");
	wf.addArg("rawOutData","raw-data-"+formHandler.getRandFileID()+".txt");
	wf.addArg("scriptFile",randFileName);
	wf.register(session);
	wf.setContinuation("ogreProcess.jsp?done=true&beanName=formHandler&workflowID="+wf.getID());
	request.setAttribute("workflowID", wf.getID());
	
	//out.println("scriptFile: "+randFileName);
	//out.println("outputFile: /canvas-"+formHandler.getRandFileID()+"."+formHandler.getType());
	if("true".equals(request.getParameter("process"))){
%>
<jsp:forward page="workflowStart.jsp"/>

<%
	}
} else { //workflow has ended ??
%>		
	<title>OGRE Study Analysis Results</title>

	<h2><center> WORKFLOW ENDED, load PNG file</center></h2>
<%		

	String ogreExecutionArea="/var/tmp/quarknet-m/tomcat/webapps/elab/cms/output";

	String mkdirCmd = "mkdir -p "+userArea;
	String cpOutputCmd = "cp " + "canvas-"+formHandler.getRandFileID()+"."+formHandler.getType() + " " + userArea;
	String cpRawCmd = "cp " + ogreRawFile + " " + userArea;
	
	String[] cmd1 = new String[] {"bash", "-c","cd "+ogreExecutionArea+" ; "+ mkdirCmd + " >out 2>&1"};
	String[] cmd2 = new String[] {"bash", "-c", "cd "+ogreExecutionArea+" ; "+cpOutputCmd + " >out 2>&1"};
	String[] cmd3 = new String[] {"bash", "-c", "cd "+ogreExecutionArea+" ; "+mkdirCmd + " >out 2>&1"};

    try{
	    Process p1 = Runtime.getRuntime().exec(cmd1);
	    int c1 = p1.waitFor();
	    if (c1 != 0) {
%>
        <TR><TD>Error: Failed to create user dir in the shell<TD></TR>
<%
        return;
	    }
	    Process p2 = Runtime.getRuntime().exec(cmd2);
	    int c2 = p2.waitFor();
	    if (c2 != 0) {
%>
        <TR><TD>Error: Failed to copy image file to the user's directory in the shell!<TD></TR>
<%
        return;
	    }
    }catch(IOException ioe){
    	out.println(ioe.getLocalizedMessage());	
    }	
	

	//out.print("Find the file in "+cmsDataPath+"/canvas-"+formHandler.getRandFileID()+"."+formHandler.getType());
	out.print("<p><center><img src=\"/elab/cms/output/canvas-"+formHandler.getRandFileID()+"."+formHandler.getType()+"\" ></center><p>");
	out.print(scriptString);
	
	if(formHandler.getSavedata().equalsIgnoreCase("1")){
		out.print("<center><h3>Raw Data</h3>");
		out.print("<iframe src=output/raw-data-"+formHandler.getRandFileID()+".txt width=400 height=300 ></iframe></center>");
	}
	//add close button
}
%>

<%--   save plot part --%>

<p align="center">To save this plot permanently, enter the new name you want.<br>
Then click <b>Save Plot</b>.<br>

<center>
<FORM name="SaveForm" ACTION="ogre-save.jsp"  method="post" target="saveWindow" onSubmit='return openPopup("",this.target,500,200);' align="center">
<%
    //Metadata section
    //there seems to be an unwritten rule to use lowercase for metadata...
    //pass any arguments to write as metadata in the "metadata" form variable as tuple strings
%>

	<%-- TODO fix outputDir--%>
    <input type="hidden" name="metadata" value="type string plot" >
	
	
    <input type="hidden" name="outputDir" value="/var/tmp/quarknet-m/tomcat/webapps/elab/cms/output" >
    <input type="hidden" name="pngFile" value="<%="canvas-"+formHandler.getRandFileID()+"."+formHandler.getType()%>" >
    <input type="hidden" name="pngThumb" value="<%="canvas-"+formHandler.getRandFileID()+"."+formHandler.getType()%>" >
    <input type="text" name="permanentFile"  size="20" maxlength="30">.png
    <input type="hidden" name="fileType" value="png" >
    <input name="save" type="submit" value="Save Plot">
</form>
</center>
