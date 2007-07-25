//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class TRLabel extends TagSupport {
    private String _for, name;

    public int doEndTag() throws JspException {
        JspWriter out = pageContext.getOut();
        try {
            out.write("</label>");
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        String tr = (String) pageContext.getRequest().getAttribute(TR.ATTR_TR);
        if (tr == null) {
            throw new JspException(
                    "elab:trlabel must be a descendant of e:tr or e:analysis");
        }
        JspWriter out = pageContext.getOut();
        try {
            out.write("<a href=\"javascript:describe('");
            out.write(tr);
            out.write("','");
            out.write(_for);
            out.write("','");
            out.write(name);
            out.write("')\"><img src=\"../graphics/question.gif\"></a>");
            out.write("<label for=\"");
            out.write(_for);
            out.write("\">");
            return EVAL_BODY_INCLUDE;
        }
        catch (IOException e) {
            throw new JspException(e);
        }
    }

    public String getFor() {
        return _for;
    }

    public void setFor(String _for) {
        this._for = _for;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
