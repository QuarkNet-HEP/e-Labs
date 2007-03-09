/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * Bunch of Milestone with a group name.
 * 
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class MilestoneSet extends DBObject {

    private int id;
    private String name;
    private Set milestonePlacements;
    private Set groups;
    private Project project;
    private Project defaultProject;

    /**
     * Empty constructor for Hibernate.
     */
    public MilestoneSet() {}

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Owners are those who own the Project this Set is part of *
     */
    public Set grabOwners(){
        if(project != null){
            return project.grabOwners();
        }
        else{
            return null;
        }
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(name != null){
            s += name;
        }
        return s;
    }

    /**
     * @hibernate.id column="id" generator-class="hilo" unsaved-value="null"
     * @return The id of this milestone set.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 
    
    /**
     * @hibernate.property
     *      column="name"
     * @return The name of this milestone set.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.MilestonePlacement"
     * @hibernate.collection-key
     *      column="fk_milestone_set"
     * @return The set of milestone placements for this set of milestones.
     */
    public Set getMilestonePlacements() { return milestonePlacements; }
    public void setMilestonePlacements(Set milestonePlacements) { this.milestonePlacements = milestonePlacements; }

    /**
     * @hibernate.set
     *      table="groups_milestonesets"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_group"
     *      class="gov.fnal.elab.db.Group"
     * @hibernate.collection-key
     *      column="fk_milestone_set"
     * @return The groups that have this set of milestones as it's milestone set.
     */
    public Set getGroups() { return groups; }
    public void setGroups(Set groups) { this.groups = groups; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_project"
     * @return The project this milestone set is related to.
     */
    public Project getProject() { return project; }
    public void setProject(Project project) { this.project = project; }

    /**
     * This is really a one-to-one relationship, made possible by the unique identifier.
     * 
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      unique="true"
     * @return The project this milestone set is the default for (if this is the default for a project).
     */
    public Project getDefaultProject() { return defaultProject; }
    public void setDefaultProject(Project defaultProject) { this.defaultProject = defaultProject; } 

}
