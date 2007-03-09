package gov.fnal.elab.util;

import java.util.Date;

public class ElabException extends Exception{
    ElabException(){
    }

    public ElabException(String msg){
        super(timestampPrefixedMessage(msg));
    }

    public ElabException(String msg, Exception root){
        super(timestampPrefixedMessage(msg), root);
    }

    static String timestampPrefixedMessage(String msg) {
        return new Date().toString()+": "+msg;
    }
}
