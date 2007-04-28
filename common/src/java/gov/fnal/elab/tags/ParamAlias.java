/*
 * Created on Apr 17, 2007
 */
package gov.fnal.elab.tags;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class ParamAlias extends TagSupport {
    public static final String ATTR_ALIASES = "elab:paramaliases";
    private String from, to;
    
    public int doStartTag() throws JspException {
        Map aliases = (Map) pageContext.getRequest().getAttribute(ATTR_ALIASES);
        if (aliases == null) {
            aliases = new HashMap();
            pageContext.getRequest().setAttribute(ATTR_ALIASES, aliases);
        }
        aliases.put(from, to);
        return EVAL_PAGE;
    }
    
    public String getFrom() {
        return from;
    }
    public void setFrom(String from) {
        this.from = from;
    }
    public String getTo() {
        return to;
    }
    public void setTo(String to) {
        this.to = to;
    }
}
