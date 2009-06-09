<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.io.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis Status</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>

	<body id="statusinfo" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<%
				if (status == AnalysisRun.STATUS_FAILED || showStatus != null) {
				    Throwable e = run.getException();
				    String message = e == null ? "Unknown error. See output for details." : e.getMessage();
					%>
						<%
							if (showStatus == null) {
								%> 
									<h1>The study failed to run properly</h1>
									<h2><%= message %></h2>
									<p>
										Try running the 
										<a href="${run.attributes.onError}?${run.analysis.encodedParameters}&runMode=${run.analysis.attributes.runMode}">analysis</a>
										with different parameters.
									</p>
								<%
							}
						%>
						
						<br />
						<e:vswitch>
							<e:visible>
								<strong>Analysis output</strong>
							</e:visible>
							<e:hidden>
								<strong>Analysis output</strong><br />
								<code style="font-size: small;">
<%
							HTMLEscapingWriter wr = new HTMLEscapingWriter(out);
							wr.write(run.getSTDERR());
							out.write("<hr />");
							if (e != null) {
								e.printStackTrace(new PrintWriter(wr));
							}
							out.write("<hr />");
							wr.write(run.getDebuggingInfo());
%>
								</code>
							</e:hidden>
						</e:vswitch>
					<%
				}
				else if (status == AnalysisRun.STATUS_RUNNING) {
					%>
					<center>
						<h1>Running ${run.analysis.name}...</h1>
						<img src="../graphics/busy2.gif" alt="Image suggesting something is happening" /><br /><br /><br />
						Progress: 
						<table id="status-progress" width="20%">
							<tr>
								<td id="status-progress-indicator" width="${run.progress * 99 + 1}%">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</table>
						Elapsed time: <span id="elapsed-time">${run.formattedRunTime}</span>; 
						estimated: ${run.formattedEstimatedRunTime}
						<div id="error-text" style="background: #ffaf70"></div>
						
						
						<%@ include file="../analysis/async-update.jsp" %>
						<script language="JavaScript" type="text/javascript">
							registerUpdate("../analysis/status-async.jsp?id=${run.id}", update);
							
							document.progressGoal = 0;
							document.currentProgress = 0;
							self.setTimeout(smoothProgress, 100);
							
							function smoothProgress() {
								if (document.currentProgress < document.progressGoal) {
									var td = document.getElementById("status-progress-indicator");
									document.currentProgress+=2;
									td.width = document.currentProgress + "%";
								}
								self.setTimeout(smoothProgress, 20);
							}
							
							function update(data, error) {
								if (error != null) {
									var diverr = document.getElementById("error-text");
									diverr.innerHTML = error;
									setTimeout('window.location="../analysis/status.jsp?id=${run.id}"', 1000);
								}
								else if (data["error"] != null) {
									stopUpdates()
									window.location = "../analysis/status.jsp?id=${run.id}";
								}
								else if (data["status"] != null) {
									if (data["status"] == "Running") {
										var percent = (data["progress"] * 99 + 1).toFixed(0);
										document.progressGoal = percent;
										document.title = percent + "% - Analysis Status";
										var elapsed = document.getElementById("elapsed-time");
										elapsed.innerHTML = data["elapsedTime"];
									}
									else {
										if (data["status"] == "Completed") {
											var td = document.getElementById("status-progress-indicator");
											td.width = "100%";
										}
										stopUpdates();
										window.location = "../analysis/status.jsp?id=${run.id}";
									}
								}
							}
						</script>
			
					<br /><br />
					<form action="../analysis/action.jsp">
						<input type="hidden" name="id" value="${run.id}" />
						<input type="submit" name="cancel" value="Cancel study" />
						<input type="submit" name="background" value="Queue study" />
					</form>
					<form action="../analysis/status.jsp">
						<input type="hidden" name="id" value="${run.id}" />
						<input id="refresh-button" type="submit" name="refresh" value="Refresh status" />
					</form>
				
					</center>
				
					<hr />
					
					<e:vswitch>
						<e:visible>
							<strong>Analysis output</strong>
						</e:visible>
						<e:hidden>
							<strong>Analysis output</strong><br />
							<code style="font-size: small;">
<%
	String output = run.getSTDERR();
	if (output != null) {
		StringTokenizer st = new StringTokenizer(output, "\n");
		int lines = st.countTokens();
		if (lines > 20) {
			out.println("...<br />");
		}
		int skip = lines - 20;
		for(int i = 0; i < skip; i++) {
			st.nextToken();
		}
		while(st.hasMoreTokens()) {
			out.print(st.nextToken());
			out.println("<br />");
		}
	}
%>
							</code>
						</e:hidden>
					</e:vswitch>
				<%
				}
				else if (status == AnalysisRun.STATUS_CANCELED) {
					%> <h1>The study was canceled</h1> <%
				}
				else if (status == AnalysisRun.STATUS_NONE) {
					%> <h1>The study was not yet started</h1> <%
				}
			%>
		 	</div>
		</div>
	</body>
</html>