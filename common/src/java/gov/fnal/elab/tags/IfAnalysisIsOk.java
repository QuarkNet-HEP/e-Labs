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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.TagSupport;

public class IfAnalysisIsOk extends TagSupport {
    public static final String ATTR_ANALYSIS_IS_OK = "elab:analysisIsOk";

    public int doEndTag() throws JspException {
        return EVAL_PAGE;
    }
    
    protected static boolean isAnalysisOk(PageContext pageContext) {
        if (Boolean.TRUE.equals(pageContext.getRequest().getAttribute(
                ATTR_ANALYSIS_IS_OK))) {
            return true;
        }
        ElabAnalysis analysis = (ElabAnalysis) pageContext.getRequest()
                .getAttribute(Analysis.ATTR_ANALYSIS);
        if (analysis == null) {
            return false;
        }
        if (pageContext.getRequest().getParameter(TRSubmit.CONTROL_NAME) != null) {
            if (analysis.isValid()) {
                pageContext.getRequest().setAttribute(ATTR_ANALYSIS_IS_OK,
                        Boolean.TRUE);
                return true;
            }
        }
        return false;
    }

    protected boolean getCondition() {
        return isAnalysisOk(pageContext);
    }

    public int doStartTag() throws JspException {
        if (getCondition()) {
            return EVAL_BODY_INCLUDE;
        }
        else {
            return SKIP_BODY;
        }
    }
}
