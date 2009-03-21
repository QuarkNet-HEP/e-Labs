/*
 * Created on Apr 9, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.analysis.ElabAnalysis;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
        Map aliases = (Map) pageContext.getRequest().getAttribute(
                ParamAlias.ATTR_ALIASES);
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
        Object v = getControlValue();
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
    
    protected Object getControlValue() throws JspException {
        return getIntrinsicValue();
    }
    
    protected Object getIntrinsicValue() throws JspException {
        return evaluate("value", value);
    }

    /**
     * Used to deal with the case when multiple parameters with the same name
     * are passed. It generates an internal iterator which goes through all the
     * values.
     */
    protected Object nextValue() throws JspException {
        Object v = getValue();
        if (v instanceof Collection) {
            Iterator i = (Iterator) pageContext.getRequest().getAttribute(
                    getName() + ":iter");
            if (i == null) {
                i = ((Collection) v).iterator();
                pageContext.getRequest().setAttribute(getName() + ":iter", i);
            }
            if (i.hasNext()) {
                return i.next();
            }
            else {
                return "";
            }
        }
        else {
            return v;
        }
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

    protected void writeDynamicLabelUpdater(JspWriter out) throws IOException {
        if (!getAttributes().containsKey("onChange")) {
            // this bit to dynamically update labels in text controls
            DynamicAttributesSupport.writeAttribute(out, "onChange",
                    "javascript:updateLabels(this, '" + getName() + "')");
        }
    }

    public void setDynamicAttributes(Map attrs) {
        this.attrs = attrs;
    }

    protected boolean isAnalysisParameterValid() {
        ElabAnalysis analysis = getAnalysis();
        if (analysis == null) {
            return true;
        }
        else {
            return analysis.isParameterValid(getParamName());
        }
    }

    protected void commitToAnalysis(Object value) {
        ElabAnalysis analysis = getAnalysis();
        if (analysis != null) {
            analysis.setParameter(getName(), value);
        }
    }
    
    protected List list(Collection c) {
        if (c instanceof List) {
            return (List) c;
        }
        else {
            return new ArrayList(c);
        }
    }
    
    protected void clearAttributes() {
        if (attrs != null) {
            attrs.clear();
        }
    }
}
