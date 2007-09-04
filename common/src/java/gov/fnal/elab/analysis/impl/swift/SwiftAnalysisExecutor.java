/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis.impl.swift;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.analysis.AbstractAnalysisRun;
import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.ProgressTracker;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.globus.cog.karajan.SpecificationException;
import org.globus.cog.karajan.stack.LinkedStack;
import org.globus.cog.karajan.stack.VariableStack;
import org.globus.cog.karajan.workflow.ElementTree;
import org.globus.cog.karajan.workflow.ExecutionContext;
import org.globus.cog.karajan.workflow.nodes.FlowElement;
import org.griphyn.vdl.karajan.Loader;
import org.griphyn.vdl.karajan.VDL2ExecutionContext;
import org.griphyn.vdl.karajan.functions.ConfigProperty;

/**
 * Runs analyses with Swift. Doble Yay!
 */
public class SwiftAnalysisExecutor implements AnalysisExecutor {
    private static final Map trees, progress;

    static {
        trees = new HashMap();
        progress = new HashMap();
    }

    protected synchronized static ElementTree getTree(Elab elab, String file)
            throws SpecificationException, IOException, Exception {
        DatedTree tree;
        tree = (DatedTree) trees.get(file);
        if (tree == null) {
            tree = new DatedTree(elab, file);
            trees.put(file, tree);
        }
        tree.update();
        return tree.getElementTree();
    }

    public AnalysisRun start(ElabAnalysis analysis, Elab elab, ElabGroup user) {
        Run run = new Run(analysis, elab, user);
        run.start();
        return run;
    }

    private static ProgressTracker pTracker = new ProgressTracker();

    public class Run extends AbstractAnalysisRun implements Serializable {
        private String runDirURL;
        private volatile transient double progress;
        private ExecutionContext ec;
        private OutputChannel out;

        protected Run(ElabAnalysis analysis, Elab elab, ElabGroup user) {
            super(analysis, elab, user);
        }

        public synchronized void start() {
            try {
                List argv = getArgv();
                String projectName = getAnalysis().getType();
                String project = projectName + ".swift";

                String runID = Loader.getUUID();

                ElementTree tree = getTree(getElab(), project);
                tree.setName(projectName + "-" + runID);
                tree.getRoot().setProperty(FlowElement.FILENAME, project);
                ec = new VDL2ExecutionContext(tree, projectName);
                ec.setArguments(argv);
                out = new OutputChannel(runID);
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
                String home = getElab().getAbsolutePath("/WEB-INF/classes");
                System.setProperty("swift.home", home);
                stack.setGlobal(ConfigProperty.INSTANCE_CONFIG_FILE, getElab()
                        .getAbsolutePath("/WEB-INF/classes/swift.properties"));
                stack.setGlobal("swift.home", home);
                stack.setGlobal("vds.home", home);
                stack.setGlobal("vdl:operation", "run");
                stack.setGlobal("VDL:RUNID", runID);

                ec.start(stack);
                setStatus(STATUS_RUNNING);
            }
            catch (Exception e) {
                e.printStackTrace();
                setException(e);
                setStatus(STATUS_FAILED);
            }
        }

        private List getArgv() {
            List argv = new ArrayList();
            Iterator i = getAnalysis().getParameters().entrySet().iterator();
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
                argv.add("-" + name + "=" + s.replaceAll("\r\n?", "\\n"));
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
                sb.append(String.valueOf(i.next()));
                if (i.hasNext()) {
                    sb.append(',');
                }
            }
            argv.add("-" + name + "=" + sb.toString());
        }

        public void cancel() {
            setStatus(STATUS_CANCELED);
        }

        public String getDebuggingInfo() {
            return "";
        }

        public String getSTDERR() {
            if (out != null) {
                return out.toString();
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

        public String getOutputDir() {
            return null;
        }

        public String getOutputDirURL() {
            return null;
        }

        public void updateStatus() {
            if (ec == null) {
                return;
            }
            else if (ec.done()) {
                if (ec.isFailed()) {
                    setException(ec.getFailure());
                    setStatus(STATUS_FAILED);
                }
                else {
                    System.out.println("Execution time: "
                            + (ec.getEndTime() - ec.getStartTime()) + "ms");
                    pTracker.setTotal(getAnalysis().getType(), out
                            .getPatternCounter());
                    setStatus(STATUS_COMPLETED);
                }
            }
            else {
                int total = pTracker.getTotal(getAnalysis().getType());
                if (total != -1) {
                    setProgress(((double) out.getPatternCounter()) / total);
                }
            }
        }
    }

    public static class DatedTree {
        private ElementTree elementTree;
        private File file;
        private long modified;
        private Elab elab;

        public DatedTree(Elab elab, String file) {
            this.elab = elab;
            this.file = new File(file);
            if (!this.file.isAbsolute()) {
                this.file = new File(elab.getProperties().getProperty(
                        "swift.workflow.dir"), file);
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

        public synchronized void update() throws SpecificationException,
                IOException, Exception {
            if (!file.exists()) {
                throw new FileNotFoundException(file.getAbsolutePath());
            }
            if (modified < file.lastModified()) {
                elementTree = Loader.load(Loader
                        .compile(file.getAbsolutePath()));
                modified = file.lastModified();
            }
        }

        public ElementTree getElementTree() {
            return elementTree;
        }
    }
}
