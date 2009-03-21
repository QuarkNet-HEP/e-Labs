/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.util.ElabException;

public interface Estimator {
    public int estimate(Elab elab, ElabAnalysis analysis)
            throws ElabException;
}