/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.estimation.ConstantEstimator;
import gov.fnal.elab.estimation.EstimatorSet;
import gov.fnal.elab.estimation.FluxEstimator;
import gov.fnal.elab.estimation.LinearEventEstimator;

public class CosmicAnalysisRunTimeEstimatorSet extends EstimatorSet {
    public CosmicAnalysisRunTimeEstimatorSet() {
        addEstimator("vds", "local", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.153424355, 2632.455));
        addEstimator("swift", "local", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.153424355, 2632.455));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.36819, 5327.64));
        addEstimator("swift", "grid", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.167697, 65988.4));
        addEstimator("swift", "mixed", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.282264, 1454.57));

        addEstimator("swift", "local", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.247119, 705.029));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.500107, 4839));
        addEstimator("swift", "grid", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.319383, 96234.4));
        // TODO this is a wild guess
        addEstimator("swift", "mixed", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.4, 1000));

        addEstimator("swift", "local", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(24251.6, -2.21535, 0.198371));
        addEstimator("swift", "grid", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(117392, -2.25828, 0.20651));

        addEstimator("swift", "local", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "grid", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "mixed", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
    }
}
