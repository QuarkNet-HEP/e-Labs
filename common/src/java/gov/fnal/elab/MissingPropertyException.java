/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

public class MissingPropertyException extends RuntimeException {
    public MissingPropertyException(String name, String props) {
        super("Missing required property (" + name + ") for " + props);
    }
}
