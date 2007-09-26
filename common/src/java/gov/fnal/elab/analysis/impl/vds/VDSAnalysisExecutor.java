/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis.impl.vds;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.analysis.AbstractAnalysisRun;
import gov.fnal.elab.analysis.AnalysisExecutor;
import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.BeanWrapper;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.ProgressTracker;
import gov.fnal.elab.beans.MappableBean;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.vds.ElabTransformation;

import java.io.File;
import java.io.RandomAccessFile;
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

/**
 * Runs analyses with VDS. Yay!
 */
public class VDSAnalysisExecutor implements AnalysisExecutor {

    public AnalysisRun start(ElabAnalysis analysis, Elab elab, ElabGroup user) {
        Run run = new Run(analysis, elab, user);
        run.start();
        return run;
    }

    public static ElabTransformation createTransformation(String name,
            ElabAnalysis analysis, ElabGroup user) throws ElabException {
        ElabTransformation et = new ElabTransformation(analysis.getType());
        String runDir = user.getDir("scratch");
        et.generateOutputDir(runDir);
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
        private volatile transient double progress;

        public Run(ElabAnalysis analysis, Elab elab, ElabGroup user) {
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
            return progress;
        }

        public void setProgress(double progress) {
            this.progress = progress;
        }

        public void start() {
            try {
                et = createTransformation(null, getAnalysis(), getUser());
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
            RunMonitor r = new RunMonitor(this);
            r.start();
            try {
                Elab elab = getElab();
                ElabRC.setDataDir(elab.getProperties().getDataDir());
                et.run();
                et.dump();
                et.close();
                r.complete();
                setStatus(STATUS_COMPLETED);
            }
            catch (Throwable t) {
                r.complete();
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
            return getUser().getDirURL(
                    "scratch" + File.separator + et.getOutputDirName());
        }
    }

    private static ProgressTracker pTracker = new ProgressTracker();
    
    private class RunMonitor extends Thread {
        private Run run;
        private boolean completed;

        public RunMonitor(Run run) {
            this.run = run;
        }
        
        public void complete() {
            completed = true;
        }

        public void run() {
            try {
                System.out.println("Starting run monitor");
                int ticks = 20;
                File f = new File(run.getOutputDir(), "run.log");
                while (!f.exists()) {
                    Thread.sleep(250);
                    ticks--;
                    if (ticks == 0) {
                        System.out.println("RunMonitor: did not see run.log file");
                        return;
                    }
                }
                System.out.println("Run log found");
                int total = pTracker.getTotal(run.getAnalysis().getType());
                int counted = 0;
                RandomAccessFile raf = new RandomAccessFile(f, "r");
                long pos = raf.getFilePointer();
                int c = raf.read();
                while (!completed) {
                    if (c == -1) {
                        while (pos >= raf.length()) {
                            Thread.sleep(250);
                        }
                        raf.seek(pos);
                    }
                    else if (c == '\n') {
                        counted++;
                        if (total > 0) {
                            run.setProgress(((double) counted) / total);
                        }
                    }
                    pos = raf.getFilePointer();
                    c = raf.read();
                }
                System.out.println("Run monitor finished");
                if (total <= 0) {
                    pTracker.setTotal(run.getAnalysis().getType(), counted);
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
