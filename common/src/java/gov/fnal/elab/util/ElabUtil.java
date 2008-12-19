/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.util;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabJspException;

import java.io.BufferedReader;
import java.io.CharArrayWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Writer;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;

import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.PNGTranscoder;

public class ElabUtil {

    public static String pathcat(String path1, String path2) {
        return pathcat(path1, path2, File.separator);
    }

    public static String urlcat(String url1, String url2) {
        return pathcat(url1, url2, "/");
    }

    public static String pathcat(String path1, String path2, String separator) {
        if (path1 == null || path2 == null) {
            throw new IllegalArgumentException("Null path");
        }
        if (path1.endsWith(separator) || path2.startsWith(separator)) {
            return path1 + path2;
        }
        else {
            return path1 + separator + path2;
        }
    }

    public static String fixQuotes(String param) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < param.length(); i++) {
            char c = param.charAt(i);
            if ((c == '\'') || (c == '\\'))  {
                sb.append(c);
            }
            sb.append(c);
        }
        return sb.toString();
    }

    private static final Map splits;

    static {
        splits = new HashMap();
    }

    public static synchronized Collection split(Object list) {
        if (list instanceof Collection) {
            return (Collection) list;
        }
        else {
            List l = (List) splits.get(list);
            if (l == null) {
                l = new ArrayList();
                StringTokenizer st = new StringTokenizer(String.valueOf(list),
                        ",");
                while (st.hasMoreTokens()) {
                    l.add(st.nextToken().trim());
                }
                splits.put(list, l);
            }
            return l;
        }
    }

    public static void optionSet(JspWriter out, String name, String values,
            String labels, String selected) throws IOException {
        out.write("<select name=\"");
        out.write(name);
        out.write("\">\n");
        optionSet(out, values, labels, selected);
        out.write("</select>\n");
    }

    public static void optionSet(JspWriter out, Object values, Object labels,
            String selected) throws IOException {
        Collection valuesList = split(values);
        Collection labelsList = split(labels);
        if (valuesList.size() != labelsList.size()) {
            throw new IllegalArgumentException(
                    "Values/labels count mismatch. Got " + valuesList.size()
                            + " values and " + labelsList.size() + " labels.");
        }
        Iterator i = valuesList.iterator(), j = labelsList.iterator();
        while (i.hasNext()) {
            String value = (String) i.next();
            out.write("<option value=\"");
            out.write(String.valueOf(value));
            out.write("\"");
            if (selected != null && selected.equals(value)) {
                out.write(" selected");
            }
            out.write(">");
            out.write(String.valueOf(j.next()));
            out.write("</option>\n");
        }
    }

    public static final NumberFormat TIME_FORMAT;
    static {
        TIME_FORMAT = NumberFormat.getNumberInstance();
        TIME_FORMAT.setMaximumFractionDigits(3);
        TIME_FORMAT.setMinimumFractionDigits(3);
    }

    public static String formatTime(long time) {
        return TIME_FORMAT.format((double) time / 1000);
    }

    public static void vsWriteVisibleStart(JspWriter out, String id,
            String cls, String image) throws IOException {
        vsWriteVisibleStart(out, id, cls, image, false);
    }

    public static void vsWriteVisibleStart(JspWriter out, String id,
            String cls, String image, boolean revert) throws IOException {
        out.write("<div ");
        if (cls != null) {
            out.write("class=\"");
            out.write(cls);
            out.write("\" ");
        }
        out.write("id=\"");
        out.write(id);
        if (revert) {
            out.write("-v\" style=\"visibility:hidden; display: none\">\n");
        }
        else {
            out.write("-v\" style=\"visibility:visible; display:\">\n");
        }
        out.write("<a href=\"#\" onclick=\"HideShow('");
        out.write(id);
        out.write("-v');HideShow('");
        out.write(id);
        out.write("-h');return false;\"><img src=\"");
        if (image == null) {
            image = "../graphics/Tright.gif";
        }
        out.write(image);
        out.write("\" alt=\" \" border=\"0\" /></a>");
    }

    public static void vsWriteVisibleEnd(JspWriter out) throws IOException {
        out.write("</div>");
    }

    public static void vsWriteHiddenStart(JspWriter out, String id, String cls,
            String image) throws IOException {
        vsWriteHiddenStart(out, id, cls, image, false);
    }

    public static void vsWriteHiddenStart(JspWriter out, String id, String cls,
            String image, boolean revert) throws IOException {
        out.write("<div ");
        if (cls != null) {
            out.write("class=\"");
            out.write(cls);
            out.write("\" ");
        }
        out.write("id=\"");
        out.write(id);
        if (revert) {
            out.write("-h\" style=\"visibility:visible; display:\">\n");
        }
        else {
            out.write("-h\" style=\"visibility:hidden; display: none\">\n");
        }
        out.write("<a href=\"#\" onclick=\"HideShow('");
        out.write(id);
        out.write("-v');HideShow('");
        out.write(id);
        out.write("-h');return false;\"><img src=\"");
        if (image == null) {
            image = "../graphics/Tdown.gif";
        }
        out.write(image);
        out.write("\" alt=\" \" border=\"0\" /></a>");
    }

    public static void vsWriteHiddenEnd(JspWriter out) throws IOException {
        out.write("</div>");
    }

    private static final String[] NO_VALUES = new String[] { "" };

    /**
     * Returns a query string that is composed of the parameters in the supplied
     * request while ensuring that a given parameter will have a certain value.
     * In other words, if the request does not contain the parameter, it will be
     * added. If it does, it will be changed to the given value.
     * 
     * @param request
     *            The request from which the query string is build
     * @param name
     *            The name of the parameter to modify/add
     * @param value
     *            The value of the modified/added parameter
     * @return The resulting query string
     */
    public static String modQueryString(HttpServletRequest request,
            String name, int value) {
        return modQueryString(request, name, String.valueOf(value));
    }

    /**
     * Returns a query string that is composed of the parameters in the supplied
     * request while ensuring that a given parameter will have a certain value.
     * In other words, if the request does not contain the parameter, it will be
     * added. If it does, it will be changed to the given value.
     * 
     * @param request
     *            The request from which the query string is build
     * @param name
     *            The name of the parameter to modify/add
     * @param value
     *            The value of the modified/added parameter
     * @return The resulting query string
     */
    public static String modQueryString(HttpServletRequest request,
            String name, String value) {
        StringBuffer sb = new StringBuffer();
        Map map = request.getParameterMap();
        sb.append('?');
        boolean hit = false;
        Iterator i = map.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            String key = (String) e.getKey();
            String[] values = (String[]) e.getValue();
            if (name.equals(key)) {
                values = new String[] { value };
                hit = true;
            }
            if (values == null || values.length == 0) {
                values = NO_VALUES;
            }
            for (int j = 0; j < values.length; j++) {
                if (j != 0) {
                    sb.append('&');
                }
                addParam(sb, key, values[j]);
            }
            if (i.hasNext()) {
                sb.append('&');
            }
        }
        if (!hit) {
            sb.append('&');
            addParam(sb, name, value);
        }
        return sb.toString();
    }

    private static void addParam(StringBuffer sb, String key, String value) {
        sb.append(key);
        sb.append('=');
        sb.append(value);
    }

    public static String join(Object[] c, String separator) {
        return join(Arrays.asList(c), separator);
    }

    public static String join(Collection c, String separator) {
        return join(c, null, null, separator);
    }

    public static String join(Collection c, String prefix, String suffix,
            String separator) {
        StringBuffer sb = new StringBuffer();
        Iterator i = c.iterator();
        while (i.hasNext()) {
            if (prefix != null) {
                sb.append(prefix);
            }
            sb.append(i.next());
            if (suffix != null) {
                sb.append(suffix);
            }
            if (i.hasNext() && (separator != null)) {
                sb.append(separator);
            }
        }
        return sb.toString();
    }

    public static void copyFile(String srcdir, String srcfile, String destdir,
            String destfile) throws ElabJspException {
        File src = new File(srcdir, srcfile);
        File dst = new File(destdir, destfile);
        dst.getParentFile().mkdirs();
        try {
            InputStream is = new FileInputStream(src);
            OutputStream os = new FileOutputStream(dst);
            byte[] buf = new byte[16384];
            int count = 0;
            try {
                while (count != -1) {
                    count = is.read(buf);
                    if (count > 0) {
                        os.write(buf, 0, count);
                    }
                }
            }
            finally {
                try {
                    is.close();
                }
                catch (Exception e) {
                }
                try {
                    os.close();
                }
                catch (Exception e) {
                }
            }
        }
        catch (IOException e) {
            throw new ElabJspException("Failed to copy " + srcfile + " from "
                    + srcdir + " to " + destdir + File.separator + destfile
                    + ". " + e.getMessage(), e);
        }
    }

    public static void runCommand(Elab elab, String cmd)
            throws ElabJspException {
        runCommand(cmd);
    }

    public static void runCommand(String cmd) throws ElabJspException {
        runCommand(cmd, null);
    }

    public static void runCommand(String cmd, Writer heartbeat)
            throws ElabJspException {
        String[] fullcmd = new String[] { "/bin/bash", "-c", cmd };
        try {
            Process p = Runtime.getRuntime().exec(fullcmd);
            p.getOutputStream().close();
            InputStream is = p.getInputStream();
            int ec;
            try {
                while (true) {
                    int block = 1024;
                    while (is.available() > 0 && block > 0) {
                        // keep reading the stdout to avoid the process
                        // filling up the buffer
                        is.read();
                        block--;
                    }

                    try {
                        ec = p.exitValue();
                        if (ec != 0) {
                            throw new ElabJspException("Failed to run '" + cmd
                                    + "'. (exit code " + ec + "): "
                                    + readStream(p.getErrorStream()));
                        }
                        break;
                    }
                    catch (IllegalThreadStateException e) {
                        // still running
                        if (heartbeat != null) {
                            heartbeat.write("<!-- process running -->\n");
                            heartbeat.flush();
                        }
                        Thread.sleep(250);
                    }
                }
            }
            catch (InterruptedException e) {
                // the page will finish rendering soon anyway
            }
        }
        catch (IOException e) {
            throw new ElabJspException("Failed to run '" + fullcmd + "'. "
                    + e.getMessage(), e);
        }
    }

    private static String readStream(InputStream is) {
        BufferedReader r = new BufferedReader(new InputStreamReader(is));
        CharArrayWriter caw = new CharArrayWriter();
        try {
            String line;
            do {
                line = r.readLine();
                if (line != null) {
                    caw.write(line);
                    caw.write('\n');
                }
            } while (line != null);
            return caw.toString();
        }
        catch (IOException e) {
            return "<error reading stream>";
        }
    }

    public static void SVG2PNG(String svg, String png) throws ElabJspException {
        try {
            // Now convert the SVG image to PNG using the Batik toolkit.
            // Thanks to the Batik website's tutorial for this code
            // (http://xml.apache.org/batik/rasterizerTutorial.html).
            PNGTranscoder t = new PNGTranscoder();
            t.addTranscodingHint(PNGTranscoder.KEY_MAX_HEIGHT, new Float(800));
            t.addTranscodingHint(PNGTranscoder.KEY_MAX_WIDTH, new Float(1200));
            TranscoderInput input = new TranscoderInput((new File(svg)).toURL()
                    .toString());
            OutputStream ostream = new FileOutputStream(png);
            TranscoderOutput output = new TranscoderOutput(ostream);
            t.transcode(input, output);
            ostream.flush();
            ostream.close();
        }
        catch (Exception e) {
            throw new ElabJspException(
                    "Error: Failed to create provenance information. "
                            + e.getMessage(), e);
        }
    }
    
    private static final TimeZone UTC = TimeZone.getTimeZone("UTC");

    public static NanoDate julianToGregorian(int jday, double fractional) {
        int Z = (int) (jday + 0.5 + fractional);
        int W = (int) ((Z - 1867216.25) / 36524.25);
        int X = (int) (W / 4);
        int A = Z + 1 + W - X;
        int B = A + 1524;
        int C = (int) ((B - 122.1) / 365.25);
        int D = (int) (365.25 * C);
        int E = (int) ((B - D) / 30.6001);
        int F = (int) (30.6001 * E);
        int day = B - D - F;
        int month = E - 1 <= 12 ? E - 1 : E - 13; // Month = E-1 or E-13 (must
        // get number
        // less than or equal to 12)
        int year = month <= 2 ? C - 4715 : C - 4716; // Year = C-4715 (if
        // Month is
        // January or February) or
        // C-4716 (otherwise)

        NanoDate nd = new NanoDate();
        Calendar gc = Calendar.getInstance(UTC);
        if (fractional != 0) {
            int hour = (int) (fractional * 24);
            int min = (int) ((fractional * 24 - hour) * 60);
            int sec = (int) (((fractional * 24 - hour) * 60 - min) * 60);
            int msec = (int) ((((fractional * 24 - hour) * 60 - min) * 60 - sec) * 1000);
            int micsec = (int) (((((fractional * 24 - hour) * 60 - min) * 60 - sec) * 1000 - msec) * 1000);
            int nsec = (int) ((((((fractional * 24 - hour) * 60 - min) * 60 - sec) * 1000 - msec) * 1000 - micsec) * 1000);

            gc.set(year, month - 1, day, (hour + 12) % 24, min, sec);
            gc.set(Calendar.MILLISECOND, msec);

            nd.setMicroSeconds(micsec);
            nd.setNanoSeconds(nsec);
        }
        else {
            gc.set(year, month - 1, day, 0, 0, 0);
        }
        nd.setTime(gc.getTimeInMillis());
        return nd;
    }
    
    private static final int[] MONTH_NUM = new int[] {306, 337, 0, 31, 61, 92, 122, 153, 184, 214, 245, 275};

    public static double gregorianToJulian(int year, int month, int day, int hour,
            int minute, int second) {
        double step1 = (year + 4712) / 4.0;
        int step1Int = (int) step1;
        double remainder = (step1 - step1Int) * 4;
        int monthNum = MONTH_NUM[month + 1];
        
        double PJD = (hour * 3600 + minute * 60 + second) / 86400.0;
        double jd = step1Int * 1461 + remainder * 365 + monthNum + day + 59
                - 13 - .5 + PJD;
        return jd;
    }

    public static String stripHTML(String text) {
        StringBuffer sb = new StringBuffer();
        boolean tag = false;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (tag) {
                if (c == '>') {
                    tag = false;
                }
            }
            else {
                if (c == '<') {
                    tag = true;
                }
                else {
                    sb.append(c);
                }
            }
        }
        return sb.toString();
    }
    
    public static String whitespaceAdjust(String text) {
        text = text.replaceAll("\n", "<br />");
        // this should be changed to only allow <a> and <img> tags
        text = text.replaceAll("(?i)</?\\s*script[^>]*>", "");
        text = text.replaceAll("(?i)</?\\s*pre[^>]*>", "");
        text = text.replaceAll("(?i)</?\\s*div[^>]*>", "");
        StringBuffer sb = new StringBuffer();
        int lastSpace = 0;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (Character.isWhitespace(c) || c == '/' || c == '<' || c == '>'
                    || c == '.') {
                lastSpace = i;
            }
            sb.append(c);
            if (i - lastSpace > 40) {
                sb.append(' ');
                lastSpace = i;
            }
        }

        return sb.toString();
    }
}
