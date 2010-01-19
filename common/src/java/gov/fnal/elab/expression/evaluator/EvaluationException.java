/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator;

public class EvaluationException extends RuntimeException {

    public EvaluationException() {
    }

    public EvaluationException(String message) {
        super(message);
    }

    public EvaluationException(Throwable cause) {
        super(cause);
    }

    public EvaluationException(String message, Throwable cause) {
        super(message, cause);
    }

}
