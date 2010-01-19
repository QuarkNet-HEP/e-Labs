/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

public class TypeException extends RuntimeException {

    public TypeException() {
        super();
    }

    public TypeException(String message, Throwable cause) {
        super(message, cause);
    }

    public TypeException(String message) {
        super(message);
    }

    public TypeException(Throwable cause) {
        super(cause);
    }

}
