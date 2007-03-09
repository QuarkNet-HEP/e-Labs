/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.util;

import java.io.File;

import javax.servlet.jsp.JspWriter;

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

    public static void warn(JspWriter out, String message) {
        try {
            out.write("<span class=\"warning\">");
            out.write(message);
            out.write("</span>");
        }
        catch (Exception e) {
            System.err.println("Failed to print warning message to page: "
                    + message);
            e.printStackTrace();
        }
    }
    
    public static String fixQuotes(String param) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < param.length(); i++) {
            char c = param.charAt(i);
            if (c == '\'') {
                sb.append(c);
            }
            sb.append(c);
        }
        return sb.toString();
    }
}
