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

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.DynamicAttributes;
import javax.servlet.jsp.tagext.TagSupport;

public class Select extends TagSupport implements DynamicAttributes {
    private Map attrs;
    private String labelList, valueList, selected, name, _default;

    public Select() {
        attrs = new HashMap();
    }

    public int doEndTag() throws JspException {
        try {
            pageContext.getOut().write("</select>\n");
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            String name = getName();
            String selected = getSelected();
            if (name != null && selected == null) {
                selected = pageContext.getRequest().getParameter(name);
                if (selected == null) {
                    selected = getDefault();
                }
            }
            JspWriter out = pageContext.getOut();
            out.write("<select");
            DynamicAttributesSupport.writeAttribute(out, "name", getName());
            DynamicAttributesSupport.writeAttributes(out, attrs);
            ElabUtil.optionSet(pageContext.getOut(), getValueList(),
                    getLabelList(), selected);
        }
        catch (Exception e) {
            throw new JspException("Exception in optionset", e);
        }
        return EVAL_BODY_INCLUDE;
    }

    public String getDefault() {
        return _default;
    }

    public void setDefault(String _default) {
        this._default = _default;
    }

    public String getLabelList() {
        return labelList;
    }

    public void setLabelList(String labelList) {
        this.labelList = labelList;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSelected() {
        return selected;
    }

    public void setSelected(String selected) {
        this.selected = selected;
    }

    public String getValueList() {
        return valueList;
    }

    public void setValueList(String valueList) {
        this.valueList = valueList;
    }

    protected Object getAttribute(String name) {
        return attrs.get(name);
    }

    protected String getStringAttribute(String name) {
        return (String) getAttribute(name);
    }

    public void setDynamicAttribute(String uri, String localName, Object value)
            throws JspException {
        attrs.put(localName, value);
    }
}
