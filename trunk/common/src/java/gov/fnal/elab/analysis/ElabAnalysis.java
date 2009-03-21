/*
 * Created on Apr 9, 2007
 */
package gov.fnal.elab.analysis;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * Represents an abstract elab analysis
 * 
 */
public interface ElabAnalysis {
    /**
     * 
     */
    public static final Class TYPE_SCALAR = String.class;
    public static final Class TYPE_LIST = List.class;
    public static final Class TYPE_ANY = Object.class;

    /**
     * Returns the type of this analysis
     */
    String getType();

    /**
     * Sets this analysis' type. It is assumed that the
     * <code>AnalysisExecution</code> implementation used to run this analysis
     * can make sense of this type.
     */
    void setType(String type);
    
    /**
     * Returns a user-friendly name for the analysis. Typically
     * this would be done by stripping the namespace off the type.
     */
    String getName();

    /**
     * Sets the value of a parameter for this analysis
     */
    void setParameter(String name, Object value);

    /**
     * Specifies what a default value for a certain parameter should be.
     */
    void setParameterDefault(String name, Object value);

    /**
     * Returns the value of a parameter
     */
    Object getParameter(String name);
    
    /**
     * Retrieves the values of a vector parameter
     */
    Collection getParameterValues(String name);

    /**
     * Returns <code>true</code> if the value currently set on a parameter on
     * this analysis is the default parameter value (possibly specified with
     * <code>setParameterDefault</code>).
     */
    boolean isDefaultValue(String name, Object value);

    /**
     * Returns <code>true</code> if the value of a parameter is valid. It is
     * not necessary for such a value to be a non-default value in order for it
     * to be valid.
     */
    boolean isParameterValid(String name);

    /**
     * Returns <code>true</code> if all values for all parameters are valid.
     */
    boolean isValid();

    /**
     * Returns a collection of parameter names whose values are invalid.
     */
    Collection getInvalidParameters();

    /**
     * Returns the type of a parameter. Currently there are three possible
     * values: <code>ElabAnalysis.TYPE_SCALAR</code>,
     * <code>ElabAnalysis.TYPE_LIST</code>, and
     * <code>ElabAnalysis.TYPE_ANY</code>. There is some fuzziness about the
     * meaning of these, but in principle the following could are believed to be
     * true:<br>
     * <ol>
     * <li> If this method returns <code>TYPE_LIST</code> for a parameter, its
     * value should be a subclass of <code>java.util.List</code>
     * <li> <code>TYPE_ANY</code> means that the implementation cannot provide
     * sufficient information to differentiate between <code>TYPE_LIST</code>
     * and <code>TYPE_SCALAR</code>, and that other means should be figured
     * for finding out what exactly is a valid value for that parameter.
     * Alternatively, the implementation may not care what the type of the value
     * is or it will automatically make sense of it.
     * </ol>
     */
    Class getParameterType(String name);

    /**
     * Returns <code>true</code> if this analysis supports the given
     * parameter.
     */
    boolean hasParameter(String name);

    /**
     * Returns a (typically immutable) Map of the parameters. 
     */
    Map getParameters();

    /**
     * Returns a collection of all valid parameter names.
     */
    Collection getParameterNames();

    /**
     * Returns this analysis' parameter in URL form.
     */
    String getEncodedParameters();
    
    void initialize(String param) throws InitializationException;
    
    AnalysisParameterTransformer getParameterTransformer();

    void setParameterTransformer(AnalysisParameterTransformer parameterTransformerInstance);
    
    void setAttribute(String name, Object value);
    
    Object getAttribute(String name);
    
    void setAttributes(Map attributes);
    
    Map getAttributes();
}
