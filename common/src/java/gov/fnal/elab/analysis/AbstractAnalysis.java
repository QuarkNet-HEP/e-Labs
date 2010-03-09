/*
 * Created on Jul 30, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public abstract class AbstractAnalysis implements ElabAnalysis {
    private String type;
    private AnalysisParameterTransformer parameterTransformer;
    private Map attributes;
    private Elab elab;
    private ElabGroup user;
    
    
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
    
    public String getName() {
        String[] ts = type.split("::");
        return ts[ts.length - 1];
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

    public void setAttributes(Map attributes) {
        this.attributes = attributes;
    }

    public void setAttribute(String name, Object value) {
        if (attributes == null) {
            attributes = new HashMap();
        }
        attributes.put(name, value);
    }

    public Object getAttribute(String name) {
        if (attributes == null) {
            return null;
        }
        else {
            return attributes.get(name);
        }
    }

    public Map getAttributes() {
        return attributes;
    }

    public Elab getElab() {
        return elab;
    }

    public void setElab(Elab elab) {
        this.elab = elab;
    }

    public ElabGroup getUser() {
        return user;
    }

    public void setUser(ElabGroup user) {
        this.user = user;
    }
}
