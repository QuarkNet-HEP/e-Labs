//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Sep 25, 2006
 */
package gov.fnal.elab.vdl2;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpSession;

public class Workflows {
public static final String SESSION_WORKFLOWS = "vdsWorkflows";

	private Map workflowTemplates;
	
	protected void addTemplate(Workflow.Template template) {
		workflowTemplates.put(template.getName(), template);
	}
	
	protected Workflow.Template getTemplate(String name) throws InvalidWorkflowException {
		Workflow.Template template = (Workflow.Template) workflowTemplates.get(name);
		if (template == null) {
			throw new InvalidWorkflowException("No such workflow: "+name, getWorkflowNames());
		}
		else {
			return template;
		}
	}

	public Collection getWorkflowNames() {
		return workflowTemplates.keySet();
	}
	
	protected Workflows() {
		workflowTemplates = new HashMap();
	}

	protected static Map getWorkflows(HttpSession session) {
		Map workflows;
		synchronized (session) {
			workflows = (Map) session.getAttribute(SESSION_WORKFLOWS);
			if (workflows == null) {
				workflows = new TreeMap();
			}
			session.setAttribute(SESSION_WORKFLOWS, workflows);
		}
		return workflows;
	}

	public static Collection getWorkflowIDS(HttpSession session) {
		Map workflows = getWorkflows(session);
		synchronized (workflows) {
			return new ArrayList(workflows.keySet());
		}
	}

	public static Workflow getWorkflow(HttpSession session, String id) {
		Map workflows = getWorkflows(session);
		synchronized (workflows) {
			return (Workflow) workflows.get(id);
		}
	}

	public static void removeWorkflow(HttpSession session, String id) {
		Map workflows = getWorkflows(session);
		synchronized (workflows) {
			workflows.remove(id);
		}
	}
	
	private static Workflows workflows;
	
	public static synchronized Workflows getDefault() {
		if (workflows == null) {
			workflows = new Workflows();
		}
		return workflows;
	}
	
	public Workflow newInstance(String name) throws InvalidWorkflowException {
		return getTemplate(name).newInstance();
	}
}
