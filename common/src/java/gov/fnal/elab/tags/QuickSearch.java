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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class QuickSearch extends TagSupport {
    private String key, value, label;

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {          
            Elab elab = (Elab) pageContext.getRequest().getAttribute("elab");
            if (elab == null) {
                throw new JspException("elab:quicksearch requires elab.jsp to be included"); 
            }
            String l = label;
            if (l == null) {
                l = value;
            }
            JspWriter out = pageContext.getOut();
            out.write("<a href=\"?submit=true&key=");
            out.write(key);
            out.write("&value=");
            out.write(value);
            out.write("\">");
            out.write(l);
            out.write("</a>");
        }
        catch (JspException e) {
            throw e;
        }
        catch (Exception e) {
            throw new JspException("Exception in QuickSearch", e);
        }
        return EVAL_BODY_INCLUDE;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

        
}
