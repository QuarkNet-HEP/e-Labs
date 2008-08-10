/*
 * Created on Jul 30, 2007
 */
package gov.fnal.elab.analysis;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public abstract class AbstractAnalysis implements ElabAnalysis {
    private String type;
    private AnalysisParameterTransformer parameterTransformer;
    
    
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getEncodedParameters() {
        return AnalysisTools.encodeParameters(this);
    }
    
    public Collection getParameterValues(String name) {
        return getParameterValues(this, name);
    }
    
    public static Collection getParameterValues(ElabAnalysis analysis, String name) {
        Object v = analysis.getParameter(name);
        if (v instanceof Collection) {
            return (Collection) v;
        }
        else if (v != null) {
            return Collections.singletonList(v);
        }
        else {
            return null;
        }
    }
    
    public Collection getInvalidParameters() {
        List l = new ArrayList();
        Iterator i = getParameters().keySet().iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            if (!isParameterValid(name)) {
                l.add(name);
            }
        }
        return l;
    }
    
    public boolean isValid() {
        Iterator i = getParameters().keySet().iterator();
        while (i.hasNext()) {
            String name = (String) i.next();
            if (!isParameterValid(name)) {
                return false;
            }
        }
        return true;
    }

    public AnalysisParameterTransformer getParameterTransformer() {
        return parameterTransformer;
    }

    public void setParameterTransformer(
            AnalysisParameterTransformer parameterTransformer) {
        this.parameterTransformer = parameterTransformer;
    }
}
