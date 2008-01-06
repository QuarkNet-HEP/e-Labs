/*
 * Created on Apr 20, 2007
 */
package gov.fnal.elab;

/**
 * This is a custom exception that can be used to display graceful error
 * messages, while still benefiting from the exception mechanism. Typically,
 * instead of nested conditions and other weirdness, Java code in JSP files
 * would throw this exception. An custom error page would then intercept
 * exceptions of this class and display them nicely.
 */
public class ElabJspException extends Exception {

    public ElabJspException() {
        super();
    }

    public ElabJspException(String message, Throwable cause) {
        super(message, cause);
    }

    public ElabJspException(String message) {
        super(message);
    }

    public ElabJspException(Throwable cause) {
        super(cause.getMessage(), cause);
    }
}
