/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.estimation.ConstantEstimator;
import gov.fnal.elab.estimation.EstimatorSet;

import java.util.HashMap;
import java.util.Map;

public class CosmicAnalysisRunTimeEstimatorSet extends EstimatorSet {
    
    private static final Map<String, Integer> CORES_MAP;
    private static final Map<String, Double> EFFICIENCY_MAP;
    
    static {
        CORES_MAP = new HashMap<String, Integer>();
        EFFICIENCY_MAP = new HashMap<String, Double>();
        
        CORES_MAP.put("local", Runtime.getRuntime().availableProcessors());
        //TODO Replace with actual core count in the cluster
        CORES_MAP.put("i2u2", 16);
        //TODO The model is probably broken in this case
        CORES_MAP.put("grid", 256);
        CORES_MAP.put("mixed", 300);
       
        /*
         * Empirically determined. Essentially there the slope of the runtime vs. file size fit 
         * for one raw data (m1) and the slope for the same when the analysis is run with two data
         * files (m2), and the efficiency is m2/m1
         */
        //TODO Guessed
        EFFICIENCY_MAP.put("local", 0.75);
        // Measured
        EFFICIENCY_MAP.put("i2u2", 0.75);
        //TODO Guessed
        EFFICIENCY_MAP.put("grid", 0.3);
        //TODO Guessed
        EFFICIENCY_MAP.put("mixed", 0.5);
    }
    
    public CosmicAnalysisRunTimeEstimatorSet() {
        // TODO Cluster values are measured on www13, the others are just the assumption
        // that the other machines have comparable hardware
        addSwiftFileSizeEstimator("local", "I2U2.Cosmic::PerformanceStudy", 0.002749625, /*TODO*/3483);
        addSwiftFileSizeEstimator("i2u2", "I2U2.Cosmic::PerformanceStudy", 0.002749625, 6000);
        addSwiftFileSizeEstimator("grid", "I2U2.Cosmic::PerformanceStudy", 0.002749625, /*TODO*/70351);
        addSwiftFileSizeEstimator("mixed", "I2U2.Cosmic::PerformanceStudy", 0.002749625, /*TODO*/3913);

        addSwiftFileSizeEstimator("local", "I2U2.Cosmic::LifetimeStudy", 0.003823715, /*TODO*/118000);
        addSwiftFileSizeEstimator("i2u2", "I2U2.Cosmic::LifetimeStudy", 0.003823715, 118000);
        addSwiftFileSizeEstimator("grid", "I2U2.Cosmic::LifetimeStudy", 0.003823715, /*TODO*/120000);
        addSwiftFileSizeEstimator("mixed", "I2U2.Cosmic::LifetimeStudy", 0.003823715, /*TODO*/4000);

        addSwiftFileSizeEstimator("local", "I2U2.Cosmic::FluxStudy", 0.001674764, /*TODO*/1000);
        addSwiftFileSizeEstimator("i2u2", "I2U2.Cosmic::FluxStudy", 0.001674764, 1000);
        addSwiftFileSizeEstimator("grid", "I2U2.Cosmic::FluxStudy", 0.001674764, /*TODO*/96000);
        addSwiftFileSizeEstimator("mixed", "I2U2.Cosmic::FluxStudy", 0.001674764, /*TODO*/9833);
        
        addSwiftFileSizeEstimator("local", "I2U2.Cosmic::ShowerStudy", 0.003932321, 1000);
        addSwiftFileSizeEstimator("i2u2", "I2U2.Cosmic::ShowerStudy", 0.003932321, 6000);
        addSwiftFileSizeEstimator("grid", "I2U2.Cosmic::ShowerStudy", 0.003932321, /*TODO*/150000);
        addSwiftFileSizeEstimator("mixed", "I2U2.Cosmic::ShowerStudy", 0.003932321, /*TODO*/8000);


        addEstimator("swift", "local", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
        addEstimator("swift", "grid", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
        addEstimator("swift", "mixed", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
    }

    private void addSwiftFileSizeEstimator(String method, String type, double aguess, double bguess) {
        addEstimator("swift", method, type, 
                new SelfAdjustingLinearFileSizeEstimator(type, method, 
                        aguess, bguess, getCores(method), getEfficiency(method)));
    }

    private int getCores(String method) {
        Integer v = CORES_MAP.get(method);
        if (v == null) {
            throw new IllegalArgumentException("No core count found for: " + method);
        }
        return v;
    }

    private double getEfficiency(String method) {
        Double v = EFFICIENCY_MAP.get(method);
        if (v == null) {
            throw new IllegalArgumentException("No efficiency found for: " + method);
        }
        return v;
    }
}
