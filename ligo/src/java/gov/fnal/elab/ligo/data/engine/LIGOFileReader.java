/*
 * Created on Feb 23, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.io.IOException;

public interface LIGOFileReader {
    Record readRecord(long l) throws IOException;
    
    Record[] readRecords(long[] indices) throws IOException;

    Double value(Record last, Record rec);
}
