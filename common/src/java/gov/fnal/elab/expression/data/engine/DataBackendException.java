/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class DataBackendException extends Exception {

    public DataBackendException() {
        super();
    }

    public DataBackendException(String message, Throwable cause) {
        super(message, cause);
    }

    public DataBackendException(String message) {
        super(message);
    }

    public DataBackendException(Throwable cause) {
        super(cause);
    }

}
