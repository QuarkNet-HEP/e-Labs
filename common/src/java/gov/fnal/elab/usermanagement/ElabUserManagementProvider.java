/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement;

import java.sql.SQLException;

import gov.fnal.elab.ElabUser;

public interface ElabUserManagementProvider {
    ElabUser authenticate(String username, String password, String project)
            throws AuthenticationException;

    void resetFirstTime(String groupId) throws SQLException;
}
