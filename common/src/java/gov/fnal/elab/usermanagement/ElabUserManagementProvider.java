/*
 * Created on Mar 5, 2007
 */
package gov.fnal.elab.usermanagement;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.util.ElabException;

import java.util.Collection;
import java.util.List;

public interface ElabUserManagementProvider extends ElabProvider {
	
	/**
	 * Attempts to authenticate a user with the given credential to this provider's elab.
	 * 
	 * @param username A user name (actually group name)
	 * @param password A password
	 * 
	 * @throws AuthenticationException if the authentication with the given credential fails
	 * for any reason
	 */
    ElabGroup authenticate(String username, String password)
            throws AuthenticationException;

    /**
     * Resets the first time flag for a group
     */
    void resetFirstTime(ElabGroup group) throws ElabException;
    
    /**
     * Returns a collection of all the teachers register with this provider's elab
     */
    Collection getTeachers() throws ElabException;
    
    /**
     * Adds a number of students under the specified teacher. The students should have a group
     * associated. If the group does not exist, it will be created.
     * 
     * @param teacher The teacher under which the new groups should be created
     * @param students A {@link java.util.List} of {@link ElabStudent}s to be added
     * @param createGroups A list of {@link java.lang.Boolean} values indicating, for each
     * student in the students list, whether the group associated with the student (and
     * accessible through {@link ElabStudent.getGroup()}) should also be registered. 
     */
    List addStudents(ElabGroup teacher, List students, List createGroups) throws ElabException;
    
    /**
     * Updates group information based on information stored in the group parameter and eventually
     * the password parameter.
     * 
     * @param group An {@link ElabGroup} object with the updated group information
     * @param password If not <code>null</code>, a new password to be associated with
     * the group 
     */
    void updateGroup(ElabGroup group, String password) throws ElabException;
    
    /**
     * Returns the teacher associated with the specified group
     */
    ElabGroup getTeacher(ElabGroup user) throws ElabException;
    
    ElabGroup getTeacher(int id) throws ElabException;
    
    /**
     * Removes a student from a group
     */
    void deleteStudent(ElabGroup group, int studentId) throws ElabException;
    
    /**
     * Returns a collection of available project names (elabs) in this deployment 
     */
    Collection getProjectNames() throws ElabException;
    
    /**
     * Returns a collection of project names that the given group is associated with
     */
    Collection getProjectNames(ElabGroup group) throws ElabException;
    
    /**
     * Updates the list of projects that a given group is associated with
     */
    void updateProjects(ElabGroup group, String[] projectNames) throws ElabException;
    
    /**
     * Returns <code>true</code> if a specific student belongs to the given group
     */
    boolean isStudentInGroup(ElabGroup group, int studentId) throws ElabException;
    
    ElabGroup getGroup(String name) throws ElabException;
    
    ElabGroup getGroupById(int id) throws ElabException; 
    
    void setTeacherInStudy(ElabGroup group) throws ElabException;
    
    void setTeacherInStudy(ElabGroup group, int testId) throws ElabException;
}
