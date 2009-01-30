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
import gov.fnal.elab.cosmic.util.AnalysisParameterTools;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

public class AnalysisRunTimeEstimator extends TagSupport {
    private static final Map estimators;

    private static void addEstimator(String engine, String method, String type,
            Estimator p) {
        estimators.put(engine.toLowerCase() + "-" + method.toLowerCase() + "-"
                + type, p);
    }
    
    private static final Estimator NULL = new NullEstimator();

    public static Estimator getEstimator(String engine, String method,
            String type) {
        if (engine == null || method == null) {
            return NULL;
        }
        Estimator p = (Estimator) estimators.get(engine.toLowerCase() + "-"
                + method.toLowerCase() + "-" + type);
        if (p == null) {
            return NULL;
        }
        else {
            return p;
        }
    }

    static {
        estimators = new HashMap();
        addEstimator("vds", "local", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.153424355, 2632.455));
        addEstimator("swift", "local", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.153424355, 2632.455));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.36819, 5327.64));
        addEstimator("swift", "grid", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.167697, 65988.4));
        addEstimator("swift", "mixed", "I2U2.Cosmic::PerformanceStudy",
                new LinearEventEstimator(0.282264, 1454.57));
        
        addEstimator("swift", "local", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.247119, 705.029));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.500107, 4839));
        addEstimator("swift", "grid", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.319383, 96234.4));
        //TODO this is a wild guess
        addEstimator("swift", "mixed", "I2U2.Cosmic::LifetimeStudy",
                new LinearEventEstimator(0.4, 1000));
        
        addEstimator("swift", "local", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(24251.6, -2.21535, 0.198371));
        addEstimator("swift", "grid", "I2U2.Cosmic::FluxStudy",
                new FluxEstimator(117392, -2.25828, 0.20651));
        
        addEstimator("swift", "local", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "i2u2", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "grid", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
        addEstimator("swift", "mixed", "I2U2.Cosmic::EventPlot",
                new ConstantEstimator(1));
    }

    private String engine, mode;
    
    private static final Integer NONE = new Integer(-1);

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
                Estimator p = getEstimator(engine, mode, analysis.getType());
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
                        estimated =  pt + " s";
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

    public static interface Estimator {
        public int estimate(Elab elab, ElabAnalysis analysis)
                throws ElabException;
    }

    /**
     * 
     * time = a + b * ev[c] + c * ev[c] * ln(ev[c])
     * 
     */
    public static class FluxEstimator implements Estimator {
        private double a, b, c;

        public FluxEstimator(double a, double b, double c) {
            this.a = a;
            this.b = b;
            this.c = c;
        }

        public synchronized int estimate(Elab elab, ElabAnalysis analysis)
                throws ElabException {
            Collection rd = (Collection) analysis.getParameter("rawData");
            String channel = (String) analysis.getParameter("singlechannel_channel");
            int events = AnalysisParameterTools.getEventCount(elab, rd, Integer.parseInt(channel));
            double ms = a + b * events + c * events * Math.log(events);
            
            return (int) (ms / 1000);
        }
    }
    
    /**
     * 
     * time = a * events + b
     * 
     */
    public static class LinearEventEstimator implements Estimator {
        private double a, b;

        public LinearEventEstimator(double a, double b) {
            this.a = a;
            this.b = b;
        }

        public synchronized int estimate(Elab elab, ElabAnalysis analysis)
                throws ElabException {
            Collection rd = (Collection) analysis.getParameter("rawData");
            int events = AnalysisParameterTools.getEventCount(elab, rd);
            double ms = a * events + b;
            
            return (int) (ms / 1000);
        }
    }
    
    public static class NullEstimator implements Estimator {
        public int estimate(Elab elab, ElabAnalysis analysis)
                throws ElabException {
            return -1;
        }
    }
    
    public static class ConstantEstimator implements Estimator {
        private int a;
        
        public ConstantEstimator(int a) {
            this.a = a;
        }
        
        public int estimate(Elab elab, ElabAnalysis analysis)
                throws ElabException {
            return a;
        }
    }
}
