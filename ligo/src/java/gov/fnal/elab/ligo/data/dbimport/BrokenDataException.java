/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;


public class BrokenDataException extends RuntimeException {

    public BrokenDataException(String msg) {
        super(msg);
    }

    public BrokenDataException(String msg, Exception e) {
        super(msg, e);
    }

}
