//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Sep 25, 2006
 */
package gov.fnal.elab.vdl2;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class ShellWorkflow extends Workflow {
	private String executable;
	private Process process;

	public ShellWorkflow(String name, String executable) {
		super(name);
		this.executable = executable;
	}

	public synchronized void start() {
		try {
			List argv = getArgv();
			if (argv == null) {
				argv = Collections.EMPTY_LIST;
			}
			String[] cmdarray = new String[argv.size() + 1];
			cmdarray[0] = executable;
			Iterator i = argv.iterator();
			for (int j = 1; j < cmdarray.length; j++) {
				cmdarray[j] = (String) i.next();
			}

			debug("Executing: " + Arrays.asList(cmdarray));
			process = Runtime.getRuntime().exec(cmdarray);
			setStatus(STATUS_RUNNING);
		}
		catch (Exception e) {
			e.printStackTrace();
			setException(e);
			setStatus(STATUS_FAILED);
		}
	}

	protected synchronized void updateStatus() {
		// TODO STDXXX management
		if (process != null) {
			try {
				int exit = process.exitValue();
				if (exit != 0) {
					setException(new Exception("Workflow terminated with code " + exit));
				}
				setProgress(1);
				setStatus(STATUS_COMPLETED);
			}
			catch (IllegalThreadStateException e) {
				// still running
			}
		}
	}

	public synchronized void cancel() {
		if (process != null) {
			process.destroy();
		}
	}

	public synchronized String getSTDERR() {
		if (process != null) {
			StringBuffer sb = new StringBuffer();
			BufferedReader br = new BufferedReader(new InputStreamReader(process.getErrorStream()));
			try {
				String line = br.readLine();
				while (line != null) {
					sb.append(line);
					sb.append('\n');
					line = br.readLine();
				}
			}
			catch (Exception e) {
				sb.append('\n');
				sb.append(e.toString());
			}
			return sb.toString();
		}
		return "";
	}

	public void addArg(String name, Object value) {
		if (value instanceof Integer) {
			addArg(name, (Integer) value);
		}
		else if (value instanceof String) {
			String s = (String) value;
			if (s.indexOf(' ') != -1) {
				s = '\'' + s + '\'';
			}
			addArg("-" + name + "=" + s);
		}
		else if (value instanceof List) {
			addArg(name, (List) value);
		}
		else {
			throw new IllegalArgumentException("Unexpected type of argument (" + value.getClass()
					+ ") for " + value);
		}
	}

	protected void addArg(String name, Integer value) {
		addArg("-" + name + "=" + value);
	}

	protected void addArg(String name, List values) {
		StringBuffer sb = new StringBuffer();
		sb.append('\'');
		Iterator i = values.iterator();
		while (i.hasNext()) {
			sb.append(String.valueOf(i.next()));
			if (i.hasNext()) {
				sb.append(',');
			}
		}
		sb.append('\'');
		addArg("-" + name + "=" + sb.toString());
	}

	public String getExecutable() {
		return executable;
	}

	public static class Template extends Workflow.Template {
		private String executable;
		private List initialArgs;

		public Template(String name, String executable, String[] initialArgs) {
			this(name, executable, initialArgs == null ? null : Arrays.asList(initialArgs));
		}

		public Template(String name, String executable, List initialArgs) {
			super(name);
			this.executable = executable;
			this.initialArgs = initialArgs;
		}

		public Workflow newInstance(List argv) {
			ShellWorkflow workflow = new ShellWorkflow(getName(), executable);
			workflow.addArgs(argv);
			return workflow;
		}

		public String getExecutable() {
			return executable;
		}
	}
}
