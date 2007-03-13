/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabProperties;
import gov.fnal.elab.usermanagement.impl.DatabaseUserManagementProvider;

public class ElabUserManagementProviderFactory {
	private static ElabUserManagementProvider defaultProvider;
	
    public static synchronized ElabUserManagementProvider getDefault(ElabProperties props) {
    	if (defaultProvider == null) {
    		defaultProvider = new DatabaseUserManagementProvider(props);
    	}
    	return defaultProvider;
    }
}
