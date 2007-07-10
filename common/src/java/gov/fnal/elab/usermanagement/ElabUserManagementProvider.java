/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;
import java.util.List;

public interface ElabUserManagementProvider {
    ElabGroup authenticate(String username, String password, String project)
            throws AuthenticationException;

    void resetFirstTime(String groupId) throws ElabException;
    
    Collection getTeachers() throws ElabException;
    
    /**
     * Adds a user under the specified teacher. The user should have a group
     * associated. If the group does not exist, it will be created.
     */
    List addUsers(ElabGroup teacher, List users, List createGroup) throws ElabException;
    
    void updateGroup(ElabGroup group, String password) throws ElabException;
    
    ElabGroup getTeacher(ElabGroup user) throws ElabException;
    
    void deleteStudent(ElabGroup group, String id) throws ElabException;
    
    Collection getProjectNames() throws ElabException;
    
    Collection getProjectNames(ElabGroup group) throws ElabException;
    
    void updateProjects(ElabGroup group, String[] projectNames) throws ElabException;
    
    boolean isStudentInGroup(ElabGroup group, String id) throws ElabException;
}
