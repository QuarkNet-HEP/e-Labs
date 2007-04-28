/*
 * Created on Apr 18, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabUser;

public interface AnalysisExecutor {
    AnalysisRun start(ElabAnalysis analysis, Elab elab, ElabUser user);
}
