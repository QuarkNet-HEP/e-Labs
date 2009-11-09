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
import gov.fnal.elab.analysis.ElabAnalysis;
import gov.fnal.elab.analysis.TimeIntervalFormatter;
import gov.fnal.elab.estimation.Estimator;
import gov.fnal.elab.estimation.EstimatorSet;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class AnalysisRunTimeEstimator extends TagSupport {
    private static Map estimatorSets;

    public static final EstimatorSet NULL_SET = new EstimatorSet();

    private synchronized static EstimatorSet getEstimatorSet(Elab elab) {
        String clsname = elab.getProperty("analysis.runtime.estimator.set");
        if (clsname == null) {
            return NULL_SET;
        }
        if (estimatorSets == null) {
            estimatorSets = new HashMap();
        }
        EstimatorSet set = (EstimatorSet) estimatorSets.get(clsname);
        if (set == null) {
            try {
                set = (EstimatorSet) AnalysisRunTimeEstimator.class.getClassLoader().loadClass(clsname).newInstance();
            }
            catch (Exception e) {
                e.printStackTrace();
                set = NULL_SET;
            }
            estimatorSets.put(clsname, set);
        }
        return set;
    }

    public static Estimator getEstimator(Elab elab, String engine,
            String method, String type) {
        return getEstimatorSet(elab).getEstimator(engine, method, type);
    }

    private String engine, mode;

    private static final Integer NONE = Integer.valueOf(-1);

    public int doStartTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();
            Elab elab = (Elab) pageContext.getRequest().getAttribute("elab");
            ElabAnalysis analysis = (ElabAnalysis) pageContext.getRequest()
                    .getAttribute(Analysis.ATTR_ANALYSIS);
            if (analysis == null) {
                throw new JspException("No analysis found on this page");
            }
            else {
                Estimator p = getEstimator(elab, engine, mode, analysis
                        .getType());
                String estimated;
                if (p == null) {
                    estimated = "N/A";
                }
                else {
                    int pt = p.estimate(elab, analysis);
                    if (pt == -1) {
                        estimated = "N/A";
                    }
                    else {
                        estimated = TimeIntervalFormatter.formatSeconds(pt);
                    }
                }

                out.write(estimated);
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

    public String getEngine() {
        return engine;
    }

    public void setEngine(String engine) {
        this.engine = engine;
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }
}
