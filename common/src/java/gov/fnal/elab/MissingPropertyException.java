/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

public class MissingPropertyException extends RuntimeException {
    public MissingPropertyException(String name, String elab) {
        super("Missing required property (" + name + ") for " + elab + " elab");
    }
}
