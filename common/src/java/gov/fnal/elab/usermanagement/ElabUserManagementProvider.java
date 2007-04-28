/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabUser;

import java.sql.SQLException;
import java.util.Collection;

public interface ElabUserManagementProvider {
    ElabUser authenticate(String username, String password, String project)
            throws AuthenticationException;

    void resetFirstTime(String groupId) throws SQLException;
    
    Collection getTeachers() throws SQLException;
}
