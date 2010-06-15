//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Jun 5, 2010
 */
package gov.fnal.elab.cms.geom;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class ParenFixerInputStream extends FileInputStream {

    public ParenFixerInputStream(File file) throws FileNotFoundException {
        super(file);
    }

    public ParenFixerInputStream(String name) throws FileNotFoundException {
        super(name);
    }

    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int ml = super.read(b, off, len);
        fixParens(b, off, ml);
        return ml;
    }

    private void fixParens(byte[] b, int off, int len) {
        int end = off + len;
        for (int i = off; i < end; i++) {
            int c = b[i];
            switch (c) {
                case '(':
                    b[i] = '[';
                    break;
                case ')':
                    b[i] = ']';
                    break;
            }
        }
    }

    @Override
    public int read(byte[] b) throws IOException {
        int ml = super.read(b);
        fixParens(b, 0, ml);
        return ml;
    }

    @Override
    public int read() throws IOException {
        int c = super.read();
        switch (c) {
            case '(':
                return '[';
            case ')':
                return ']';
            default:
                return c;
        }
    }

}
