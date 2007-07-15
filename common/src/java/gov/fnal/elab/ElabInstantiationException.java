/*
 * Created on Mar 4, 2007
 */
package gov.fnal.elab;

/**
 * This exception is thrown when an <code>Elab</code> object cannot be
 * instantiated.
 * 
 */
public class ElabInstantiationException extends RuntimeException {

    public ElabInstantiationException() {
        super();
    }

    public ElabInstantiationException(String message, Throwable cause) {
        super(message, cause);
    }

    public ElabInstantiationException(String message) {
        super(message);
    }

    public ElabInstantiationException(Throwable cause) {
        super(cause);
    }
}
