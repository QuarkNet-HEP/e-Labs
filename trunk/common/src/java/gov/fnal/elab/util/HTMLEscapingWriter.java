/*
 * Created on Apr 20, 2007
 */
package gov.fnal.elab.util;

import java.io.IOException;
import java.io.Writer;

/**
 * 
 * This writer can be used to escape HTML characters and produce
 * a HTML renderable piece of text. Characters such as '<', '>', etc.
 * are transformed to their corresponding HTML entities and new lines are
 * transformed into "<br/>". 
 *
 */
public class HTMLEscapingWriter extends Writer {
    private static String[] esc = new String[128];
    static {
        esc['<'] = "&lt;";
        esc['>'] = "&gt;";
        esc['&'] = "&amp;";
        esc['\''] = "&quot;";
        esc['\n'] = "<br />";
    }
    private Writer wr;
    
    public HTMLEscapingWriter(Writer writer) {
        this.wr = writer;
    }

    public void close() throws IOException {
    }

    public void flush() throws IOException {
        wr.flush();
    }

    public void write(char[] cbuf, int off, int len) throws IOException {
        if (cbuf == null) {
            return;
        }
        for (int i = 0; i < len; i++) {
            char c = cbuf[off + i];
            if (esc[c] != null) {
                wr.write(esc[c]);
            }
            else {
                wr.write(c);
            }
        }
    }

    public void write(String str) throws IOException {
        super.write(String.valueOf(str));
    }
}
