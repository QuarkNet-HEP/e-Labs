/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * http://www.postgresql.org/docs/8.1/static/sql-copy.html
 * @author Mihael Hategan
 *
 */
public class PGDataBinaryFileWriter implements PGDataFileWriter {
    public static final byte[] HEADER = new byte[] { 'P', 'G', 'C', 'O', 'P', 'Y', '\n', (byte) 0xff, 0x0d, '\n', 0x00};

    private BufferedOutputStream os;
    private File f;

    public PGDataBinaryFileWriter(File f, boolean append) throws IOException {
        this.f = f;
        os = new BufferedOutputStream(new FileOutputStream(f, append));
        writeHeader();
    }

    private void writeHeader() throws IOException {
        os.write(HEADER);
        writeRawInt(0);
        writeRawInt(0);
    }
    
    private void writeRawInt(int i) throws IOException {
        for (int j = 0; j < 4; j++) {
            os.write((i >> 24) & 0x000000ff);
            i <<= 8;
        }
    }
    
    public void writeInt(int i) throws IOException {
        writeRawInt(4);
        writeRawInt(i);
    }
    
    public void writeLong(long l) throws IOException {
        writeRawInt(8);
        for (int j = 0; j < 8; j++) {
            os.write((int) ((l >> 56) & 0x00000000000000ffL));
            l <<= 8;
        }
    }
    
    private void writeRawShortInt(int i) throws IOException {
        for (int j = 0; j < 2; j++) {
            os.write((i >> 8) & 0x000000ff);
            i <<= 8;
        }
    }
    
    public void newRow(int columns) throws IOException {
        writeRawShortInt(columns);
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
}
