//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 21, 2007
 */
package gov.fnal.elab.tags;

import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.util.ElabUtil;

import java.util.Collection;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class AnalysisParamLabel extends TagSupport {
    private String name, label;

    public int doStartTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();
            ElabAnalysis analysis = (ElabAnalysis) pageContext.getRequest()
                .getAttribute(Analysis.ATTR_ANALYSIS);
            if (analysis == null) {
                throw new JspException("No analysis found on this page"); 
            }
            else {
                Object value = analysis.getParameter(name);
                if (value != null && !value.equals("")) {
                    out.write(label);
                    if (value instanceof Collection) {
                        out.write(ElabUtil.join((Collection) value, ", "));
                    }
                    else {
                        out.write(value.toString());
                    }
                    TRTextArea ta = (TRTextArea) findAncestorWithClass(this, TRTextArea.class);
                    ta.registerLabelForUpdate(name, label);
                }
            }
        }
        catch (JspException e) {
            throw e;
        }
        catch (Exception e) {
            throw new JspException("Exception in popup", e);
        }
        return EVAL_PAGE;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        Map map = (Map) pageContext.getRequest().getAttribute(TRLabel.LABEL_MAP);
        if (map != null) {
            setLabel((String) map.get(name));
        }
        else {
            setLabel(name);
        }
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        if (label != null && !label.endsWith(" ")) {
            this.label = label + ' ';
        }
        else {
            this.label = label;
        }
    }
}
