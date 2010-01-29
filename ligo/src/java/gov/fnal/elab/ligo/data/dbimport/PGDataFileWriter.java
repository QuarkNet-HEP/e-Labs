/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.File;
import java.io.IOException;

public interface PGDataFileWriter {

    void close() throws IOException;

    void newRow(int i) throws IOException;

    void writeDouble(double sum) throws IOException;

    void writeFloat(float value) throws IOException;

    void writeLong(long sum) throws IOException;

    void writeInt(int value) throws IOException;

    File getFile();
}
