/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.estimation;

import java.util.HashMap;
import java.util.Map;

public class EstimatorSet {
    private Map estimators;
    
    public EstimatorSet() {
        estimators = new HashMap();
    }

    private static final Estimator NULL = new NullEstimator();

    public void addEstimator(String engine, String method, String type,
            Estimator p) {
        estimators.put(engine.toLowerCase() + "-" + method.toLowerCase() + "-"
                + type, p);
    }

    public Estimator getEstimator(String engine, String method, String type) {
        if (engine == null || method == null) {
            return NULL;
        }
        Estimator p = (Estimator) estimators.get(engine.toLowerCase() + "-"
                + method.toLowerCase() + "-" + type);
        if (p == null) {
            return NULL;
        }
        else {
            return p;
        }
    }
}
