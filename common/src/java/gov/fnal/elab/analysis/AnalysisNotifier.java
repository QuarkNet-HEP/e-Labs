/*
 * Created on Feb 27, 2010
 */
package gov.fnal.elab.analysis;


public interface AnalysisNotifier extends AnalysisRunListener  {
    void setRun(AnalysisRun run);
}
