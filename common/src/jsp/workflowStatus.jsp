<%@ page language="java" import="java.util.*,gov.fnal.elab.vdl2.*,java.io.*" %>
<%@ include file="dhtmlutil.jsp" %>

<%
	try{
	String workflowID = request.getParameter("workflowID");
	String showStatus = request.getParameter("showStatus");
	
	if (workflowID == null) {
		workflowID = (String) request.getAttribute("foregroundWorkflowID");
	}

	if (workflowID == null) {
		%> <jsp:forward page="workflowList.jsp"/> <%
	}
	else {
		Workflow workflow = Workflows.getWorkflow(session, workflowID);
		
		if (workflow == null) {
			System.err.println("Invalid workflow id " + workflowID);
			%> 
				The specified workflow ID (<%= workflowID %>) is invalid. Please re-run the experiment.
			<%
		}
		else {
			int status = workflow.getStatus();
			if (status == Workflow.STATUS_COMPLETED && showStatus == null) {
				String cont = workflow.getContinuation();
				System.out.println("Initial continuation: " + cont);
				if (cont != null) {
					int i = cont.indexOf("beanName=");
					if (i != -1) {
						int j = cont.indexOf("&", i);
						if (j == -1) {
							j = cont.length();
						}
						String beanName = cont.substring(i + "beanName=".length(), j);
						//need to retrieve the bean for this workflow as it is expected by the
						//jsp code
						session.setAttribute(beanName, workflow.getAttribute("bean"));
						cont = cont.substring(0, i - 1) + cont.substring(j);
					}
					System.out.println("Continuation: "+cont);
					response.sendRedirect(cont);
				}
				else {
					throw new RuntimeException("No continuation");
				}
			}
			else {
				%>
					<html>
						<head>
							<title>Study Execution Status</title>
							<!-- header/navigation -->
							<%
								//be sure to set this before including the navbar
								String headerType = "Data";
							%>
							<%@ include file="include/navbar_common.jsp" %>
							<body>

							<br><br>
				<%
				
				if (status == Workflow.STATUS_FAILED || showStatus != null) {
					%>
						<%
							if (showStatus == null) {
								%> <h1>The study failed to run properly</h1><br> <%
							}
						%>
						
						<br>
						<table border="0" width="100%">
							<tr>
								<td align="left">
									<% visibilitySwitcher(out, "funnyMessagesCT", "funnyMessages", 
									"Hide funny messages", "Show funny messages", true); %>
								</td>
							</tr>
							<tr>
								<td align="left">
									<div id="funnyMessages" style="visibility:visible;display:">
										<code style="font-size: small;">
<%
							out.write(workflow.getSTDERR().replaceAll("\\n", "<br>"));
							out.write("<hr><code>");
							StringWriter wr = new StringWriter();
							Exception e = workflow.getException();
							if (e != null) {
								e.printStackTrace(new PrintWriter(wr));
							}
							out.write(wr.toString().replaceAll("\\n", "<br>"));
							out.write("<hr>");
							out.write(workflow.getDebuggingInfo().replaceAll("\\n", "<br>"));
%>
										</code>
									</div>
								</td>
							</tr>
						</table>						
					<%
				}
				else if (status == Workflow.STATUS_RUNNING) {
					%>
					<center>
						<h1>The <%= workflow.getName() %> study is running...</h1>
						<img src="graphics/busy2.gif"/><br><br><br>
						Progress: 
						<table style="border: solid black thin;" width="20%">
							<tr>
								<td id="progressbar" width="<%= workflow.getProgress()*99 + 1 %>%" bgcolor="#5d89d9">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</table>
						
						
						<%@ include file="asyncupdate.jsp" %>
						<script language="JavaScript">
							registerUpdate("workflowStatusAsync.jsp?workflowID=" + <%= workflowID %>, update);
							
							function update(data) {
								if (data["error"] != null) {
									stopUpdates()
									window.location = "workflowStatus.jsp?workflowID=" + <%= workflowID %>;
								}
								else if (data["status"] != null) {
									var td = document.getElementById("progressbar");
									if (data["status"] == "running") {
										td.width = (data["progress"]*99+1) + "%";
									}
									else {
										if (data["status"] == "completed") {
											td.width = "100%";
										}
										stopUpdates();
										window.location = "workflowStatus.jsp?workflowID=" + <%= workflowID %>;
									}
								}
							}
						</script>
			
					<br><br>
					<table border="0">
						<tr>
							<form action="workflowAction.jsp">
								<input type="hidden" name="workflowID" value="<%= workflowID %>"/>
								<td>
									<input type="submit" name="cancel" value="Cancel study">
								</td>
								<td>
									<input type="submit" name="background" value="Queue study">
								</td>
							</form>
			
			
							<form action="workflowStatus.jsp">
								<input type="hidden" name="workflowID" value="<%= workflowID %>"/>
								<td>
									<input id="refreshButton" type="submit" name="refresh" value="Refresh status">
								</td>
							</form>
						</tr>
					</table>
				
					</center>
				
					<hr>
					
					<table border="0" width="100%">
						<tr>
							<td align="left">
								<% visibilitySwitcher(out, "funnyMessagesCT", "funnyMessages", 
									"Hide funny messages", "Show funny messages", true); %>
								
							</td>
						</tr>
						<tr>
							<td align="left">
								<div id="funnyMessages" style="visibility:visible;display:">
									<code style="font-size: small;">
<%
	String output = workflow.getSTDERR();
	
	StringTokenizer st = new StringTokenizer(output, "\n");
	int lines = st.countTokens();
	if (lines > 20) {
		out.println("...<br>");
	}
	int skip = lines - 20;
	for(int i = 0; i < skip; i++) {
		st.nextToken();
	}
	while(st.hasMoreTokens()) {
		out.print(st.nextToken());
		out.println("<br>");
	}
%>
									</code>
								</div>
							</td>
						</tr>
					</table>
				<%
				}
				else if (status == Workflow.STATUS_CANCELED) {
					%>
						<h1>The study was canceled</h1>
					<%
				}
				else if (status == Workflow.STATUS_NONE) {
					%>
						<h1>The study was not yet started</h1>
					<%
				}
			}
		}
	}
	} catch(Exception e) {e.printStackTrace();}
%>

</ul>
</body>
</html>