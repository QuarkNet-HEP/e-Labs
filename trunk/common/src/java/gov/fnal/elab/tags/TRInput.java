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
import java.util.Collection;
import java.util.Iterator;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

public class TRInput extends TRControl {
    public int doEndTag() throws JspException {
        clearAttributes();
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        JspWriter out = pageContext.getOut();
        try {
            Object value = getValue();
            String type = (String) getAttribute("type");
            if (value instanceof Collection) {
                Collection col = (Collection) value;
                if ("hidden".equals(type)) {
                    Iterator i = col.iterator();
                    while (i.hasNext()) {
                        writeOne(out, i.next());
                        out.write('\n');
                    }
                }
                else if ("checkbox".equals(type)) {
                    Object iv = getIntrinsicValue();
                    if (iv != null && col.contains(iv)) {
                        setDynamicAttribute(null, "checked", "checked");
                    }
                    writeOne(out, iv);
                }
                else {
                    writeOne(out, nextValue());
                }
                commitToAnalysis(list(col));
            }
            else {
                if ("checkbox".equals(type)) {
                    Object iv = getIntrinsicValue();
                    if (value instanceof Boolean) {
                    	if (((Boolean) value).booleanValue()) {
                    		setDynamicAttribute(null, "checked", "checked");
                    	}
                    }
                    else if ((iv == null && value != null) || (iv != null && iv.equals(value))) {
                        setDynamicAttribute(null, "checked", "checked");
                    }
                    writeOne(out, iv);
                }
                else {
                    writeOne(out, value);
                }
                commitToAnalysis(value);
            }
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_BODY_INCLUDE;
    }    

    protected void writeOne(JspWriter out, Object value) throws IOException,
            JspException {
        out.write("<input");
        if (!isAnalysisParameterValid()) {
        	out.write(" class=\"invalid\"");
        }
        writeAttribute(out, "name", getName());
        if (value != null) {
            writeAttribute(out, "value", value);
        }
        if (!"hidden".equals(getAttribute("type"))) {
            writeDynamicLabelUpdater(out);
        }
        writeAttributes(out);
        out.write("/>");
        if (pageContext.getRequest().getParameter(TRSubmit.CONTROL_NAME) != null
                && !isAnalysisParameterValid() && getOnError() != null) {
            out.write("<span class=\"param-error\">");
            out.write(getOnError());
            out.write("</span>");
        }
    }

    protected Object getControlValue() throws JspException {
        String type = (String) getAttribute("type");
        Object iv = getIntrinsicValue();
        if ("checkbox".equals(type)) {
            if (getAttribute("checked") != null) {
                if (iv != null) {
                    return iv;
                }
                else {
                    return "on"; 
                }
            }
            else {
                return null;
            }
        }
        else {
            return getIntrinsicValue();
        }
    }
}
