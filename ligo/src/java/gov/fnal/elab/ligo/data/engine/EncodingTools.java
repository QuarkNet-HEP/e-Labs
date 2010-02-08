/*
 * Created on Jan 29, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;

public class EncodingTools {
    public static void writeLong(OutputStream os, long l) throws IOException {
        for (int j = 0; j < 8; j++) {
            os.write((int) (l & 0x00000000000000ffL));
            l >>>= 8;
        }
    }
    
    public static void writeInt(OutputStream os, int l) throws IOException {
        for (int j = 0; j < 4; j++) {
            os.write(l & 0x000000ff);
            l >>>= 8;
        }
    }
    
    public static double readDouble(InputStream is) throws IOException {
        return Double.longBitsToDouble(readLong(is));
    }
    
    public static long readLong(InputStream is) throws IOException {
        long v = 0;
        for (int j = 0; j < 8; j++) {
            long l = is.read();
            if (l == -1) {
                throw new EOFException();
            }
            v = (v >>> 8) + ((l & 0x00000000000000ffL) << 56);
        }
        return v;
    }
    
    public static double readDouble(RandomAccessFile f) throws IOException {
        return Double.longBitsToDouble(readLong(f));
    }
    
    public static long readLong(RandomAccessFile f) throws IOException {
        long v = 0;
        for (int j = 0; j < 8; j++) {
            long l = f.read();
            if (l == -1) {
                throw new EOFException();
            }
            v = (v >>> 8) + ((l & 0x00000000000000ffL) << 56);
        }
        return v;
    }

    public static int readInt(InputStream is) throws IOException {
        int v = 0;
        for (int j = 0; j < 4; j++) {
            int c = is.read();
            if (c == -1) {
                throw new EOFException();
            }
            v = (v >>> 8) + ((c & 0x000000ff) << 24);
        }
        return v;
    }
    
    public static float readFloat(InputStream is) throws IOException {
        return Float.intBitsToFloat(readInt(is));
    }

    public static boolean readBoolean(RandomAccessFile f) throws IOException {
        return f.read() != 0;
    }
}
