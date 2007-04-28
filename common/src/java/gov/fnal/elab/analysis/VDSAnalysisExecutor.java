/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabUser;
import gov.fnal.elab.beans.MappableBean;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.vds.ElabTransformation;

import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.griphyn.common.catalog.replica.ElabRC;

// TODO fix the dax2dot business:
/*
 * //FIXME This exists to clean out a bug in the DAX2DOT routine. cmd = new
 * String[] {"bash", "-c", "/usr/bin/perl -pi -e 's/^.*\"\".*$//g' " +
 * provenanceDir + "/dv.dot"};
 */
public class VDSAnalysisExecutor implements AnalysisExecutor {
    public AnalysisRun start(ElabAnalysis analysis, Elab elab, ElabUser user) {
        Run run = new Run(analysis, elab, user);
        run.start();
        return run;
    }

    public static ElabTransformation createTransformation(String name, ElabAnalysis analysis)
            throws ElabException {
        ElabTransformation et = new ElabTransformation(analysis.getType());
        if (name != null) {
            et.setDVName(name);
        }
        if (analysis instanceof BeanWrapper
                && ((BeanWrapper) analysis).getBean() instanceof MappableBean) {
            et.createDV((MappableBean) ((BeanWrapper) analysis).getBean());
        }
        else {
            et.createDV(new HashMap(analysis.getParameters()));
        }
        return et;
    }

    public class Run extends AbstractAnalysisRun implements Runnable,
            Serializable {
        private transient ElabTransformation et;
        private transient Thread thread;
        private String runDirURL;

        public Run(ElabAnalysis analysis, Elab elab, ElabUser user) {
            super(analysis, elab, user);
        }

        public void cancel() {
            thread.interrupt();
            setStatus(STATUS_CANCELED);
        }

        public String getDebuggingInfo() {
            return null;
        }

        public double getProgress() {
            return 0;
        }

        public void start() {
            try {
                et = createTransformation(null, getAnalysis());
                File scratch = new File(getElab().getName(), "scratch");
                String runDir = new File(getUser().getUserDir(), scratch
                        .getPath()).getAbsolutePath();
                et.generateOutputDir(runDir);
                List nulllist = et.getNullKeys();
                if (!nulllist.isEmpty()) {
                    StringBuffer sb = new StringBuffer();
                    sb
                            .append("There are still keys in the Transformation which must be defined:\n");
                    for (Iterator i = nulllist.iterator(); i.hasNext();) {
                        String ss = (String) i.next();
                        sb.append("null keys: " + ss + "\n");
                    }
                    sb.append("\n\nbailing out!");
                    throw new IllegalArgumentException(sb.toString());
                }
                thread = new Thread(this);
                thread.start();
                setStatus(STATUS_RUNNING);
            }
            catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        public void run() {
            try {
                Elab elab = getElab();
                ElabRC.setDataDir(elab.getProperties().getDataDir());
                et.run();
                et.dump();
                et.close();
                setStatus(STATUS_COMPLETED);
            }
            catch (Throwable t) {
                setException(t);
                setStatus(STATUS_FAILED);
                t.printStackTrace();
            }
        }

        public String getOutputDir() {
            if (et == null) {
                throw new IllegalStateException(
                        "getOutputDir() can only be called after start()");
            }
            return et.getOutputDir();
        }

        public String getOutputDirURL() {
            String root = getElab().getServletContext().getRealPath("/");
            String dir = et.getOutputDir();
            if (dir.startsWith(root)) {
                return "../../" + dir.substring(root.length());
            }
            else {
                return null;
            }
        }
    }
}
