//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Oct 2, 2006
 */
package gov.fnal.elab.vdl2;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.globus.cog.karajan.Loader;
import org.globus.cog.karajan.SpecificationException;
import org.globus.cog.karajan.stack.LinkedStack;
import org.globus.cog.karajan.stack.VariableStack;
import org.globus.cog.karajan.workflow.ElementTree;
import org.globus.cog.karajan.workflow.ExecutionContext;

public class KarajanWorkflow extends ShellWorkflow {
	private static final Map trees, progress;
	public static final String workflowsDir = System.getProperty("vds.home");

	static {
		trees = new HashMap();
		progress = new HashMap();
	}

	protected synchronized static ElementTree getTree(String file) throws SpecificationException,
			IOException {
		DatedTree tree;
		tree = (DatedTree) trees.get(file);
		if (tree == null) {
			tree = new DatedTree(file);
			trees.put(file, tree);
		}
		tree.update();
		return tree.getElementTree();
	}

	private ExecutionContext ec;
	private OutputChannel out;

	protected KarajanWorkflow(String name, String script) {
		super(name, script);
	}

	public String getScript() {
		return super.getExecutable();
	}

	public synchronized void start() {
		try {
			List argv = getArgv();
			if (argv == null) {
				argv = Collections.EMPTY_LIST;
			}

			ElementTree tree = getTree(getExecutable());
			ec = new ExecutionContext(tree);
			ec.setArguments(argv);
			out = new OutputChannel();
			out.setPattern("Running job");
			ec.setStderr(out);
			ec.setStdout(out);
			out.append("Arguments: \n");
			Iterator i = argv.iterator();
			while (i.hasNext()) {
				out.append("  " + i.next() + "\n");
			}
			VariableStack stack = new LinkedStack(ec);

			String runMode = (String) getAttribute("runMode");
			if (runMode != null) {
				String poolFile = "sites.xml";
				if ("local".equals(runMode)) {
					poolFile = "sites-local.xml";
				}
				else if ("mixed".equals(runMode)) {
					poolFile = "sites-mixed.xml";
				}
				else if ("grid".equals(runMode)) {
					poolFile = "sites-grid.xml";
				}
				// disabled for now
				// stack.setGlobal("vdl:sitecatalogfile", poolFile);
			}

			ec.start(stack);
			setStatus(STATUS_RUNNING);
		}
		catch (Exception e) {
			e.printStackTrace();
			setException(e);
			setStatus(STATUS_FAILED);
		}
	}

	public void addArg(String name, Object value) {
		if (value instanceof Integer) {
			super.addArg(name, (Integer) value);
		}
		else if (value instanceof String) {
			String s = (String) value;
			addArg("-" + name + "=" + s.replaceAll("\r\n?", "\\n"));
		}
		else if (value instanceof List) {
			addArg(name, (List) value);
		}
		else {
			throw new IllegalArgumentException("Unexpected type of argument ("
					+ (value == null ? "null" : value.getClass().toString()) + ") for " + name);
		}
	}

	protected void addArg(String name, List values) {
		StringBuffer sb = new StringBuffer();
		Iterator i = values.iterator();
		while (i.hasNext()) {
			sb.append(String.valueOf(i.next()));
			if (i.hasNext()) {
				sb.append(',');
			}
		}
		addArg("-" + name + "=" + sb.toString());
	}

	public void cancel() {
	}

	public String getSTDERR() {
		if (out != null) {
			return out.toString();
		}
		else {
			return "";
		}
	}

	protected void updateStatus() {
		if (ec == null) {
			return;
		}
		else if (ec.done()) {
			if (ec.isFailed()) {
				setException((Exception) ec.getFailure());
				setStatus(STATUS_FAILED);
			}
			else {
				System.out.println("Execution time: " + (ec.getEndTime() - ec.getStartTime())
						+ "ms");
				setMaxProgress(getExecutable(), out.getPatternCounter());
				setStatus(STATUS_COMPLETED);
			}
		}
		else {
			updateProgress(getExecutable(), out.getPatternCounter());
		}
	}

	private void setMaxProgress(String executable, int max) {
		synchronized (progress) {
			progress.put(executable, new Integer(max));
		}
	}

	private void updateProgress(String executable, int crt) {
		synchronized (progress) {
			Integer max = (Integer) progress.get(executable);
			if (max != null) {
				setProgress(((double) crt) / max.intValue());
			}
		}
	}

	public static class DatedTree {
		private ElementTree elementTree;
		private File file;
		private long modified;

		public DatedTree(String file) {
			this.file = new File(file);
			if (!this.file.isAbsolute() && workflowsDir != null) {
				this.file = new File(workflowsDir, file);
			}
			this.modified = 0;
		}

		public boolean equals(Object obj) {
			if (obj instanceof DatedTree) {
				return ((DatedTree) obj).file.equals(file);
			}
			else {
				return false;
			}
		}

		public int hashCode() {
			return file.hashCode();
		}

		public synchronized void update() throws SpecificationException, IOException {
			if (!file.exists()) {
				throw new FileNotFoundException(file.getAbsolutePath());
			}
			if (modified < file.lastModified()) {
				elementTree = Loader.load(file.getAbsolutePath());
				modified = file.lastModified();
			}
		}

		public ElementTree getElementTree() {
			return elementTree;
		}
	}

	public static class Template extends ShellWorkflow.Template {
		public Template(String name, String script) {
			super(name, script, (List) null);
		}

		public String getScript() {
			return super.getExecutable();
		}

		public Workflow newInstance(List argv) {
			KarajanWorkflow workflow = new KarajanWorkflow(getName(), getScript());
			workflow.addArgs(argv);
			return workflow;
		}
	}
}
