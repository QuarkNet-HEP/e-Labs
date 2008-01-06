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
import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

public class TRLabel extends BodyTagSupport {
    public static String LABEL_MAP = "elab:labelMap";
    
    private String _for, name;

    public int doEndTag() throws JspException {
        String tr = (String) pageContext.getRequest().getAttribute(TR.ATTR_TR); 
        if (tr == null) {
            throw new JspException(
                    "elab:trlabel must be a descendant of e:tr or e:analysis");
        }
        String label = bodyContent.getString();
        updateLabelMap(_for, label);
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
            out.write(label);
            out.write("</label>");
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_PAGE;
    }
    
    public int doStartTag() throws JspException {
        return EVAL_BODY_BUFFERED;
    }
    
    protected void updateLabelMap(String name, String label) {
        Map map = (Map) pageContext.getRequest().getAttribute(LABEL_MAP);
        if (map == null) {
            map = new HashMap();
            pageContext.getRequest().setAttribute(LABEL_MAP, map);
        }
        map.put(name, label);
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
