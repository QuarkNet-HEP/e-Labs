//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Oct 10, 2006
 */
package gov.fnal.elab.vdl2;

import java.util.Collection;

public class InvalidWorkflowException extends Exception {
	private Collection valid;
	
	public InvalidWorkflowException(String message, Collection valid) {
		super(message);
		this.valid = valid;
	}
	
	public Collection getValid() {
		return valid;
	}
}
