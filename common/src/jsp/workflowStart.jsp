<%@ page language="java" import="java.util.*,gov.fnal.elab.vdl2.*" %>

<br>
<%!
public static void startExistingWorkflow(String id, HttpServletRequest request) {
	Workflow workflow = Workflows.getWorkflow(request.getSession(), id);
	startWorkflow(workflow, request);
}
%>

<%!
public static void startWorkflowFromParams(HttpServletRequest request, JspWriter out) throws java.io.IOException {
	HttpSession session = request.getSession();
	ServletContext application = session.getServletContext();

	String workflowName = request.getParameter("workflow");

	String continuation = request.getParameter("continuation");

	if (continuation == null) {
		continuation = application.getInitParameter("vds:workflowWrapperDefaultContinuation");
	}

	if (continuation == null) {
		continuation = "index.jsp";
	}

	Collection workflows = (Collection) Workflows.getDefault().getWorkflowNames();

	String argv = request.getParameter("argv");
	List arglist = new ArrayList();
	
	System.out.println("Starting " + workflowName + " with arguments...");
	if (argv != null) {
		StringTokenizer st = new StringTokenizer(argv, " ");
		
		while(st.hasMoreTokens()) {
			arglist.add(st.nextToken());
		}

		Iterator i = arglist.iterator();
		
		while(i.hasNext()) {
			out.print(i.next());
			if (i.hasNext()) {
				out.print(", ");
			}
		}
	}
		
		
	
	try {
		Workflow workflow = Workflows.getDefault().newInstance(workflowName);
		workflow.addArgs(arglist);
		workflow.setContinuation(continuation);
		startWorkflow(workflow, request);
	}
	catch (InvalidWorkflowException e) {
		out.println("Invalid workflow name: " + workflowName + "<br>");
		out.println("Valid workflow names are:<br>");
		out.println("<ul>");
		Iterator i = e.getValid().iterator();

		while (i.hasNext()) {
			out.println("<li>"+i.next());
		}
		
		out.println("</ul>");
	}
}
%>

<%!
public static void startWorkflow(Workflow workflow, HttpServletRequest request) {
	String runMode = request.getParameter("workflowRunMode");
	System.err.println("Run mode: " + runMode);
	workflow.setAttribute("runMode", runMode);
	workflow.start();
	
	request.setAttribute("foregroundWorkflowID", workflow.getID());
}
%>

<%
String workflowID = request.getParameter("workflowID");
if (workflowID == null) {
	workflowID = (String) request.getAttribute("workflowID");
}

if (workflowID != null) {
	startExistingWorkflow(workflowID, request);
}
else {
	startWorkflowFromParams(request, out);
}

%> <jsp:forward page="workflowStatus.jsp"/> <%

%>