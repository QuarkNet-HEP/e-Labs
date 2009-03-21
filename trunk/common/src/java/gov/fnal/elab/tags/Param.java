package gov.fnal.elab.tags;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;


public class Param extends TagSupport {
    public static interface Parent {
        public static final String ATTR_PARAM_PARENT = "param:parent";
        
        void addParameter(String name, String value);
    }
    
    private String name, value;

    public int doStartTag() throws JspException {
        Parent p = (Parent) pageContext.getAttribute(Parent.ATTR_PARAM_PARENT);
        if (p == null) {
            throw new JspException("param tag used without a parent");
        }
        else {
            p.addParameter(name, value);
        }
        return EVAL_BODY_INCLUDE;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
