//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class TR extends TagSupport {
    public static final String ATTR_TR = "elab:tr";
    private String name;

    public int doEndTag() throws JspException {
        pageContext.getRequest().removeAttribute(ATTR_TR);
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        pageContext.getRequest().setAttribute(ATTR_TR, name);
        return EVAL_BODY_INCLUDE;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
