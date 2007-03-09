package gov.fnal.elab.vdl2;

import gov.fnal.elab.vds.ElabTransformation;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpSession;

import org.griphyn.vdl.classes.Derivation;
import org.griphyn.vdl.classes.LFN;
import org.griphyn.vdl.classes.Leaf;
import org.griphyn.vdl.classes.Pass;
import org.griphyn.vdl.classes.Scalar;
import org.griphyn.vdl.classes.Text;
import org.griphyn.vdl.classes.Value;

public abstract class Workflow {
	public static final int ID_RANDOM_INCREMENT_LIMIT = 1000;

	public static final int STATUS_NONE = 0;
	public static final int STATUS_RUNNING = 1;
	public static final int STATUS_COMPLETED = 2;
	public static final int STATUS_FAILED = 3;
	public static final int STATUS_CANCELED = 4;

	private List argv;
	private String name;
	private String id;
	private Exception exception;
	private double progress;
	private String continuation;
	private StringBuffer debuggingInfo;
	private Map arguments, attributes;
	private int status;

	protected Workflow(String name) {
		this.id = String.valueOf(getUniqueID());
		this.name = name;
		this.debuggingInfo = new StringBuffer();
		this.arguments = new HashMap();
		this.status = STATUS_NONE;
	}

	private static int sid = 0;

	private synchronized int getUniqueID() {
		sid += ID_RANDOM_INCREMENT_LIMIT * Math.random();
		return sid;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setArgv(List argv) {
		this.argv = argv;
	}

	public synchronized List getArgv() {
		if (argv == null) {
			argv = new ArrayList();
		}
		return argv;
	}

	public synchronized void addArgs(List args) {
		getArgv().addAll(args);
	}

	public synchronized void addArg(String arg) {
		getArgv().add(arg);
	}

	public abstract void addArg(String name, Object value);

	public void register(HttpSession session) {
		Map workflows = Workflows.getWorkflows(session);
		synchronized (workflows) {
			workflows.put(id, this);
		}
	}

	public abstract void start();

	public void unregister(HttpSession session) {
		Map workflows = Workflows.getWorkflows(session);
		synchronized (workflows) {
			workflows.remove(id);
		}
	}

	public abstract void cancel();

	public String getID() {
		return id;
	}

	public boolean isFinished() {
		updateStatus();
		return status != STATUS_NONE && status != STATUS_RUNNING;
	}

	public Exception getException() {
		return exception;
	}

	public boolean isFailed() {
		updateStatus();
		return status == STATUS_FAILED;
	}

	protected abstract void updateStatus();

	protected void setException(Exception exception) {
		this.exception = exception;
	}

	public double getProgress() {
		return progress;
	}

	protected void setProgress(double progress) {
		this.progress = progress;
	}

	public String getContinuation() {
		return continuation;
	}

	public void setContinuation(String continuation) {
		this.continuation = continuation;
	}

	public abstract String getSTDERR();

	protected void debug(String message) {
		debuggingInfo.append(message);
		debuggingInfo.append('\n');
	}

	public String getDebuggingInfo() {
		return debuggingInfo.toString();
	}

	public void initializeFromElabTR(ElabTransformation et) {
		Derivation dv = et.getDV();
		Iterator i = dv.getPassList().iterator();
		while (i.hasNext()) {
			Pass p = (Pass) i.next();
			Value v = p.getValue();
			if (v instanceof Scalar) {
				addArg(p.getBind(), leafValue((Scalar) v, et));
			}
			else if (v instanceof org.griphyn.vdl.classes.List) {
				List value = new LinkedList();
				org.griphyn.vdl.classes.List l = (org.griphyn.vdl.classes.List) v;
				Iterator j = l.iterateScalar();
				while (j.hasNext()) {
					Scalar s = (Scalar) j.next();
					value.add(leafValue(s, et));
				}
				addArg(p.getBind(), value);
			}
			else {
				throw new IllegalArgumentException("Unknown dv arg type: " + v);
			}
		}
	}

	protected String leafValue(Scalar scalar, ElabTransformation et) {
		Leaf leaf = scalar.getLeaf(0);
		if (leaf instanceof Text) {
			String content = ((Text) leaf).getContent();
			return content;
		}
		else if (leaf instanceof LFN) {
			LFN lfn = (LFN) leaf;
			int l = lfn.getLink();
			String value;
			if (l == LFN.OUTPUT || l == LFN.INOUT) {
				value = lfn.getTemporary();
				if (value == null) {
					// this is a yet another hack. SingleChannel seems to be
					// able to
					// extract multiple channels from one input file. Yet, the
					// parameter
					// used for that is a string instead of an array. This will
					// obviously break
					// in the case of files with spaces
					if (lfn.getFilename().indexOf(' ') != -1) {
						StringTokenizer st = new StringTokenizer(lfn.getFilename(), " ");
						StringBuffer sb = new StringBuffer();
						while (st.hasMoreTokens()) {
							File f = new File(st.nextToken());
							if (f.isAbsolute()) {
								sb.append(f.getAbsolutePath());
							}
							else {
								sb.append(new File(et.getOutputDir(), f.getPath()).getAbsolutePath());
							}
							sb.append(' ');
						}
						value = sb.toString();
					}
					else {
						// this is not the right way to do things!
						File f = new File(lfn.getFilename());
						if (!f.isAbsolute()) {
							// only do the output dir thing of the filename is
							// not
							// absolute
							// there is some kind of oddity in the way the
							// cosmic
							// code handles
							// the concept of a LFN
							value = new File(et.getOutputDir(), lfn.getFilename()).getAbsolutePath();
						}
						else {
							value = lfn.getFilename();
						}
					}
				}
			}
			else {
				value = lfn.getFilename();
				File f = new File(value);
				if (!f.isAbsolute()) {
					value = new File(System.getProperty("portal.datadir"), value).getAbsolutePath();
				}
			}
			return value;
		}
		else {
			throw new IllegalArgumentException("Unknown leaf type " + leaf.getClass());
		}
	}

	protected synchronized void setStatus(int status) {
		this.status = status;
	}

	public int getStatus() {
		try {
			updateStatus();
		}
		catch (Exception e) {
			System.err.println("Failed to update status");
			e.printStackTrace();
		}
		return status;
	}

	public static abstract class Template {
		private String name;
		private Workflows workflows;

		protected Template(String name) {
			this.name = name;
		}

		public String getName() {
			return name;
		}

		public Workflow newInstance() {
			return newInstance(Collections.EMPTY_LIST);
		}

		public abstract Workflow newInstance(List argv);
	}

	public synchronized void setAttribute(String name, Object value) {
		if (attributes == null) {
			attributes = new HashMap();
		}
		attributes.put(name, value);
	}

	public synchronized Object getAttribute(String name) {
		if (attributes == null) {
			return null;
		}
		else {
			return attributes.get(name);
		}
	}
}
