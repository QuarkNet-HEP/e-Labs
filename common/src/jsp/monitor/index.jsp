<%@ include file="../include/elab.jsp" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="org.globus.cog.karajan.arguments.*" %>
<%@ page import="org.globus.cog.karajan.workflow.*" %>
<%@ page import="org.globus.cog.karajan.*" %>

<%!
	public static class OutputChannel extends AbstractWriteOnlyVariableArguments {
		private StringBuffer sb;
		private int lines;
	
		public OutputChannel() {
			sb = new StringBuffer();
		}
	
		public synchronized void append(Object value) {
			String str = String.valueOf(value);			
			StringTokenizer st = new StringTokenizer(str, "\n\r");
			lines += st.countTokens();
			while (st.hasMoreTokens()) {
				System.out.println("monitor: " + st.nextToken());
			}
			sb.append(str);
		}
	
		public boolean isCommutative() {
			return false;
		}
	
		public String toString() {
			return sb.toString();
		}
	
		public int getLineCount() {
			return lines;
		}
	}

	public static class Monitor {
		private ElementTree et;
		private String current = "";
		private boolean running;
		private String script;
		private ExecutionContext ec;
		private Date timestamp;
		private int lines;
		private OutputChannel out;
		
		public Monitor(String script) {
			this.script = script;
		}
		
		public synchronized void start() throws Exception {
			if (running) {
				return;
			}
			running = true;
			load();
			ec = new ExecutionContext(et);
			out = new OutputChannel();
            ec.setStderr(out);
            ec.setStdout(out);
            ec.start();
		}
		
		private void load() throws Exception {
			if (et == null) {
				et = Loader.load(script);
			}
		}
		
		public synchronized String getStatus() {
			if (ec == null) {
				return "stopped";
			}
			else {
				boolean done = ec.done();
				if (running && done) {
					processOutput();
					running = false;
					lines = out.getLineCount();
				}
				if (done) {
					if (ec.isFailed()) {
						if (ec.getFailure() != null) {
							ec.getFailure().printStackTrace();
						}
						else {
							System.err.println("No explicit failure");
						}
						return "failed";
					}
					else {
						return "stopped";
					}
				}
				else {
					return "running";
				}
			}
		}
		
		public int getProgress() {
			if (lines != 0 && out != null) {
				return out.getLineCount() * 100 / lines;
			}
			else {
				return -1;
			}
		}
		
		private void processOutput() {
			if (out != null) {
				timestamp = new Date();
				out.append("@timestamp=" + timestamp + "\n");
				current = out.toString();
			}
		}
		
		public synchronized String getOutput() {
			return current;
		}
		
		public synchronized String getRawOutput() {
			if (out == null) {
				return "";
			}
			else {
				return out.toString();
			}
		}
		
		public Date getTimestamp() {
			return timestamp;
		}
	}
	
	public static synchronized Monitor getMonitor(ServletContext c, String script) {
		Monitor monitor = (Monitor) c.getAttribute("i2u2.site.monitor");
		if (monitor == null) {
			monitor = new Monitor(script);
			c.setAttribute("i2u2.site.monitor", monitor);
		}
		return monitor;
	}
