/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;

import java.util.Collection;

public interface AnalysisQueue {
    void add(AnalysisRun run);
    
    Collection<AnalysisRun> getQueued();
    Collection<AnalysisRun> getRunning();
}
