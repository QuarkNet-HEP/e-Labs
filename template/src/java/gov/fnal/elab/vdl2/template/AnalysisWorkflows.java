package gov.fnal.elab.vdl2.template;

import gov.fnal.elab.vdl2.KarajanWorkflow;
import gov.fnal.elab.vdl2.Workflows;

public class AnalysisWorkflows extends Workflows{

	private static AnalysisWorkflows workflows;

	public static synchronized Workflows getDefault() {
		if (workflows == null) {
			workflows = new AnalysisWorkflows();
			// NOTE: Make sure template.vds.home is set up properly in the elab.properties file of your deployment
			//String wfdir = System.getProperty("template.vds.home");
			String wfdir = "/Users/tiberius/local/apache-tomcat-5.5.17/webapps/elab/template/output";
			
			workflows.addTemplate(new KarajanWorkflow.Template("Analysis", wfdir + "/analysis-wf.kml"));
		}
		return workflows;
	}
	
}
