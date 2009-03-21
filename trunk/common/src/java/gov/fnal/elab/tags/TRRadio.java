//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.util.ElabUtil;

import java.io.IOException;
import java.util.Collection;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

public class TRRadio extends TRControl {
    private Collection valueList, labelList;

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            Object value = getValue();
            String selected = String.valueOf(nextValue());
            if (selected == null || selected.equals("")) {
                if (valueList != null && valueList.size() > 0) {
                    selected = String.valueOf(valueList.iterator().next());
                }
            }
            JspWriter out = pageContext.getOut();
            radioSet(out, list(valueList), list(labelList), selected);
            if (value instanceof Collection) {
                commitToAnalysis(list((Collection) value));
            }
            else {
                commitToAnalysis(value);
            }
        }
        catch (Exception e) {
            throw new JspException("Exception in select", e);
        }
        return EVAL_BODY_INCLUDE;
    }
    
    public void radioSet(JspWriter out, List values, List labels, String selected) throws IOException {
        for (int i = 0; i < values.size(); i++) {
            String value = (String) values.get(i);
            out.write("<input type=\"radio\" name=\"" + getName() + "\" value=\"" + value + "\"");
            if (value.equals(selected)) {
                out.write(" checked=\"checked\"");
            }
            writeAttributes(out);
            out.write(" />");
            out.write((String) labels.get(i));
            out.write("\n");
        }
    }

    public Object getLabelList() {
        return labelList;
    }

    public void setLabelList(Object labelList) {
        this.labelList = ElabUtil.split(labelList);
    }

    public Object getValueList() {
        return valueList;
    }

    public void setValueList(Object valueList) {
        this.valueList = ElabUtil.split(valueList);
    }
}
