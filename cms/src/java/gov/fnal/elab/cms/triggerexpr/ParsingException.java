/*
 * Created on May 7, 2010
 */
package gov.fnal.elab.cms.triggerexpr;

public class ParsingException extends Exception {

    public ParsingException() {
        super();
    }

    public ParsingException(String message, Throwable cause) {
        super(message, cause);
    }

    public ParsingException(String message) {
        super(message);
    }

    public ParsingException(Throwable cause) {
        super(cause);
    }
}