%>
<%
	response.setHeader("Cache-Control", "no-cache");
	
	Monitor m = getMonitor(application, elab.getAbsolutePath(elab.getName() + "/monitor/monitor.k"));
	String op = request.getParameter("op");
	String status = m.getStatus();
	if (!"nostart".equals(op) && !"status".equals(op)) {
		m.start();
		status = m.getStatus();
	}
	if ("status".equals(op)) { 
		out.write("status=" + status + "&progress=" + m.getProgress());
		return;
	}
	request.setAttribute("raw", m.getRawOutput());
	
	String ds = null;
	
	if (status.equals("stopped")) {
		ds = "<a class=\"button\" href=\"?op=start\">Update</a>";
	}
	else if (status.equals("running")) {
		if (m.getProgress() == -1) {
			ds = "Updating<span id=\"status-progress-indicator\">...</span>";
		} 
		else {
			ds = "Updating: <span id=\"status-progress-indicator\">" + m.getProgress() + "</span>%";
		}
	}
	else if (status.equals("failed")) {
		ds = "Failed. <a class=\"button\" href=\"?op=start\">Run Again</a>";
	}
	
	request.setAttribute("status", ds);
	
	if (m.getStatus().startsWith("running")) {
		request.setAttribute("enableScript", Boolean.TRUE);
	}
	
	Map sites = new TreeMap();
	Map sitemap = null;
	List paths = null;
	BufferedReader br = new BufferedReader(new StringReader(m.getOutput()));
	String line = br.readLine();
	while (line != null) {
		if (line.startsWith("@")) {
			if (line.startsWith("@timestamp=")) {
				request.setAttribute("modified", line.substring(11));
			}
			else if (line.startsWith("@site=")) {
				sitemap = new HashMap();
				paths = new ArrayList();
				sitemap.put("paths", paths);
				String name = line.substring("@site=".length());
				sitemap.put("name", name);
				sites.put(name, sitemap);		
			}
			else if (line.startsWith("@diskFree-")) {
				int index = line.indexOf('=');
				String mount = line.substring(10, index);
				Map mm = new HashMap();
				mm.put("name", mount);
				if (line.endsWith("succeeded")) {
					br.readLine();
					line = br.readLine();
					String[] values = line.split("\\s+");
					if (values.length == 1) {
						//when the device path is too long, df splits this on two lines
						line = "dummy " + br.readLine();
						values = line.split("\\s+");
					}
					String value = values[4];
					value = value.substring(0, value.length() - 1);
					mm.put("value", value);
					mm.put("disabled", "false");
				}
				else {
					mm.put("value", "-1");
					mm.put("disabled", "true");
				}
				paths.add(mm);
			}
			else if (line.startsWith("@uptime")) {
				if (line.endsWith("succeeded")) {
					line = br.readLine();
					int index = line.indexOf("load average: ");
					if (index == -1) {
						continue;
					}
					String[] values = line.substring(index + 14).replaceAll(",", "").split("\\s+");
					sitemap.put("loadvalue", values);
					sitemap.put("loaddisabled", "false");
				}
				else {
					sitemap.put("loadvalue", new int[3]);
					sitemap.put("loaddisabled", "true");
				}
				
			}
			else if (line.startsWith("@basicFSTest-")) {
				int index = line.indexOf('=');
				String provider = line.substring(13, index);
				sitemap.put("fstype", provider);
				sitemap.put("fstest", Boolean.valueOf(line.endsWith("succeeded")));
			}
			else if (line.startsWith("@basicExecTest-")) {
				int index = line.indexOf('=');
				String provider = line.substring(15, index);
				sitemap.put("exectype", provider);
				sitemap.put("exectest", Boolean.valueOf(line.endsWith("succeeded")));
			}
			//out.write(line);
		}
		line = br.readLine();
	}
	request.setAttribute("sites", sites);
%>

<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:svg="http://www.w3.org/2000/svg">
	<head>
		<style type="text/css">
.label {
	border: thin outset #b0b0b0;
	background-color: #ffffff;
	padding-left: 4px;
	padding-right: 4px;
}

body {
	background-color: #b0b0b0;
	font-size: 11px;
	font-family: gill, verdana, arial;
}
		</style>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body>
		<script language="JavaScript" type="text/javascript">
			setInterval(updateTime, 1000);
				
			function updateTime() {
				var last = Date.parse("${modified}");
				if (isNaN(last)) {
					return;
				}
				var now = new Date().getTime();
				var s = (now - last)/1000;
				var span = document.getElementById("elapsed");
				var str = "(";
				if (s < 60) {
					str += "less than 1 minute";
				}
				else {
					var m = Math.floor(s / 60);
					var h = Math.floor(m / 60);
					var d = Math.floor(h / 24);
					m = m % 60;
					h = h % 24; 
					if (d != 0) {
						str += d + " day";
						if (d != 1) {
							str += "s";
						}
					}
					if (h != 0) {
						if ((d != 0) && (m == 0)) {
							str += " and ";
						}
						else if ((d != 0) && (m != 0)) {
							str += ", ";
						}
						str += h + " hour";
						if (h != 1) {
							str += "s";
						}
					}
					if (m != 0) {
						if ((d != 0) || (h != 0)) {
							str += " and ";
						}
						str += m + " minute";
						if (m != 1) {
							str += "s";
						}
					}
				}
				str += " ago)";
				span.innerHTML = str;
			}
		</script>
		<c:if test="${enableScript}">
			<%@ include file="../analysis/async-update.jsp" %>
	
			<script language="JavaScript" type="text/javascript">
				registerUpdate("../monitor/index.jsp?op=status", update);
				
				function update(data) {
					if (data["status"] == "failed" || data["status"] == "stopped") {
						stopUpdates();
						window.location = "../monitor/index.jsp?op=nostart";
					}
					else if (data["status"] == "running") {
						var span = document.getElementById("status-progress-indicator");
						if (data["progress"] != "-1") {
							span.innerHTML = data["progress"];
						}
						else {
							if (span.innerHTML == ".") {
								span.innerHTML = "..";
							}
							else if (span.innerHTML == "..") {
								span.innerHTML = "...";
							}
							else if (span.innerHTML == "...") {
								span.innerHTML = ".";
							} 
						}
					}
				}
			</script>
		</c:if>
