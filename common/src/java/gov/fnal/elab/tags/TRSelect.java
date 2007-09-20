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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

public class TRSelect extends TRControl {
    private Collection valueList, labelList;

    public int doEndTag() throws JspException {
        try {
            pageContext.getOut().write("</select>\n");
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            String selected = String.valueOf(getValue());
            if (selected == null || selected.equals("")) {
                if (valueList != null && valueList.size() > 0) {
                    selected = String.valueOf(valueList.iterator().next());
                }
            }
            JspWriter out = pageContext.getOut();
            out.write("<select");
            writeDynamicLabelUpdater(out);
            writeAttribute(out, "name", getName());
            writeAttributes(out);
            out.write(">\n");
            ElabUtil.optionSet(out, getValueList(), getLabelList(), selected);
            commitToAnalysis(selected);
        }
        catch (Exception e) {
            throw new JspException("Exception in select", e);
        }
        return EVAL_BODY_INCLUDE;
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
