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
import gov.fnal.elab.ElabFactory;
import gov.fnal.elab.analysis.AnalysisParameterTransformer;
import gov.fnal.elab.analysis.ElabAnalysis;

import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.TagSupport;

public class Analysis extends TagSupport {
    public static final String ATTR_ANALYSIS = "elab:analysis";

    private String name, impl, type, param, parameterTransformer;

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }

    public int doStartTag() throws JspException {
        try {
            Elab elab = (Elab) pageContext.getRequest().getAttribute("elab");
            if (elab == null) {
                throw new JspException(
                        "No elab available. Did you include elab.jsp?");
            }
            ElabAnalysis old = (ElabAnalysis) pageContext.getRequest()
                    .getAttribute(ATTR_ANALYSIS);
            ElabAnalysis analysis = ElabFactory.newElabAnalysis(elab, impl,
                    param);
            analysis.setType(type);
            if (old != null) {
                if (!compareType(type, old.getType())) {
                    throw new JspException(
                            "Stored analysis type doesn't match the requested "
                                    + "analysis type. Perhaps rerun.jsp redirected to the "
                                    + "wrong analysis page?");
                }
                pageContext.getSession().removeAttribute(ATTR_ANALYSIS);

                /*
                 * The old analysis cannot be used if the current analysis type
                 * has added parameters to the signature. So a copy must be
                 * made.
                 */
                Iterator i = old.getParameters().entrySet().iterator();
                while (i.hasNext()) {
                    Map.Entry e = (Map.Entry) i.next();
                    String name = (String) e.getKey();
                    if (analysis.hasParameter(name)) {
                        analysis.setParameter(name, e.getValue());
                    }
                }
                analysis.setAttributes(old.getAttributes());
            }

            setAnalysisParams(analysis);

            pageContext.getRequest().setAttribute(ATTR_ANALYSIS, analysis);
            pageContext.getRequest().setAttribute(TR.ATTR_TR, type);
            if (name != null) {
                pageContext.getRequest().setAttribute(name, analysis);
            }
        }
        catch (JspException e) {
            throw e;
        }
        catch (Exception e) {
            throw new JspException(e);
        }
        return EVAL_BODY_INCLUDE;
    }

    protected boolean compareType(String t1, String t2) {
        // should we or should we not allow such incompatibilities
        return true;
    }

    protected void setAnalysisParams(ElabAnalysis analysis) {
        setAnalysisParams(pageContext, analysis,
                getParameterTransformerInstance());
    }

    protected static void setAnalysisParams(PageContext pageContext,
            ElabAnalysis analysis, AnalysisParameterTransformer t) {
        Map aliases = (Map) pageContext.getRequest().getAttribute(
                ParamAlias.ATTR_ALIASES);
        if (aliases == null) {
            aliases = Collections.EMPTY_MAP;
        }
        ServletRequest request = pageContext.getRequest();
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            String name = (String) e.nextElement();
            String analysisParamName = (String) aliases.get(name);
            if (analysisParamName == null) {
                analysisParamName = name;
            }
            if (!analysis.hasParameter(analysisParamName)
                    || analysisParamName.equals(TRSubmit.CONTROL_NAME)) {
                continue;
            }
            Class type = analysis.getParameterType(analysisParamName);
            if (type == null) {
                throw new IllegalArgumentException(
                        "The analysis did not report a type for "
                                + analysisParamName);
            }
            if (type.equals(String.class)) {
                analysis.setParameter(analysisParamName, request
                        .getParameter(name));
            }
            else if (type.equals(Boolean.class) || type.equals(boolean.class)) {
                analysis.setParameter(analysisParamName, Boolean
                        .valueOf(request.getParameter(name)));
            }
            else if (type.equals(List.class)) {
                analysis.setParameter(analysisParamName, Arrays.asList(request
                        .getParameterValues(name)));
            }
            else if (type.equals(Object.class)) {
                /*
                 * As a last resort, try to figure out the type from the
                 * request. This is likely to break in the general case.
                 */
                String[] values = request.getParameterValues(name);
                if (values != null && values.length > 1) {
                    analysis.setParameter(analysisParamName, Arrays
                            .asList(values));
                }
                else {
                    analysis.setParameter(analysisParamName, request
                            .getParameter(name));
                }
            }
            else {
                throw new IllegalArgumentException(
                        "Could not set analysis parameter '" + name
                                + "'. Unsupported type: " + type);
            }
        }
        analysis.setParameterTransformer(t);
    }

    public String getImpl() {
        return impl;
    }

    public void setImpl(String impl) {
        this.impl = impl;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getParam() {
        return param;
    }

    public void setParam(String param) {
        this.param = param;
    }

    public String getParameterTransformer() {
        return parameterTransformer;
    }

    public void setParameterTransformer(String parameterTransformer) {
        this.parameterTransformer = parameterTransformer;
    }

    protected AnalysisParameterTransformer getParameterTransformerInstance() {
        if (parameterTransformer == null) {
            return null;
        }
        else {
            try {
                return (AnalysisParameterTransformer) Class.forName(
                        parameterTransformer).newInstance();
            }
            catch (Exception e) {
                throw new IllegalArgumentException(
                        "Invalid parameter transformer: "
                                + parameterTransformer + ": " + e.getMessage());
            }
        }
    }
}
