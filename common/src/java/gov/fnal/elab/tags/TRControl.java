/*
 * Created on Apr 9, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.analysis.ElabAnalysis;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.DynamicAttributes;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.taglibs.standard.lang.support.ExpressionEvaluatorManager;

public abstract class TRControl extends TagSupport implements DynamicAttributes {
    private Map attrs;
    private String name, onError;
    private Object value;
    private Object _default;

    public TRControl() {
        attrs = new HashMap();
    }

    protected void writeAttribute(JspWriter out, String name, Object v)
            throws IOException {
        DynamicAttributesSupport.writeAttribute(out, name, v);
    }

    protected void writeAttributes(JspWriter out) throws IOException {
        DynamicAttributesSupport.writeAttributes(out, attrs);
    }

    public Object getDefault() {
        return _default;
    }

    public void setDefault(Object _default) {
        this._default = _default;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getOnError() {
        return onError;
    }

    public void setOnError(String onError) {
        this.onError = onError;
    }
    
    protected String getParamName() {
        Map aliases = (Map) pageContext.getRequest().getAttribute(ParamAlias.ATTR_ALIASES);
        String alias = null;
        String name = getName();
        if (aliases != null) {
            alias = (String) aliases.get(name);
            if (alias == null) {
                alias = name;
            }
        }
        else {
            alias = name;
        }
        return alias;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    public Object getValue() throws JspException {
        Object v = evaluate("value", value);
        ElabAnalysis analysis = getAnalysis();
        if (v == null && analysis != null) {
            v = analysis.getParameter(getParamName());
            if (analysis.isDefaultValue(getParamName(), v)) {
                v = null;
            }
        }
        if (v == null) {
            v = pageContext.getRequest().getParameter(getName());
        }
        if (v == null) {
            v = _default;
        }
        if (v == null && analysis != null) {
            v = analysis.getParameter(getParamName());
        }
        return v;
    }
    
    protected Object evaluate(String name, Object value) throws JspException {
        if (value instanceof String) {
            return ExpressionEvaluatorManager.evaluate(name, (String) value,
                    Object.class, this, pageContext);
        }
        else {
            return value;
        }
    }

    public ElabAnalysis getAnalysis() {
        return (ElabAnalysis) pageContext.getRequest().getAttribute(
                Analysis.ATTR_ANALYSIS);
    }

    protected Object getAttribute(String name) {
        return attrs.get(name);
    }

    protected String getStringAttribute(String name) {
        return (String) getAttribute(name);
    }

    protected Map getAttributes() {
        return attrs;
    }

    public void setDynamicAttribute(String uri, String localName, Object value)
            throws JspException {
        attrs.put(localName, value);
    }
    
    public void setDynamicAttributes(Map attrs) {
        this.attrs = attrs; 
    }
}
