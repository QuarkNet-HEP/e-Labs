<%@ page language="java" import="java.util.*,gov.fnal.elab.vdl2.*,java.io.*" %>

<%
	String workflowID = request.getParameter("workflowID");
	
	if (workflowID == null) {
		workflowID = (String) request.getAttribute("foregroundWorkflowID");
	}

	if (workflowID == null) {
		%> <jsp:forward page="list.jsp"/> <%
	}
	else {
		Workflow workflow = Workflows.getWorkflow(session, workflowID);
		
		if (workflow == null) {
			%> 
				The specified workflow ID (<%= workflowID %>) is invalid. Please re-run the experiment.
			<%
		}
		else {
			if (request.getParameter("cancel") != null) {
				workflow.cancel();
				%> <h1>The study was canceled</h1> <%
			}
			else if (request.getParameter("background") != null) {
				%> 
					<h1>The study has been added to the study list and continues to run</h1>
					<jsp:forward page="list.jsp"/> 
				<%
			}
		}
	}
%>

</ul>
</body>
</html>