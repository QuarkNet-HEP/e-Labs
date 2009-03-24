/*
 * Created on Mar 24, 2009
 */
package gov.fnal.elab.tags;

import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class Transclude extends TagSupport {
    public static final int BUFFER_SIZE = 8192;
    private String url;
    private String start, end;

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public int doStartTag() throws JspException {
        JspWriter out = pageContext.getOut();
        if (!url.startsWith("http://")) {
            url = "http://" + url;
        }
        try {
            URL u = new URL(url);
            InputStreamReader isr = new InputStreamReader(u.openStream());
            if (start != null) {
                skipTo(isr, start);
            }
            if (end != null) {
                copyTo(isr, out, end);
            }
            else {
                copy(isr, out);
            }
            isr.close();
        }
        catch (MalformedURLException e) {
            throw new JspException("Invalid URL: " + url, e);
        }
        catch (IOException e) {
            throw new JspException("Error reading from " + url, e);
        }
        return EVAL_PAGE;
    }

    private void copy(InputStreamReader isr, JspWriter out) throws IOException {
        char[] buf = new char[BUFFER_SIZE];
        int count = isr.read(buf);
        while (count != -1) {
            out.write(buf, 0, count);
            count = isr.read(buf);
        }
    }

    private void copyTo(InputStreamReader isr, JspWriter out, String end) throws IOException {
        int index = 0;
        StringBuilder sb = new StringBuilder();
        while (true) {
            int c = isr.read();
            if (c == -1) {
                out.write(sb.toString());
                return;
            }
            if (c == end.charAt(index)) {
                index++;
                if (index == end.length()) {
                    sb.delete(sb.length() - end.length() + 1, sb.length());
                    out.append(sb.toString());
                    return;
                }
            }
            else {
                index = 0;
            }
            sb.append((char) c);
        }
    }

    private void skipTo(InputStreamReader isr, String start) throws IOException {
        int index = 0;
        while (true) {
            int c = isr.read();
            if (c == -1) {
                return;
            }
            if (c == start.charAt(index)) {
                index++;
                if (index == start.length()) {
                    return;
                }
            }
            else {
                index = 0;
            }
        }
    }
}
