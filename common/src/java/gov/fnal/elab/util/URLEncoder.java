/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.util;

import java.io.UnsupportedEncodingException;

public class URLEncoder {
    public static String encode(String s) {
        try {
            return java.net.URLEncoder.encode(s, "UTF-8");
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException(
                    "UTF-8 encoding is not supported on this platform");
        }
    }
}
