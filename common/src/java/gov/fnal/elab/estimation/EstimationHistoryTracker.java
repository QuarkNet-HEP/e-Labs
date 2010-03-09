/*
 * Created on Mar 9, 2010
 */
package gov.fnal.elab.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.AnalysisRun;

public interface EstimationHistoryTracker {
    public static final String KEY = "estimationTracker";

    void add(Elab elab, AnalysisRun run);
}
