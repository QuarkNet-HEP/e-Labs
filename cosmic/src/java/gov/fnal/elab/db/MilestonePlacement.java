/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * Contains a relationship to a {@link Milestone} with placement attributes 
 * such as a section and an id within that section. Thus there is 2 levels of 
 * placement data.<br/>
 * {@link MilestoneSet}s contain sets of these objects instead of the
 * <code>Milestone</code>s themselves.
 * 
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class MilestonePlacement extends DBObject {

    private int id;
    private String section;
    private String sectionId;
    private Milestone milestone;
    private MilestoneSet milestoneSet;

    /**
     * Empty constructor for Hibernate.
     */
    public MilestonePlacement() {}
     
    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     */
    public Set grabOwners(){
        return milestoneSet.grabOwners();
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(section != null){
            s += section + " ";
        }
        if(sectionId != null){
            s += sectionId + " ";
        }
        if(milestone != null){
            s += milestone.getName();
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this property value.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="section"
     *      type="text"
     * @return The section of this milestone. Used for categorizing.
     */
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }

    /**
     * @hibernate.property
     *      column="section_id"
     *      type="text"
     * @return The section id of this milestone. Used for ordering within a category.
     */
    public String getSectionId() { return sectionId; }
    public void setSectionId(String sectionId) { this.sectionId = sectionId; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_milestone"
     * @return The milestone that these are placement attributes for.
     */
    public Milestone getMilestone() { return milestone; }
    public void setMilestone(Milestone milestone) { this.milestone = milestone; }
    
    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_milestone_set"
     * @return The milestone set these attributes on a milestone are part of.
     */
    public MilestoneSet getMilestoneSet() { return milestoneSet; }
    public void setMilestoneSet(MilestoneSet milestoneSet) { this.milestoneSet = milestoneSet; }
    
}
