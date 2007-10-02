/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis.impl.swift;

import gov.fnal.elab.Elab;
import gov.fnal.elab.RawDataFileResolver;
import gov.fnal.elab.analysis.AbstractAnalysisRun;
import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.ProgressTracker;

import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.globus.cog.karajan.SpecificationException;
import org.globus.cog.karajan.stack.LinkedStack;
import org.globus.cog.karajan.stack.VariableStack;
import org.globus.cog.karajan.workflow.ElementTree;
import org.globus.cog.karajan.workflow.nodes.FlowElement;
import org.griphyn.vdl.karajan.Loader;
import org.griphyn.vdl.karajan.VDL2ExecutionContext;
import org.griphyn.vdl.karajan.functions.ConfigProperty;
import org.griphyn.vdl.util.VDL2Config;

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

    public AnalysisRun createRun(ElabAnalysis analysis, Elab elab,
            String outputDir) {
        Run run = new Run(analysis, elab, outputDir);
        return run;
    }

    private static ProgressTracker pTracker = new ProgressTracker();

    public class Run extends AbstractAnalysisRun implements Serializable {
        private String runDir, runDirUrl;
        private volatile transient double progress;
        private VDL2ExecutionContext ec;
        private OutputChannel out;

        protected Run(ElabAnalysis analysis, Elab elab, String outputDir) {
            super(analysis, elab, outputDir);
        }

        public synchronized void start() {
            try {
                List argv = getArgv();
                String projectName = getAnalysis().getType();
                String project = projectName + ".swift";

                String egd = System.getProperty("java.security.egd");
                if ("Linux".equals(System.getProperty("os.name"))) {
                    System
                            .setProperty("java.security.egd",
                                    "file:/dev/urandom");
                }
                String runID = Loader.getUUID();
                if (egd != null) {
                    // oddly enough, there is no way to remove a system property
                    System.setProperty("java.security.egd", egd);
                }

                ElementTree tree = getTree(getElab(), project);
                tree.setName(projectName + "-" + runID);
                tree.getRoot().setProperty(FlowElement.FILENAME, project);
                ec = new VDL2ExecutionContext(tree, projectName);
                ec.setArguments(argv);
                out = new OutputChannel(runID);
                out.setPattern("Running job");
                ec.setStderr(out);
                ec.setStdout(out);
                ec.setRunID(runID);
                out.append("Arguments: \n");
                Iterator i = argv.iterator();
                while (i.hasNext()) {
                    out.append("  " + i.next() + "\n");
                }
                VariableStack stack = new LinkedStack(ec);

                VDL2Config conf = VDL2Config.getConfig(getElab()
                        .getAbsolutePath("/WEB-INF/classes/swift.properties"));
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
                    conf.setProperty("sites.file", getElab().getAbsolutePath(
                            "/WEB-INF/classes")
                            + File.separator
                            + "etc"
                            + File.separator
                            + poolFile);
                }
                String home = getElab().getAbsolutePath("/WEB-INF/classes");
                System.setProperty("swift.home", home);
                stack.setGlobal(ConfigProperty.INSTANCE_CONFIG, conf);
                stack.setGlobal("swift.home", home);
                stack.setGlobal("vds.home", home);
                stack.setGlobal("vdl:operation", "run");

                createRunDir();
                ec.setCwd(runDir);

                ec.start(stack);
                setStatus(STATUS_RUNNING);
            }
            catch (Exception e) {
                e.printStackTrace();
                setException(e);
                setStatus(STATUS_FAILED);
            }
        }

        private void createRunDir() throws IOException {
            runDir = getOutputDir();
            File rdf = new File(runDir);
            rdf.mkdirs();
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

        public void updateStatus() {
            if (ec == null) {
                return;
            }
            else if (ec.done()) {
                if (ec.isFailed()) {
                    if (ec.getFailure() == null) {
                        setException(new Exception(getStdErrStuff()));
                    }
                    else {
                        setException(ec.getFailure());
                    }
                    setStatus(STATUS_FAILED);
                }
                else {
                    System.out.println("Execution time: "
                            + (ec.getEndTime() - ec.getStartTime()) + "ms");
                    pTracker.setTotal(getAnalysis().getType(), out
                            .getPatternCounter());
                    File[] f = new File(runDir).listFiles(new FileFilter() {
                        public boolean accept(File pathname) {
                            return pathname.getName().endsWith(".dot");
                        }
                    });
                    if (f.length != 1) {
                        System.out.println(f.length
                                + " .dot files found. Only one was expected.");
                    }
                    else {
                        f[0].renameTo(new File(runDir, "dv.dot"));
                    }
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

        protected String getStdErrStuff() {
            StringBuffer sb = new StringBuffer();
            String s = out.toString();
            StringTokenizer st = new StringTokenizer(s, "\n");
            boolean on = false;
            while (st.hasMoreTokens()) {
                String line = st.nextToken().trim();
                if (line.startsWith("STDOUT:")) {
                    on = false;
                }
                else if (line.startsWith("STDERR: ")) {
                    on = true;
                    line = line.substring("STDERR: ".length());
                }
                if (on) {
                    sb.append(line);
                    sb.append('\n');
                }
            }
            return sb.toString();
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
