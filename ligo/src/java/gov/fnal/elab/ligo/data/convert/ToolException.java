/*
 * Created on Feb 4, 2010
 */
package gov.fnal.elab.ligo.data.convert;

public class ToolException extends RuntimeException {

    public ToolException() {
        super();
    }

    public ToolException(String message, Throwable cause) {
        super(message, cause);
    }

    public ToolException(String message) {
        super(message);
    }

    public ToolException(Throwable cause) {
        super(cause);
    }
}
