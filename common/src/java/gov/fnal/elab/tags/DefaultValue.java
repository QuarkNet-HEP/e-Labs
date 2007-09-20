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
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.Tag;

public class DefaultValue extends BodyTagSupport {
    private String value;

    public int doEndTag() throws JspException {
        Tag parent = getParent();
        if (parent instanceof TRControl) {
        	TRControl trc = (TRControl) parent;
        	trc.setDefault(bodyContent.getString().trim());
        }
        else {
        	throw new JspException(
                    "Invalid location of 'default' tag. Must be a child of a trcontrol (e.g. trinput, trtextarea)");
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        return EVAL_BODY_BUFFERED;
    }
}
