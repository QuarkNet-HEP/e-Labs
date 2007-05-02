/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

/**
 * Thrown when a required property was not specified in any of the properties
 * files. 
 */
public class MissingPropertyException extends RuntimeException {
    public MissingPropertyException(String name, String props) {
        super("Missing required property (" + name + ") for " + props);
    }
}
