<%@ page language="java" import="java.util.*,java.io.*" %>
<%@ page import="gov.fnal.elab.vdl2.Workflow" %>
<%@ page import="gov.fnal.elab.vdl2.Workflows" %>


<html>
<head>
<title>Running studies</title>
<%@ include file="include/javascript.jsp" %>

<!-- include css style file -->
<%@ include file="include/style.css" %>

<!-- header/navigation -->
<%
String headerType = "Data";
%>
<%@ include file="common.jsp" %>
<%@ include file="include/navbar_common.jsp" %>

<%@ include file="workflowutil.jsp" %>
<%@ include file="dhtmlutil.jsp" %>

<%!
	public static void writeStatus(Workflow wf, JspWriter out) throws IOException {
		String id = wf.getID();
		String status = workflowStatusString(wf);
		String cstatus = status;
		if (status != null && status.length() > 0) {
			cstatus = Character.toUpperCase(status.charAt(0)) + status.substring(1);
		}
		String progress = workflowProgress(wf);
		out.write("<table border=\"0\"><tr><td>");
		out.write("<img id=\"imgstatus" + id + "\" src=\"graphics/" + status + ".png\"/></td>");
		out.write("<td id=\"textstatus" + id + "\">" + cstatus + "</td>");
		if ("running".equals(status)) {
			out.write("<td><table id=\"progressbar" + id + "\" style=\"border: solid black thin;\" width=\"100px\" cellpadding=\"0\" cellspacing=\"1\">");
			out.write("<tr>");
			out.write("<td id=\"progress" + id + "\" width=\"" + (Double.parseDouble(progress)*99 + 1) + "%\" bgcolor=\"#5d89d9\">&nbsp;</td>");
			out.write("<td>&nbsp;</td>");
			out.write("</tr>");
			out.write("</table></td>");
		}
		out.write("</tr></table>");
	}
%>

<br><br>
  <center>
  	<%
		
  	Collection ids = Workflows.getWorkflowIDS(session);
	
	%>
	<table border="1" id="wftable">
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Status</th>
			<th>Results</th>
			<th>Continuation</th>
		</tr>
		<%
			if (ids.isEmpty()) {
				%><tr id="nostudies"><td colspan="5"><h1>There are no studies in this session</h1></td></tr> <%	
			}
		
			Iterator i = ids.iterator();
		
			while (i.hasNext()) {
				String workflowID = (String) i.next();
			
				Workflow workflow = Workflows.getWorkflow(session, workflowID);
				int status = workflow.getStatus();
			
				%>
					<tr>
						<td><%= workflowID %></td>
						<td><%= workflow.getName() %></td>
						<td>
							<%
								writeStatus(workflow, out);
							%>
						</td>
						<td>
							<%
								if (status == Workflow.STATUS_COMPLETED) {
									%>
										<a href="workflowStatus.jsp?workflowID=<%= workflow.getID() %>">See results</a>
									<%
								}
								else {
									%>
										<a id="results<%=workflowID%>" style="<%=STYLE_H%>" href="workflowStatus.jsp?workflowID=<%= workflow.getID() %>">See results</a>
									<%
								}
							%>
						</td>
						<td>
							<%
								if (status == Workflow.STATUS_COMPLETED) {
									out.write(workflow.getContinuation());
								}
							%>
						</td>
					</tr>
				<%
			}
		%>
	</table>
	<%@ include file="asyncupdate.jsp" %>
	<script language="JavaScript">
		registerUpdate("workflowStatusAsync.jsp?workflowID=all", update);
							
		function update(data) {
			if (data["ids"] != null) {
				var ids = data["ids"].split(",");
				
				for (i in ids) {
					var id = ids[i];
					
					var status = data["status" + id];
					var progress = data["progress"+ id];
					var name = data["name" + id];
					
					if (status != null && progress != null && name != null) {
						var cstatus = status.charAt(0).toUpperCase() + status.substr(1);
						var imgstatus = document.getElementById("imgstatus" + id);
						if (imgstatus == null) {
							var nostudies = document.getElementById("nostudies")
							if (nostudies != null) {
								nostudies.style.visibility="hidden";
								nostudies.style.display="none";
							}
							var table = document.getElementById("wftable");
							var row = table.insertRow(table.rows.length);
							row.insertCell(0).innerHTML = "<td>" + id + "</td>";
							row.insertCell(1).innerHTML = name;
							var hstatus =  "<table border=\"0\"><tr><td>" +
								 "<img id=\"imgstatus" + id + "\" src=\"graphics/" + status + ".png\"/></td>" +
								 "<td id=\"textstatus" + id + "\">" + cstatus + "</td>";
							
							if (status == "running") {
								hstatus +="<td><table id=\"progressbar" + id + "\" style=\"border: solid black thin;\"" +
								"width=\"100px\" cellpadding=\"0\" cellspacing=\"1\">" +
									"<tr>" + 
									"<td id=\"progress" + id + "\" width=\"" + (progress*99 + 1) + "%\" bgcolor=\"#5d89d9\">&nbsp;</td>" + 
									"<td>&nbsp;</td>" + 
									"</tr></table></td>";
							}
							hstatus += "</tr></table>";
								
							row.insertCell(2).innerHTML = hstatus;
							var rescel;
							if (status == "completed") {
								rescell = "<a href=\"workflowStatus.jsp?workflowID=" + id + "\">See results</a>";
							}
							else {
								rescell = "<a id=\"results" + id + "\" style=\"<%=STYLE_H%>\" href=\"workflowStatus.jsp?workflowID=" + id + "\">Details</a>";
							}
							row.insertCell(3).innerHTML = rescell;
						
							row.insertCell(4).innerHTML = "&nbsp;";
						}
						else {
							imgstatus.src = "graphics/" + status + ".png";
							
							var textstatus = document.getElementById("textstatus" + id);
							textstatus.innerHTML = cstatus;
						
							var tdprogress = document.getElementById("progress" + id);
							if (tdprogress != null) {
								tdprogress.width = (progress*99+1) + "%";
							}
							if (status == "completed") {
								var results = document.getElementById("results" + id);
								if (results != null) {
									results.style.visibility="visible";
									results.style.display="";
								}
								var progressbar = document.getElementById("progressbar" + id);
								if (progressbar != null) {
									progressbar.style.visibility = "hidden";
								}
							}
						}
					}
				}
			}
		}
	</script>
  </center>
</ul>
</body>
</html>