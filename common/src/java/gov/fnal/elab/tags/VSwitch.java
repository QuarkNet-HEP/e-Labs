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

import org.apache.commons.lang.StringUtils;

public class VSwitch extends TagSupport {
    public static final String ATTR_ID = "elab:vSwitch.id";
    public static final String ATTR_COUNTER = "elab:vSwitch.counter";
    public static final String ATTR_CLS = "elab:vSwitch.class";
    public static final String ATTR_REVERT = "elab:vSwitch.revert";
    public static final String ATTR_TITLE = "elab:vSwitch.title";
    public static final String ATTR_TITLE_CLS = "elab:vSwitch.titleclass";
    
    private String cls, title, titleclass, id;
    private Boolean revert;
    
    public int doEndTag() throws JspException {
    	// Flush bean state 
    	id = null; 
    	cls = null;
    	title = null;
    	titleclass = null; 
    	revert = null; 
    	return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            if (StringUtils.isBlank(id)) {
                Integer oldid = (Integer) pageContext.getAttribute(ATTR_COUNTER);
                int aid; 
                if (oldid == null) {
                    aid = 0;
                }
                else {
                    aid = oldid + 1;
                }
                pageContext.setAttribute(ATTR_COUNTER, aid); 
                id = "vsId-" + aid; 
            }
            pageContext.setAttribute(ATTR_ID, id);
            pageContext.setAttribute(ATTR_CLS, cls);
            pageContext.setAttribute(ATTR_TITLE, title);
            pageContext.setAttribute(ATTR_TITLE_CLS, titleclass);
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

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getTitleclass() {
        return titleclass;
    }

    public void setTitleclass(String titleclass) {
        this.titleclass = titleclass;
    }

    public String getId() {
        return this.id; 
    }

    public void setId(String id) {
    	this.id = id; 
    }
}
