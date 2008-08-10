/*
 * Created on Aug 5, 2008
 */
package gov.fnal.elab.analysis;

import java.util.Map;

public class NullAnalysisParameterTransformer implements
        AnalysisParameterTransformer {

    public Map transform(Map params) {
        return params;
    }

}
