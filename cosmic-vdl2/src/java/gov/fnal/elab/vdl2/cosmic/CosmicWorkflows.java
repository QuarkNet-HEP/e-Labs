//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Oct 16, 2006
 */
package gov.fnal.elab.vdl2.cosmic;

import gov.fnal.elab.vdl2.KarajanWorkflow;
import gov.fnal.elab.vdl2.Workflows;

public class CosmicWorkflows extends Workflows {
	private static CosmicWorkflows workflows;

	public static synchronized Workflows getDefault() {
		if (workflows == null) {
			workflows = new CosmicWorkflows();
			String wfdir = System.getProperty("vds.home");
			workflows.addTemplate(new KarajanWorkflow.Template("FluxStudy", wfdir + "/fluxk.xml"));
			workflows.addTemplate(new KarajanWorkflow.Template("PerformanceStudy", wfdir + "/performancek.xml"));
			workflows.addTemplate(new KarajanWorkflow.Template("LifetimeStudy", wfdir + "/lifetimek.xml"));
			workflows.addTemplate(new KarajanWorkflow.Template("ShowerStudy", wfdir + "/showerk.xml"));
		}
		return workflows;
	}
}
