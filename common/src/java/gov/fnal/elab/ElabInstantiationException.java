/*
 * Created on Mar 4, 2007
 */
package gov.fnal.elab;

public class ElabInstantiationException extends Exception {

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
