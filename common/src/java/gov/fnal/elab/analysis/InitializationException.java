/*
 * Created on Jul 15, 2007
 */
package gov.fnal.elab.analysis;

public class InitializationException extends Exception {

    public InitializationException() {
        super();
    }

    public InitializationException(String message, Throwable cause) {
        super(message, cause);
    }

    public InitializationException(String message) {
        super(message);
    }

    public InitializationException(Throwable cause) {
        super(cause);
    }
}
