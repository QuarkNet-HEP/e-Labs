/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import gov.fnal.elab.estimation.ConstantEstimator;
import gov.fnal.elab.estimation.EstimatorSet;

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
                new FluxEstimator(4000, -2.21535, 0.198371));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(11000, -2.6, 0.24651));
        addEstimator("swift", "grid", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(117392, -2.25828, 0.20651));
        addEstimator("swift", "mixed", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(33442.4, -2.83716, 0.28372));
        
        addEstimator("swift", "local", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.181027, 14304));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.364106, 33960));
        addEstimator("swift", "grid", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.24, 150000));
        addEstimator("swift", "mixed", "I2U2.Cosmic::ShowerStudy",
                new LinearEventEstimator(0.3, 20000));


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
