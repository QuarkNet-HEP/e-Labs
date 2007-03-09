
<jsp:useBean id="formHandler" class="gov.fnal.elab.template.beans.AnalysisBean" scope="session"/>

<%
// We are using a session to connect the input with the output of the Workflow
// At this point we are only making sure that there is a session set at the next page
if (session.getAttribute("login") != null ) {
	out.println("Welcome "+session.getAttribute("login"));
}else{
	out.println("Setting session cookie");
	session.setAttribute("login","guest");
	session.setAttribute("appName", "template");
	session.setAttribute("userDir", "output");
	
}

%>

<h3 align=center>Hello to the Template elab's  Analysis Input page</h3>

<form method="POST" name="processInput"  action="analysisProcess.jsp?process=true">
<center>
Input your message to be analyzed by the Grid: 
<br><input type=text name=inputString>
<br><input type=submit value="run Analysis">
</center>
</form>

