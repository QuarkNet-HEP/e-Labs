/*
 * Created on Apr 16, 2007
 */
package gov.fnal.elab.tags;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.jsp.JspWriter;

public class DynamicAttributesSupport {
    
    public static void writeAttribute(JspWriter out, String name, Object value)
            throws IOException {
        if (value != null) {
            out.write(' ');
            out.write(name);
            out.write("=\"");
            out.write(value.toString());
            out.write('\"');
        }
    }

    public static void writeAttributes(JspWriter out, Map attrs) 
            throws IOException {
        Iterator i = attrs.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry e = (Map.Entry) i.next();
            writeAttribute(out, (String) e.getKey(), e.getValue());
        }
    }
}
