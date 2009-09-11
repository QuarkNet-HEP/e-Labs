/*
 * Created on Aug 27, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.cosmic.estimation.HistoricData.Parameters;
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.estimation.Estimator;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

public class SelfAdjustingLinearEventEstimator implements Estimator {
    private Parameters guess;
    private String type, mode;
    
    public SelfAdjustingLinearEventEstimator(String type, String mode, double aguess, double bguess) {
        this.guess = new Parameters(aguess, bguess);
        this.type = type;
        this.mode = mode;
    }

    public int estimate(Elab elab, ElabAnalysis analysis) throws ElabException {
        HistoricData.Parameters p = HistoricData.instance().getParameters(type, mode, guess);
        
        Collection rd = (Collection) analysis.getParameter("rawData");
        int events = AnalysisParameterTools.getEventCount(elab, rd);
        double ms = p.a * events + p.b;
        
        return (int) (ms / 1000);
    }
}
