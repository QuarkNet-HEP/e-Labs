/*
 * Created on Aug 5, 2008
 */
package gov.fnal.elab.analysis;

import java.util.Map;

public interface AnalysisParameterTransformer {
    Map transform(Map params);
}
