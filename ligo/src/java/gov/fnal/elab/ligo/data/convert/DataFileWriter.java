/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import java.io.File;
import java.io.IOException;

public interface DataFileWriter {

    void close() throws IOException;

    void writeDouble(double sum) throws IOException;

    void writeFloat(float value) throws IOException;

    void writeLong(long sum) throws IOException;

    void writeInt(int value) throws IOException;

    File getFile();

    void flush() throws IOException;

    void writeBoolean(boolean valid) throws IOException;
}
