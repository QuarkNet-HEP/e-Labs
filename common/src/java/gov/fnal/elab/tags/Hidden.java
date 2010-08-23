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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class Hidden extends TagSupport {
    private String image;

    public Hidden() {
    }

    public int doEndTag() throws JspException {
        try {
            ElabUtil.vsWriteHiddenEnd(pageContext.getOut());
        }
        catch (Exception e) {
            throw new JspException("Exception in elab:hidden", e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();
            String id = "vsId-" + ((Integer) pageContext.getAttribute(VSwitch.ATTR_ID)).toString();
            String cls = (String) pageContext.getAttribute(VSwitch.ATTR_CLS);
            String title = (String) pageContext.getAttribute(VSwitch.ATTR_TITLE);
            String titleclass = (String) pageContext.getAttribute(VSwitch.ATTR_TITLE_CLS);
            Boolean revert = (Boolean) pageContext
                    .getAttribute(VSwitch.ATTR_REVERT);
            ElabUtil.vsWriteHiddenStart(out, id, cls, image,
                    revert == null ? false : revert.booleanValue(), title, titleclass);
        }
        catch (Exception e) {
            throw new JspException("Exception in elab:hidden", e);
        }
        return EVAL_BODY_INCLUDE;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }
}
