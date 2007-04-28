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
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class Popup extends TagSupport {
    private String href, width, height, target;

    public int doEndTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();
            out.write("</a>");
        }
        catch (Exception e) {
            throw new JspException("Exception in popup", e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();
            out.write("<a href=\"\" onclick=\"javascript:window.open('");
            out.write(href);
            out.write("', '");
            out.write(target);
            out.write("', 'width=");
            out.write(width);
            out.write(",height=");
            out.write(height);
            out.write("');\">");
        }
        catch (Exception e) {
            throw new JspException("Exception in popup", e);
        }
        return EVAL_BODY_INCLUDE;
    } 

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getHref() {
        return href;
    }

    public void setHref(String href) {
        this.href = href;
    }

    public String getWidth() {
        return width;
    }

    public void setWidth(String width) {
        this.width = width;
    }

    public String getTarget() {
        return target;
    }

    public void setTarget(String target) {
        this.target = target;
    }

    
}
