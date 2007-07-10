//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.analysis.ElabAnalysis;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class TRDefault extends TagSupport {
    private String name;
    private Object value;

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        ElabAnalysis analysis = (ElabAnalysis) pageContext.getRequest()
                .getAttribute(Analysis.ATTR_ANALYSIS);
        if (analysis == null) {
            throw new JspException("No analysis found. <trdefault> must be a descendant of <analysis>.");
        }
        analysis.setParameterDefault(getName(), getValue());
        return EVAL_BODY_INCLUDE;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Object getValue() {
        return value;
    }

    public void setValue(Object value) {
        this.value = value;
    }
}
