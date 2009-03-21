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

public class VSwitch extends TagSupport {
    public static final String ATTR_ID = "elab:vSwitch.id";
    public static final String ATTR_CLS = "elab:vSwitch.class";
    public static final String ATTR_REVERT = "elab:vSwitch.revert";
    
    private String cls;
    private Boolean revert;
    
    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {          
            Integer oldid = (Integer) pageContext.getAttribute(ATTR_ID);
            int id; 
            if (oldid == null) {
                id = 0;
            }
            else {
                id = oldid.intValue() + 1;
            }
            pageContext.setAttribute(ATTR_ID, new Integer(id));
            pageContext.setAttribute(ATTR_CLS, cls);
            if (revert != null) {
                pageContext.setAttribute(ATTR_REVERT, revert);
            }
        }
        catch (Exception e) {
            throw new JspException("Exception in VSwitch", e);
        }
        return EVAL_BODY_INCLUDE;
    }

    public String getCls() {
        return cls;
    }

    public void setCls(String cls) {
        this.cls = cls;
    }

    public Boolean getRevert() {
        return revert;
    }

    public void setRevert(Boolean revert) {
        this.revert = revert;
    }
}
