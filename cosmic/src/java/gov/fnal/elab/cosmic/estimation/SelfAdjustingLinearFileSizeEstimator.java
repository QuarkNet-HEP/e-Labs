/*
 * Created on Aug 27, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.cosmic.estimation.HistoricData.Parameters;
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.estimation.EstimationHistoryTracker;
import gov.fnal.elab.estimation.Estimator;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

public class SelfAdjustingLinearFileSizeEstimator implements Estimator {
    private Parameters guess;
    private String type, mode;
    
    /** Number of computing processors on the target machine **/
    private int p;
    /**
     * E(p) = S(p) / p
     * S(p) = T1 / Tp
     * 
     * so
     * 
     * Tp = T1 / S(p) = T1 / (p * E(p))
     */
    private double efficiency;
    
    /**
     * The estimated curve is a*sz + b and is in milliseconds, where sz is the file size.
     */
    public SelfAdjustingLinearFileSizeEstimator(String type, String mode, double aguess, double bguess, int cores, double efficiency) {
        this.guess = new Parameters(aguess, bguess);
        this.type = type;
        this.mode = mode;
        this.p = cores;
        this.efficiency = efficiency;
    }

    public int estimate(Elab elab, ElabAnalysis analysis) throws ElabException {
        HistoricData.Parameters p = HistoricData.instance().getParameters(type, mode, guess);
        analysis.setAttribute(EstimationHistoryTracker.KEY, HistoricData.instance());
        
        @SuppressWarnings("unchecked")
        Collection<String> rd = (Collection<String>) analysis.getParameter("rawData");
        long sz = AnalysisParameterTools.getCombinedFileSizes(elab, rd);
        
        // single core time
        double T1 = p.a * sz + p.b;
        //
        // There are no more than p cores, but less would be utilized if there are fewer files since
        // swift will parallelize based on the input files.
        //
        int actualP = Math.min(this.p, rd.size());
        double Tp = T1 / (actualP * efficiency);
        
        return (int) (Tp / 1000);
    }
}
