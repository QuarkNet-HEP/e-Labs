/*
 * Created on Apr 9, 2007
 */
package gov.fnal.elab.analysis;

import java.util.Collection;
import java.util.List;
import java.util.Map;

public interface ElabAnalysis {
    public static final Class TYPE_SCALAR = String.class;
    public static final Class TYPE_LIST = List.class;
    public static final Class TYPE_ANY = Object.class;
    
    String getType();
    void setType(String type);
    
    void setParameter(String name, Object value);
    void setParameterDefault(String name, Object value);
    Object getParameter(String name);
    boolean isDefaultValue(String name, Object value);
    
    boolean isParameterValid(String name);
    
    boolean isValid();
    
    Collection getInvalidParameters();
    
    Class getParameterType(String name);
    
    boolean hasParameter(String name);
 
    Map getParameters();
    
    Collection getParameterNames();
        
    String getEncodedParameters();
}
