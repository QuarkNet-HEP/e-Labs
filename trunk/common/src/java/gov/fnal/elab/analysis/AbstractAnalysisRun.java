/*
 * Created on Apr 19, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;

import java.io.File;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public abstract class AbstractAnalysisRun implements AnalysisRun {
    private ElabAnalysis analysis;
    private Elab elab;
    private Throwable exception;
    private int status;
    private String id, outputDir, outputDirURL;
    private static int sid = 0;
    private Map attributes;
    private Date startTime, endTime;

    public AbstractAnalysisRun(ElabAnalysis analysis, Elab elab,
            String outputDir) {
        this.analysis = analysis;
        this.elab = elab;
        this.outputDir = outputDir;
        this.status = STATUS_NONE;
        synchronized (AnalysisRun.class) {
            this.id = String.valueOf(sid++);
        }
    }

    public Throwable getException() {
        return exception;
    }

    public void setException(Throwable t) {
        this.exception = t;
    }

    public String getId() {
        return id;
    }

    public double getProgress() {
        return 0;
    }

    public String getSTDERR() {
        return "";
    }

    public int getStatus() {
        updateStatus();
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public boolean isFailed() {
        return status == STATUS_FAILED;
    }

    public boolean isFinished() {
        return status == STATUS_FAILED || status == STATUS_COMPLETED;
    }

    public void updateStatus() {
    }

    public synchronized Object getAttribute(String name) {
        if (attributes == null) {
            return null;
        }
        else {
            return attributes.get(name);
        }
    }

    public synchronized void setAttribute(String name, Object value) {
        if (attributes == null) {
            attributes = new HashMap();
        }
        attributes.put(name, value);
    }

    public Map getAttributes() {
        return Collections.unmodifiableMap(attributes);
    }

    public ElabAnalysis getAnalysis() {
        return analysis;
    }

    public Elab getElab() {
        return elab;
    }

    public String getOutputDir() {
        return outputDir;
    }

    public String getOutputDirURL() {
        return outputDirURL;
    }

    public void setOutputDir(String outputDir) {
        this.outputDir = outputDir;
    }

    public void setOutputDirURL(String outputDirURL) {
        this.outputDirURL = outputDirURL;
    }

    protected void delete(File f) {
        if (f.isDirectory()) {
            File s[] = f.listFiles();
            if (s.length == 0) {
                f.delete();
            }
            else {
                for (int i = 0; i < s.length; i++) {
                    delete(s[i]);
                }
            }
        }
        else {
            f.delete();
        }
    }

    protected void finalize() throws Throwable {
        try {
            // cleaning up the output dir
            File rd = new File(getOutputDir());
            delete(rd);
        }
        catch (Exception e) {
            // we were cleaning up
        }
        super.finalize();
    }

    public Date getStartTime() {
        return startTime;
    }

    protected void setStartTime(Date startTime) {
        this.startTime = startTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    protected void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public String getFormattedRunTime() {
        if (endTime != null) {
            return TimeIntervalFormatter.format(startTime, endTime);
        }
        else {
            return TimeIntervalFormatter.format(startTime, new Date());
        }
    }

    public String getFormattedEstimatedRunTime() {
        Integer est = (Integer) getAttribute("estimatedTime");
        if (est != null) {
            return TimeIntervalFormatter.format(est.intValue() * 1000);
        }
        else {
            return "-";
        }
    }
}
