/*
 * Created on Jul 30, 2007
 */
package gov.fnal.elab.analysis;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class GenericAnalysis extends AbstractAnalysis {

    private Map arguments, defaults;
    
    public GenericAnalysis() {
    	arguments = new HashMap();
    	defaults = new HashMap();
    }

    public Object getParameter(String name) {
        return arguments.get(name);
    }

    public Collection getParameterNames() {
    	//not much more can be done here
        return arguments.keySet();
    }

    public Class getParameterType(String name) {
        return Object.class;
    }

    public Map getParameters() {
        return arguments;
    }

    public boolean hasParameter(String name) {
        return true;
    }

    public void initialize(String param) throws InitializationException {
    }

    public boolean isDefaultValue(String name, Object value) {
        if (equals(value, defaults.get(name))) {
            return true;
        }
        else {
        	return false;
        }
    }
    
    private boolean equals(Object o1, Object o2) {
        if (o1 == null) {
            return o2 == null;
        }
        else {
            return o1.equals(o2);
        }
    }

    public boolean isParameterValid(String name) {
        return arguments.containsKey(name);
    }

    public void setParameter(String name, Object value) {
    	arguments.put(name, value);
    }

    public void setParameterDefault(String name, Object value) {
    	defaults.put(name, value);
    	setParameter(name, value);
    }
}
