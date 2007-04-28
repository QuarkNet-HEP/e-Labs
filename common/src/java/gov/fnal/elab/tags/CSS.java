//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.Elab;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class CSS extends TagSupport {
    private String file;

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {          
            Elab elab = (Elab) pageContext.getRequest().getAttribute("elab");
            if (elab == null) {
                throw new JspException("elab:css requires elab.jsp to be included"); 
            }
            pageContext.getOut().write(
                    elab.css((HttpServletRequest) pageContext.getRequest(), file));
        }
        catch (JspException e) {
            throw e;
        }
        catch (Exception e) {
            throw new JspException("Exception in CSS", e);
        }
        return SKIP_BODY;
    }

    public String getFile() {
        return file;
    }

    public void setFile(String file) {
        this.file = file;
    }    
}
