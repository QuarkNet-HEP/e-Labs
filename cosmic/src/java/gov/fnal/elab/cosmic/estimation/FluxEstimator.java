package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.Elab;
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.estimation.Estimator;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;

/**
 * 
 * time = a + b * ev[c] + c * ev[c] * ln(ev[c])
 * 
 */
public class FluxEstimator implements Estimator {
    private double a, b, c;

    public FluxEstimator(double a, double b, double c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }

    public synchronized int estimate(Elab elab, ElabAnalysis analysis) throws ElabException {
        Collection rd = (Collection) analysis.getParameter("rawData");
        String channel = (String) analysis.getParameter("singlechannel_channel");
        int events = AnalysisParameterTools.getEventCount(elab, rd, Integer.parseInt(channel));
        double ms = a + b * events + c * events * Math.log(events);

        return (int) (ms / 1000);
    }
}