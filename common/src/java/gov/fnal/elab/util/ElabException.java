package gov.fnal.elab.util;

public class ElabException extends Exception {
    ElabException() {
    }

    public ElabException(String msg) {
        super(msg);
    }

    public ElabException(String msg, Exception root) {
        super(msg, root);
    }

    public ElabException(Throwable prev) {
        super(prev);
    }
}
