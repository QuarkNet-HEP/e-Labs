//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

public class TRTextArea extends TRControl {
    private List labelsToUpdate;
    private String id;

    public int doEndTag() throws JspException {
        JspWriter out = pageContext.getOut();
        try {
            Object value = getValue();
            if (value != null) {
                out.write(String.valueOf(value));
            }
            out.write("</textarea>\n");
            commitToAnalysis(value);
            if (labelsToUpdate.size() > 0) {
                out.write("<script type=\"text/javascript\">\n");
                Iterator i = labelsToUpdate.iterator();
                while (i.hasNext()) {
                    String[] s = (String[]) i.next();
                    out.write("registerLabelForUpdate(\"" + s[0] + "\", \"" + s[1] + "\", \"" + id + "\");\n");
                }
                out.write("</script>\n");
            }
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        labelsToUpdate = new LinkedList();
         JspWriter out = pageContext.getOut();
        try {
            out.write("<textarea");
            writeAttribute(out, "name", getName());
            id = (String) getAttribute("id");
            if (id == null) {
                id = "tr" + getName();
            }
            else {
                getAttributes().remove("id");
            }
            writeAttribute(out, "id", id);
            writeAttributes(out);
            out.write(">");
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_BODY_INCLUDE;
    }

    public void registerLabelForUpdate(String name, String label) {
        labelsToUpdate.add(new String[] {name, label});
    }
}
