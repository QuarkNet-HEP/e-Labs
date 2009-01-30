/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis;

import java.util.Date;
import java.util.Map;

/**
 * Encapsulates information about the execution of an analysis. An
 * {@link AnalysisExecutor} would typically return a specific
 * implementation of this interface which would be linked to the executor that
 * created it.
 */
public interface AnalysisRun {
    /**
     * Indicates that this run has not been started yet
     */
    public static final int STATUS_NONE = 0;

    /**
     * Indicates that this run is in progress
     */
    public static final int STATUS_RUNNING = 1;

    /**
     * Indicates that the run has completed successfully
     */
    public static final int STATUS_COMPLETED = 2;

    /**
     * Indicates that a run has completed in a failure
     */
    public static final int STATUS_FAILED = 3;

    /**
     * Indicates a user-cancelled run
     */
    public static final int STATUS_CANCELED = 4;

    /**
     * Starts this run.
     */
    void start();
    
    /**
     * Cancels this run.
     */
    void cancel();

    /**
     * Returns the ID of this run
     */
    String getId();

    /**
     * Returns <code>true</code> if this run has finished (either successfully
     * or not).
     */
    boolean isFinished();

    /**
     * If the run has failed, this method MAY return an exception detailing the
     * causes of the failure.
     */
    Throwable getException();

    /**
     * Returns <code>true</code> if this run has failed.
     */
    boolean isFailed();

    /**
     * Ensures that calls to any of the status information methods (such as
     * <code>isCompleted</code>, <code>getProgress</code>, etc.) do not
     * reflect a state that is older than time when this method is called.
     */
    void updateStatus();

    /**
     * Retrieves the progress of this run.
     * 
     * @return a double value, in the [0.0, 1.0] interval
     */
    double getProgress();

    /**
     * Returns possible error messages that were produced during the run.
     */
    String getSTDERR();

    /**
     * Returns possible log messages that were produced during the run.
     */
    String getDebuggingInfo();

    /**
     * Returns the status of this run
     * 
     * @return an int with one of the following possible values:
     *         <code>STATUS_NONE</code>, <code>STATUS_RUNNING</code>,
     *         <code>STATUS_COMPLETED</code>, <code>STATUS_FAILED</code>,
     *         or <code>STATUS_CANCELED</code>
     */
    int getStatus();

    /**
     * Returns the directory in which files produced by this run were created.
     */
    String getOutputDir();

    /**
     * Returns a URL poiting to a directory in which files produced by this run
     * were created. I'm a little fuzzy about why this such functionality should
     * exist here.
     */
    String getOutputDirURL();
    
    /**
     * Allows setting of the output dir URL
     */
    void setOutputDirURL(String outputDirURL);

    /**
     * Sets a custom attribute on this object
     */
    void setAttribute(String name, Object value);

    /**
     * Retrieves the value of a custom attribute that was set on this object
     */
    Object getAttribute(String name);
    
    /**
     * Make JSP happy
     */
    Map getAttributes();

    /**
     * Returns the analysis that this run is executing.
     */
    ElabAnalysis getAnalysis();
    
    Date getStartTime();
    
    Date getEndTime();
    
    String getFormattedRunTime();
    
    String getFormattedEstimatedRunTime();
}
