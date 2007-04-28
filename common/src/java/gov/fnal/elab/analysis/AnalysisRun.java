/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis;



public interface AnalysisRun {
    public static final int STATUS_NONE = 0;
    public static final int STATUS_RUNNING = 1;
    public static final int STATUS_COMPLETED = 2;
    public static final int STATUS_FAILED = 3;
    public static final int STATUS_CANCELED = 4;
    
    void start();

    void cancel();

    String getId();
        
    boolean isFinished();

    Throwable getException();
        
    boolean isFailed();
        
    void updateStatus();

    double getProgress();

    String getSTDERR();

    String getDebuggingInfo();

    int getStatus();
    
    String getOutputDir();
    
    String getOutputDirURL();
    
    void setAttribute(String name, Object value);
    
    Object getAttribute(String name);
    
    ElabAnalysis getAnalysis();
}
