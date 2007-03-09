package gov.fnal.elab.util;

import gov.fnal.elab.db.*;
import java.util.Set;

/**
 * A class containing the current {@link Login}, {@link Project} and {@link Group}
 * for the session. These values are typically set during authentication and
 * together specify the information needed to present the correct section of the
 * eLab site to them.
 *
 * @author  Hao Zhou
 * @author  Paul Nepywoda
 */
public class SessionLogin {

    private int loginId;
    private int projectId;
    private int groupId;
    
    /**
     * Constructor.
     * @param   loginId   the id of the login to associate with this session
     * @param   projectId the id of the project to associate with this login
     * @param   groupId the id of the group to associate with this login
     */
    public SessionLogin(int loginId, int projectId, int groupId){
        this.loginId = loginId;
        this.projectId = projectId;
        this.groupId = groupId;
    }
    
    /**
     * Constructor.
     * @param   login   the login to associate with this session
     * @param   project the project to associate with this login
     * @param   group the group to associate with this login
     */
    public SessionLogin(Login login, Project project, Group group){
        setLogin(login);
        setProject(project);
        setGroup(group);
    }
    
    /**
     * Set the current login for this session.
     * @param   login   the login to associate with this session
     */
    public void setLogin(Login login){
        loginId = login.getId();
    }
    
    /**
     * Get the current login object.
     */
    public Login getLogin() throws ElabException{
		return (Login)DBObject.findById("Login", loginId);
    }
    
    /**
     * Set the current project for this login
     * @param   project the project to associate with this login
     */
    public void setProject(Project project){
        projectId = project.getId();
    }
    
    /**
     * Get the current Project object associated with the current Login for
     * this session.
     */
    public Project getProject() throws ElabException{
		return (Project)DBObject.findById("Project", projectId);
    }

    /**
     * Set the current group for this login
     * @param   group the group to associate with this login
     */
    public void setGroup(Group group){
        groupId = group.getId();
    }
    
    /**
     * Get the current Group object associated with the current Login for
     * this session.
     */
    public Group getGroup() throws ElabException{
		return (Group)DBObject.findById("Group", groupId);
    }
}
