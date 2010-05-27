/*
 * Created on May 25, 2010
 */
package gov.fnal.elab.cms.dataset;

public class DatasetLoadException extends Exception {

    public DatasetLoadException() {
        super();
    }

    public DatasetLoadException(String message, Throwable cause) {
        super(message, cause);
    }

    public DatasetLoadException(String message) {
        super(message);
    }

    public DatasetLoadException(Throwable cause) {
        super(cause);
    }
}
