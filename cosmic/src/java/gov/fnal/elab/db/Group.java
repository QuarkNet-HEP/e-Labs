/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import java.util.Date;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.type.Type;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.db.HibernateUtil;

/**
 * A group has a (unique) name and an optional start and end date. 
 * {@link Login}s can be part of groups and groups can be managed by 
 * {@link Manager}s.
 * 
 * @hibernate.class
 *      table="team"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Group extends DBObject {

    private int id;
    private String name;
    private Date startDate;
    private Date endDate;
    private Set projects;
    private Set logins;
    private Set managers;
    private Set milestoneSets;
    private Set comments;
    
    /**
     * Constructor for Hibernate.
     * Sets the start date to creation date
     * by default, and the end date to a year
     * later.
     */
    public Group() {
        startDate = new Date();
        endDate = new Date();
        endDate.setDate(endDate.getDate() + 7);
    }

    
    
    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * A group is owned by the managers that manage it *
     */
    public Set grabOwners(){
        return managers;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(name != null){
            s += name + " ";
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this login.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property column="name" unique="true" not-null="true"
     * @return The name of this group.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.property column="start_date"
     * @return The start date of this group.
     */
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    /**
     * @hibernate.property column="end_date"
     * @return The end date of this group.
     */
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    
    /**
     * @hibernate.set
     *      table="groups_projects"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_project"
     *      class="gov.fnal.elab.db.Project"
     * @hibernate.collection-key
     *      column="fk_group"
     * @return The set of projects that this group belongs to.
     */
    public Set getProjects() { return projects; }
    public void setProjects(Set projects) { this.projects = projects; }

    /**
     * @hibernate.set
     *      table="logins_groups"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_login"
     *      class="gov.fnal.elab.db.Login"
     * @hibernate.collection-key
     *      column="fk_group"
     * @return The logins that belong to this group.
     */
    public Set getLogins() { return logins; }
    public void setLogins(Set logins) { this.logins = logins; }

    /**
     * @hibernate.set
     *      table="groups_managers"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_manager"
     *      class="gov.fnal.elab.db.Manager"
     * @hibernate.collection-key
     *      column="fk_group"
     * @return The managers that manage this group.
     */
    public Set getManagers() { return managers; }
    public void setManagers(Set managers) { this.managers = managers; }

    /**
     * @hibernate.set
     *      table="groups_milestonesets"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_milestone_set"
     *      class="gov.fnal.elab.db.MilestoneSet"
     * @hibernate.collection-key
     *      column="fk_group"
     * @return The milestone sets this group has (one per project)
     */
    public Set getMilestoneSets() { return milestoneSets; }
    public void setMilestoneSets(Set milestoneSets) { this.milestoneSets = milestoneSets; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Comment"
     * @hibernate.collection-key
     *      column="fk_group"
     * @return The set of comments about this group
     */
    public Set getComments() { return comments; }
    public void setComments(Set comments) { this.comments = comments; }




    /**
     * Determine if this group is in a specific project.
     */
    public boolean isInProject(String s){
        if(getProjects() == null){
            return false;
        }
        for(Iterator i=getProjects().iterator(); i.hasNext(); ){
            Project p = (Project)i.next();
            if(s.equals(p.getName())){
                return true;
            }
        }
        return false;
    }

    /**
     * Reset the managers this login is in to just this one
     * NOTE: not sure if this is useful yet...
     */
    public void setManager(Manager p){
        managers = new HashSet();
        managers.add(p);
    }

    /**
     * Add a project for this login.
     * NOTE: not sure if this is useful yet...
     */
    public void addManager(Manager p){
        if(managers == null){
            managers = new HashSet();
        }
        managers.add(p);
    }
    /**
     * Reset the projects this login is in to just this one
     * NOTE: not sure if this is useful yet...
     */
    public void setProject(Project p){
        projects = new HashSet();
        projects.add(p);
    }

    /**
     * Add a project for this login.
     * NOTE: not sure if this is useful yet...
     */
    public void addProject(Project p){
        if(projects == null){
            projects = new HashSet();
        }
        projects.add(p);
    }

}
