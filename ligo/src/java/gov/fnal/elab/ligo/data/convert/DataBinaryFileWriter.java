/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import gov.fnal.elab.ligo.data.engine.EncodingTools;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * http://www.postgresql.org/docs/8.1/static/sql-copy.html
 * @author Mihael Hategan
 *
 */
public class DataBinaryFileWriter implements DataFileWriter {

    private BufferedOutputStream os;
    private File f;

    public DataBinaryFileWriter(File f, boolean append) throws IOException {
        this.f = f;
        os = new BufferedOutputStream(new FileOutputStream(f, append));
    }
    
    private void write(int b) throws IOException {
        os.write(b);
    }
    
    private void write(byte[] buf) throws IOException {
        os.write(buf);
    }
    
    private void writeRawInt(int i) throws IOException {
        EncodingTools.writeInt(os, i);
    }
    
    public void writeInt(int i) throws IOException {
        writeRawInt(i);
    }
    
    public void writeLong(long l) throws IOException {
        EncodingTools.writeLong(os, l);
    }
    
    public void newRow(int columns) throws IOException {
    }

    public void writeDouble(double d) throws IOException {
        writeLong(Double.doubleToRawLongBits(d));
    }
    
    public void writeFloat(float f) throws IOException {
        writeInt(Float.floatToRawIntBits(f));
    }
    
    public void close() throws IOException {
        os.close();
    }
    
    public File getFile() {
        return f;
    }

    public void flush() throws IOException {
        os.flush();
    }

    public void writeBoolean(boolean valid) throws IOException {
        if (valid) {
            os.write(255);
        }
        else {
            os.write(0);
        }
    }
}
