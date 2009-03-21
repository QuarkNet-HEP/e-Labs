/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis.impl.shell;

import gov.fnal.elab.Elab;
import gov.fnal.elab.RawDataFileResolver;
import gov.fnal.elab.analysis.AbstractAnalysisRun;
import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.analysis.AnalysisParameterTransformer;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.NullAnalysisParameterTransformer;
import gov.fnal.elab.analysis.ProgressTracker;

import java.io.CharArrayWriter;
import java.io.File;
import java.io.PrintWriter;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.globus.cog.abstraction.impl.common.AbstractionFactory;
import org.globus.cog.abstraction.impl.common.StatusEvent;
import org.globus.cog.abstraction.impl.common.task.JobSpecificationImpl;
import org.globus.cog.abstraction.impl.common.task.TaskImpl;
import org.globus.cog.abstraction.interfaces.FileLocation;
import org.globus.cog.abstraction.interfaces.JobSpecification;
import org.globus.cog.abstraction.interfaces.Status;
import org.globus.cog.abstraction.interfaces.StatusListener;
import org.globus.cog.abstraction.interfaces.Task;
import org.globus.cog.abstraction.interfaces.TaskHandler;

/**
 * Runs analyses with Swift. Doble Yay!
 */
public class ShellAnalysisExecutor implements AnalysisExecutor {
    private static final Map progress;

    static {
        progress = new HashMap();
    }

    public AnalysisRun createRun(ElabAnalysis analysis, Elab elab,
            String outputDir) {
        Run run = new Run(analysis, elab, outputDir);
        return run;
    }

    private static ProgressTracker pTracker = new ProgressTracker();

    public class Run extends AbstractAnalysisRun implements Serializable, StatusListener {
        private Task task;
        private volatile transient double progress;
        private boolean updated;

        protected Run(ElabAnalysis analysis, Elab elab, String outputDir) {
            super(analysis, elab, outputDir);
        }

        public synchronized void start() {
            setStartTime(new Date());
            try {
                List argv = getArgv();
                String name = getAnalysis().getType();
                
                task = new TaskImpl();
                task.setType(Task.JOB_SUBMISSION);
                JobSpecification js = new JobSpecificationImpl();
                js.setExecutable(getElab().getProperties().getProperty("app.dir") + "/" + name);
                js.setArguments(argv);
                js.setStdOutputLocation(FileLocation.MEMORY);
                js.setStdErrorLocation(FileLocation.MEMORY);
                task.setSpecification(js);
                task.addStatusListener(this);
                
                TaskHandler th = AbstractionFactory.newExecutionTaskHandler("local");
                th.submit(task);
                
                setStatus(STATUS_RUNNING);
            }
            catch (Exception e) {
                e.printStackTrace();
                setException(e);
                setStatus(STATUS_FAILED);
            }
        }

        private List getArgv() {
            AnalysisParameterTransformer tr = getAnalysis()
                    .getParameterTransformer();
            if (tr == null) {
                tr = new NullAnalysisParameterTransformer();
            }
            List argv = new ArrayList();
            Iterator i = tr.transform(getAnalysis().getParameters()).entrySet()
                    .iterator();
            while (i.hasNext()) {
                Map.Entry e = (Map.Entry) i.next();
                addArg(argv, (String) e.getKey(), e.getValue());
            }
            return argv;
        }

        protected void addArg(List argv, String name, Integer value) {
            argv.add("-" + name + "=" + value);
        }

        public void addArg(List argv, String name, Object value) {
            if (value instanceof Integer) {
                addArg(argv, name, (Integer) value);
            }
            else if (value instanceof String) {
                String s = (String) value;
                s = resolve(s);
                argv.add("-" + name + "=" + s.replaceAll("\r\n?", "\\\\n"));
            }
            else if (value instanceof Collection) {
                addArg(argv, name, (Collection) value);
            }
            else {
                throw new IllegalArgumentException(
                        "Unexpected type of argument ("
                                + (value == null ? "null" : value.getClass()
                                        .toString()) + ") for " + name);
            }
        }

        protected void addArg(List argv, String name, Collection values) {
            StringBuffer sb = new StringBuffer();
            Iterator i = values.iterator();
            while (i.hasNext()) {
                sb.append(resolve(String.valueOf(i.next())));
                if (i.hasNext()) {
                    sb.append(',');
                }
            }
            argv.add("-" + name + "=" + sb.toString());
        }

        protected String resolve(String maybeAFile) {
            if (maybeAFile == null || maybeAFile.equals("")) {
                return maybeAFile;
            }
            File f = new File(RawDataFileResolver.getDefault().resolve(
                    getElab(), maybeAFile));
            if (f.exists() && f.isFile()) {
                return f.getAbsolutePath();
            }
            else {
                return maybeAFile;// or maybe not
            }
        }

        public void cancel() {
            setStatus(STATUS_CANCELED);
        }

        public String getDebuggingInfo() {
            if (getException() != null) {
            	CharArrayWriter caw = new CharArrayWriter();
            	PrintWriter pr = new PrintWriter(caw);
            	getException().printStackTrace(pr);
            	return caw.toString();
            }
            else {
            	return "";
            }
        }

        public String getSTDERR() {
            if (task != null) {
                return task.getStdOutput();
            }
            else {
                return "";
            }
        }

        public double getProgress() {
            return progress;
        }

        public void setProgress(double progress) {
            this.progress = progress;
        }

        public void updateStatus() {
            
        }

        private void log(String stuff) {
            System.out.println(stuff + ", runid=-1, time="
                    + (getEndTime().getTime() - getStartTime().getTime())
                    + ", startTime=" + getStartTime().getTime()
                    + ", estimated=" + getAttribute("estimatedTime")
                    + ", type=" + getAnalysis().getType() + ", runMode=local");
        }

        protected String getStdErrStuff() {
            return task.getStdError();
        }

		public void statusChanged(StatusEvent e) {
			switch(e.getStatus().getStatusCode()) {
				case Status.ACTIVE:
					break;
				case Status.CANCELED:
					setStatus(STATUS_CANCELED);
					break;
				case Status.FAILED:
					Exception ex = e.getStatus().getException();
					if (ex == null) {
						ex = new Exception(e.getStatus().getMessage());
					}
					setException(ex);
					setStatus(STATUS_FAILED);
					break;
				case Status.COMPLETED:
					setStatus(STATUS_COMPLETED);
					break;
				default:
			}
		}
    }
}
