<%@ include file="../include/elab.jsp" %>
<%@ page import="org.globus.cog.karajan.workflow.*" %>
<%@ page import="org.globus.cog.karajan.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.globus.cog.karajan.arguments.*" %>

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
		private String current;
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
			timestamp = new Date();
			load();
			ec = new ExecutionContext(et);
			out = new OutputChannel();
			out.append("@timestamp=" + timestamp);
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
					if (lines != 0) {
						return "running" + out.getLineCount() * 100 / lines;
					}
					else {
						return "running0";
					}
				}
			}
		}
		
		private void processOutput() {
			if (out != null) {
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
	
	private static Monitor monitor;
	
	public static synchronized Monitor getMonitor(String script) {
		if (monitor == null) {
			monitor = new Monitor(script);
		}
		return monitor;
	}
%>

<%
	response.setHeader("Cache-Control", "no-cache");
	String op = request.getParameter("op");
	Monitor m = getMonitor(elab.getAbsolutePath(elab.getName() + "/monitor/monitor.k"));
	if ("start".equals(op)) {
		m.start();
		out.write("ok");
	}
	else if ("status".equals(op)) {
		out.write(m.getStatus());
	}
	else if ("getdata".equals(op)) {
		out.write(m.getOutput());
	}
	else if ("getraw".equals(op)) {
		out.write(m.getRawOutput());
	}
	else if ("reset".equals(op)) {
		monitor = null;
	}
	else {
		out.write("missingOp");
	}
%>