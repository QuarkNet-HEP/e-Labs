<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.io.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis status</title>
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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
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
										Try running the <a href="<%= run.getAttribute("onError") + "?" + run.getAnalysis().getEncodedParameters() %>">analysis</a> with different parameters.
									</p>
								<%
							}
						%>
						
						<br>
						<e:vswitch>
							<e:visible>
								<strong>Analysis output</strong>
							</e:visible>
							<e:hidden>
								<strong>Analysis output</strong><br/>
								<code style="font-size: small;">
<%
							HTMLEscapingWriter wr = new HTMLEscapingWriter(out);
							wr.write(run.getSTDERR());
							out.write("<hr><code>");
							if (e != null) {
								e.printStackTrace(new PrintWriter(wr));
							}
							out.write("<hr>");
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
						<h1>The <%= run.getAnalysis().getType() %> study is running...</h1>
						<img src="../graphics/busy2.gif"/><br><br><br>
						Progress: 
						<table style="border: solid black thin;" width="20%">
							<tr>
								<td id="progressbar" width="<%= run.getProgress()*99 + 1 %>%" bgcolor="#5d89d9">&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</table>
						
						
						<%@ include file="../analysis/async-update.jsp" %>
						<script language="JavaScript">
							registerUpdate("../analysis/status-async.jsp?id=" + <%= run.getId() %>, update);
							
							function update(data) {
								if (data["error"] != null) {
									stopUpdates()
									window.location = "../analysis/status.jsp?id=" + <%= run.getId() %>;
								}
								else if (data["status"] != null) {
									var td = document.getElementById("progressbar");
									if (data["status"] == "Running") {
										td.width = (data["progress"]*99+1) + "%";
									}
									else {
										if (data["status"] == "Completed") {
											td.width = "100%";
										}
										stopUpdates();
										window.location = "../analysis/status.jsp?id=" + <%= run.getId() %>;
									}
								}
							}
						</script>
			
					<br><br>
					<table border="0">
						<tr>
							<form action="../analysis/action.jsp">
								<input type="hidden" name="id" value="<%= run.getId() %>"/>
								<td>
									<input type="submit" name="cancel" value="Cancel study"/>
								</td>
								<td>
									<input type="submit" name="background" value="Queue study"/>
								</td>
							</form>
			
			
							<form action="../analysis/status.jsp">
								<input type="hidden" name="id" value="<%= run.getId() %>"/>
								<td>
									<input id="refresh-button" type="submit" name="refresh" value="Refresh status"/>
								</td>
							</form>
						</tr>
					</table>
				
					</center>
				
					<hr>
					
					<e:vswitch>
						<e:visible>
							<strong>Analysis output</strong>
						</e:visible>
						<e:hidden>
							<strong>Analysis output</strong><br/>
							<code style="font-size: small;">
<%
	String output = run.getSTDERR();
	
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