<p>
	${status}<br/>
	Last update: ${modified} <span id="elapsed"></span>
</p>
<table cellpadding="0" cellspacing="1" border="0">
	<tr>
		<th><div class="label">Site</div></th>
		<th width="86px"><div class="label">Filesystem</div></th>
		<th width="86px"><div class="label">Execution</div></th>
		<th><div class="label">Load Average</div></th>
		<th><div class="label">Disk Utilization</div></th>
	</tr>
	<c:forEach items="${sites}" var="site">
		<tr>
			<td align="right" class="label">
				<strong>${site.key}</strong>
			</td>
			
			<td valign="top">
				<table cellspacing="1" cellpadding="1">
					<tr valign="bottom">
						<td align="center" width="86px">
							<c:choose>
								<c:when test="${site.value.fstype}">${site.value.fstype}</c:when>
								<c:otherwise>N/A<c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<td align="center">
							<div class="label">
								<c:choose>
									<c:when test="${site.value.fstest}">
										<object type="image/svg+xml" data="onoff.jsp?value=${site.value.fstest}" width="50" height="70">SVG not supported</object>
									</c:when>
									<c:otherwise>
										<object type="image/svg+xml" data="onoff.jsp?disabled=true" width="50" height="70">SVG not supported</object>
									</c:otherwise>
								</c:choose>
							</div>
						</td>
					</tr>
				</table>
			</td>
			
			<td valign="top">
				<table cellspacing="1" cellpadding="1">
					<tr valign="bottom">
						<td align="center" width="86px">
							<div class="label">${site.value.exectype}</div>
						</td>
					</tr>
					<tr>
						<td align="center">
							<div class="label">
								<object type="image/svg+xml" data="onoff.jsp?value=${site.value.exectest}" width="50" height="70">SVG not supported</object>
							</div>
						</td>
					</tr>
				</table>
			</td>
			
			<td valign="top">
				<table cellspacing="1" cellpadding="1">
					<tr valign="bottom">
						<td align="center">
							<div class="label">${site.value.loadvalue[0]}, ${site.value.loadvalue[1]}, ${site.value.loadvalue[2]}</div>
						</td>
					</tr>
					<tr>
						<td align="center">
							<div class="label">
								<object type="image/svg+xml" data="multi-gauge.jsp?value1=${site.value.loadvalue[0]}&value2=${site.value.loadvalue[1]}&value3=${site.value.loadvalue[2]}&disabled=${site.value.loaddisabled}" width="160" height="70">SVG not supported</object>
							</div>
						</td>
					</tr>
				</table>
			</td>
			
			<td valign="top">
				<table cellspacing="1" cellpadding="1">
					<tr valign="bottom">
						<c:forEach items="${site.value.paths}" var="path">
							<td align="center" width="190px">
								<div class="label">${path.name}</div>
							</td>
						</c:forEach>
					</tr>
					<tr>
						<c:forEach items="${site.value.paths}" var="path">
							<td align="center">
								<div class="label">
									<object type="image/svg+xml" data="gauge.jsp?value=${path.value}&disabled=${path.disabled}" width="160" height="70">SVG not supported</object>
								</div>
							</td>
						</c:forEach>
					</tr>
				</table>
			</td>
		</tr>
	</c:forEach>
</table>



</p>
<e:vswitch>
	<e:visible>
		Raw output so far
	</e:visible>
	<e:hidden>
		Raw output so far
<pre>${raw}</pre>
	</e:hidden>
</e:vswitch>
</body>
</html>