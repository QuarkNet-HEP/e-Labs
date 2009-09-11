/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.estimation.ConstantEstimator;
import gov.fnal.elab.estimation.EstimatorSet;

public class CosmicAnalysisRunTimeEstimatorSet extends EstimatorSet {
    public CosmicAnalysisRunTimeEstimatorSet() {
        addEstimator("swift", "local", "I2U2.Cosmic::PerformanceStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::PerformanceStudy", "local", 0.1747, 3483));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::PerformanceStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::PerformanceStudy", "i2u2", 0.3323, 7000));
        addEstimator("swift", "grid", "I2U2.Cosmic::PerformanceStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::PerformanceStudy", "grid", 0.1480, 70351));
        addEstimator("swift", "mixed", "I2U2.Cosmic::PerformanceStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::PerformanceStudy", "mixed", 0.2008, 3913));

        addEstimator("swift", "local", "I2U2.Cosmic::LifetimeStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::LifetimeStudy", "local", 0.2502, 3356));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::LifetimeStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::LifetimeStudy", "i2u2", 0.4755, 8436));
        addEstimator("swift", "grid", "I2U2.Cosmic::LifetimeStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::LifetimeStudy", "grid", 0.2870, 120000));
        // TODO this is a wild guess
        addEstimator("swift", "mixed", "I2U2.Cosmic::LifetimeStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::LifetimeStudy", "mixed", 0.35, 4000));

        addEstimator("swift", "local", "I2U2.Cosmic::FluxStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::FluxStudy", "local", 0.4320, 3469));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::FluxStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::FluxStudy", "i2u2", 1.0400, 8641));
        addEstimator("swift", "grid", "I2U2.Cosmic::FluxStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::FluxStudy", "grid", 0.4000, 96000));
        addEstimator("swift", "mixed", "I2U2.Cosmic::FluxStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::FluxStudy", "mixed", 0.6720, 9833));
        
        addEstimator("swift", "local", "I2U2.Cosmic::ShowerStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::ShowerStudy", "local", 0.2253, 2427));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::ShowerStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::ShowerStudy", "i2u2", 0.4480, 9050));
        addEstimator("swift", "grid", "I2U2.Cosmic::ShowerStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::ShowerStudy", "grid", 0.24, 150000));
        addEstimator("swift", "mixed", "I2U2.Cosmic::ShowerStudy",
                new SelfAdjustingLinearEventEstimator("I2U2.Cosmic::ShowerStudy", "mixed", 0.35, 8000));


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
