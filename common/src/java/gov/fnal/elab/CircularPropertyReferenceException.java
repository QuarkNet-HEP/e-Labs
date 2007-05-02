/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab;

import java.util.Collection;

/**
 * Elab properties can contain references to other properties in the ${name}
 * form. This exception is thrown if a circular reference is found in the
 * properties files.
 */
public class CircularPropertyReferenceException extends RuntimeException {
    public CircularPropertyReferenceException(Collection stack, String name) {
        super("Circular reference (" + stack + ")" + " in " + name);
    }
}
