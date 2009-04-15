/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.estimation.ConstantEstimator;
import gov.fnal.elab.estimation.EstimatorSet;

public class CosmicAnalysisRunTimeEstimatorSet extends EstimatorSet {
    public CosmicAnalysisRunTimeEstimatorSet() {
        addEstimator("swift", "local", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.1747, 3483));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.3323, 7000));
        addEstimator("swift", "grid", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.1480, 70351));
        addEstimator("swift", "mixed", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.2008, 3913));

        addEstimator("swift", "local", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.2502, 3356));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.4755, 8436));
        addEstimator("swift", "grid", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.2870, 120000));
        // TODO this is a wild guess
        addEstimator("swift", "mixed", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.35, 4000));

        addEstimator("swift", "local", "I2U2.Cosmic::FluxStudy",
                new LinearEventEstimator(0.4320, 3469));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::FluxStudy",
                new LinearEventEstimator(1.0400, 8641));
        addEstimator("swift", "grid", "I2U2.Cosmic::FluxStudy",
                new LinearEventEstimator(0.4000, 96000));
        addEstimator("swift", "mixed", "I2U2.Cosmic::FluxStudy",
                new LinearEventEstimator(0.6720, 9833));
        
        addEstimator("swift", "local", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.2253, 2427));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.4480, 9050));
        addEstimator("swift", "grid", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.24, 150000));
        addEstimator("swift", "mixed", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.35, 8000));


        addEstimator("swift", "local", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
        addEstimator("swift", "grid", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
        addEstimator("swift", "mixed", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(4));
    }
}
