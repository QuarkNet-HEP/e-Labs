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
import gov.fnal.elab.analysis.BeanWrapper;
import gov.fnal.elab.analysis.ElabAnalysis;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class UseBean extends TagSupport {
	private Object bean;

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
			ElabAnalysis analysis = new BeanWrapper(bean);
			setAnalysisParams(analysis);

			pageContext.getRequest().setAttribute(Analysis.ATTR_ANALYSIS,
					analysis);
		}
		catch (JspException e) {
			throw e;
		}
		catch (Exception e) {
			throw new JspException(e);
		}
		return EVAL_BODY_INCLUDE;
	}

	protected void setAnalysisParams(ElabAnalysis analysis) {
		Analysis.setAnalysisParams(pageContext, analysis, null);
	}

	public Object getBean() {
		return bean;
	}

	public void setBean(Object bean) {
		this.bean = bean;
	}
}
