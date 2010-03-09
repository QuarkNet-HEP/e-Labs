package gov.fnal.elab.tags;

import gov.fnal.elab.analysis.AnalysisRun;
import gov.fnal.elab.analysis.ElabAnalysis;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class Rerun extends TagSupport implements Param.Parent {
    private String label, type, cclass;
    private Object analysis;
    private String id;
    private Map params;

    public Rerun() {
        params = new HashMap();
    }

    public int doEndTag() throws JspException {
        pageContext.removeAttribute(ATTR_PARAM_PARENT);
        try {
            JspWriter out = pageContext.getOut();
            out.write("<a href=\"../analysis/rerun.jsp?study=" + type);
            if (analysis instanceof ElabAnalysis) {
                ElabAnalysis a = (ElabAnalysis) analysis;
                pageContext.getSession().setAttribute("analysisToRerun", a);
            }
            else if (id != null) {
                out.write("&id=" + id);
            }
            else {
                throw new JspException("Invalid analysis.");
            }
            if (!params.isEmpty()) {
                out.write("&");
                Iterator i = params.entrySet().iterator();
                while (i.hasNext()) {
                    Map.Entry e = (Map.Entry) i.next();
                    out.write(String.valueOf(e.getKey()));
                    out.write("=");
                    out.write(String.valueOf(e.getValue()));
                    if (i.hasNext()) {
                        out.write("&");
                    }
                }
            }
            out.write("\"");
            if (cclass != null) {
                out.write(" class=\"");
                out.write(cclass);
                out.write("\"");
            }
            out.write(">");
            out.write(label);
            out.write("</a>");
        }
        catch (JspException e) {
            throw e;
        }
        catch (Exception e) {
            throw new JspException("Exception in rerun", e);
        }
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        params.clear();
        pageContext.setAttribute(ATTR_PARAM_PARENT, this);
        return EVAL_BODY_INCLUDE;
    }

    public Object getAnalysis() {
        return analysis;
    }

    public void setAnalysis(Object analysis) {
        this.analysis = analysis;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void addParameter(String name, String value) {
        params.put(name, value);
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCclass() {
        return cclass;
    }

    public void setCclass(String cclass) {
        this.cclass = cclass;
    }
}
