/*
 * Created on Feb 11, 2010
 */
package gov.fnal.elab.ligo.data.engine;

public class EngineException extends RuntimeException {

    public EngineException() {
        super();
    }

    public EngineException(String message, Throwable cause) {
        super(message, cause);
    }

    public EngineException(String message) {
        super(message);
    }

    public EngineException(Throwable cause) {
        super(cause);
    }
    
}
