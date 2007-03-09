/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import java.util.Collection;

public class CircularPropertyReferenceException extends RuntimeException {
    public CircularPropertyReferenceException(Collection stack, String name) {
        super("Circular reference in elab properties files (" + stack + ")"
                + " in " + name + " elab properties file");
    }
}
