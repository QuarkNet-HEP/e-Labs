package gov.fnal.elab.vdl2.cms;

import gov.fnal.elab.vdl2.KarajanWorkflow;
import gov.fnal.elab.vdl2.Workflows;

public class CMSWorkflows extends Workflows{

	private static CMSWorkflows workflows;

	public static synchronized Workflows getDefault() {
		if (workflows == null) {
			workflows = new CMSWorkflows();
			String wfdir = System.getProperty("cms.vds.home");
			workflows.addTemplate(new KarajanWorkflow.Template("OGRE", wfdir + "/ogre-wfk.xml"));
		}
		return workflows;
	}
	
}
