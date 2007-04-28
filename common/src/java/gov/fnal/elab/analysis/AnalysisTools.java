/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.analysis;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;


public class AnalysisTools {
    
    public static String encodeParameters(ElabAnalysis analysis) {
        try {
            boolean first = true;
            StringBuffer sb = new StringBuffer();
            Map params = analysis.getParameters();
            Iterator i = params.entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry e = (Map.Entry) i.next();
                String name = (String) e.getKey();
                Object o = e.getValue();
                if (analysis.isDefaultValue(name, o)) {
                    continue;
                }
                if (o instanceof Collection) {
                    Iterator j = ((Collection) o).iterator();
                    while (j.hasNext()) {
                        first = encodeOne(sb, name, j.next(), first);
                    }
                }
                else {
                    first = encodeOne(sb, name, o, first);
                }
            }
            return sb.toString();
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException(
                    "Oh my. UTF-8 is not supported on this platform.");
        }
    }
    
    public static boolean encodeOne(StringBuffer sb, String name, Object value,
            boolean first) throws UnsupportedEncodingException {
        if (value != null) {
            if (!first) {
                sb.append('&');
            }
            sb.append(URLEncoder.encode(name, "UTF-8"));
            sb.append('=');
            sb.append(URLEncoder.encode(value.toString(), "UTF-8"));
            return false;
        }
        else {
            return first;
        }
    }
}
