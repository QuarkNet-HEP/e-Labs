package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.estimation.Estimator;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

/**
 * 
 * time = a * events + b
 * 
 */
public class LinearEventEstimator implements Estimator {
    private double a, b;

    public LinearEventEstimator(double a, double b) {
        this.a = a;
        this.b = b;
    }

    public synchronized int estimate(Elab elab, ElabAnalysis analysis)
            throws ElabException {
        Collection rd = (Collection) analysis.getParameter("rawData");
        int events = AnalysisParameterTools.getEventCount(elab, rd);
        double ms = a * events + b;
        
        return (int) (ms / 1000);
    }
}