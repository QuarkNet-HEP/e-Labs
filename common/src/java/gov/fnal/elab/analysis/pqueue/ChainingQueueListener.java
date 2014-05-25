/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.AnalysisRunListener;

public class ChainingQueueListener implements AnalysisRunListener {
    private final AnalysisRunListener previous;
    private final DefaultAnalysisQueue queue;
    private final AnalysisRun run;
    
    public ChainingQueueListener(DefaultAnalysisQueue queue, AnalysisRunListener previous, AnalysisRun run) {
        this.queue = queue;
        this.previous = previous;
        this.run = run;
    }

    @Override
    public void runStatusChanged(int status) {
        switch (status) {
            case AnalysisRun.STATUS_CANCELED:
            case AnalysisRun.STATUS_COMPLETED:
            case AnalysisRun.STATUS_FAILED:
                queue.runTerminated(run);
        }
        previous.runStatusChanged(status);
    }
}
