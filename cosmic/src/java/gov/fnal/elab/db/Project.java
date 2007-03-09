/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * Project models the elements necessary for a project in an e-Labs.  The decoupling
 * of {@link Login} and Project allows for groups to be members of many projects while
 * keeping their information in one place.
 *
 * @hibernate.class
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Project extends DBObject {

    private int id;
    private String name;
    private String description;
    private String audience; 
    private String subjectMatter;
    private Date startDate;
    private Date endDate;
    private Set groups;
    private Set contacts;
    private Set milestoneSets;
    private MilestoneSet defaultMilestoneSet;
    private Set tests;
    private Set projectProperties;
    private Set propertyNames;
    private Set comments;
    
    /**
     * Empty constructor for Hibernate.
     */
    public Project() {}

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
        Set owners = new HashSet();
        for(Iterator i=contacts.iterator(); i.hasNext(); ){
            Login login = (Login)i.next();
            //should always be true
            if(login instanceof Manager){
                owners.add(login);
            }
        }
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(name != null){
            s += name;
        }
        if(description != null){
            s += " " + description;
        }
        if(audience != null){
            s += " " + audience;
        }
        return s;
    }

    /**
     * @hibernate.id column="id" generator-class="hilo" unsaved-value="null"
     * @return The id of this project.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property column="name" 
     * @return The name of the project.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    /**
     * @hibernate.property 
     *      column="description" 
     *      type="text" 
     * @return The description of the project.
     */
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    /**
     * @hibernate.property column="audience" type="text"
     * @return The free-text description of the audience of this project.
     */
    public String getAudience() { return audience; }
    public void setAudience(String audience) { this.audience = audience; }

    /**
     * @hibernate.property column="subject_matter" type="text"
     * @return The free-text description of the subject matter of this project.
     */
    public String getSubjectMatter() { return subjectMatter; }
    public void setSubjectMatter(String subjectMatter) { this.subjectMatter = subjectMatter; }

    /**
     * @hibernate.property column="start_date"
     * @return The start date of this project.
     */
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    /**
     * @hibernate.property column="end_date"
     * @return The end date of this project.
     */
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    /**
     * @hibernate.set
     *      table="groups_projects"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_group"
     *      class="gov.fnal.elab.db.Group"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The groups that belong to this project.
     */
    public Set getGroups() { return groups; }
    public void setGroups(Set groups) { this.groups = groups; }

    /**
     * @hibernate.set
     *      table="projects_contacts"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_manager"
     *      class="gov.fnal.elab.db.Manager"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of managers in charge of this project. 
     */
    public Set getContacts() { return contacts; }
    public void setContacts(Set contacts) { this.contacts = contacts; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.MilestoneSet"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of milestone sets which have groups related to them.
     */
    public Set getMilestoneSets() { return milestoneSets; }
    public void setMilestoneSets(Set milestoneSets) { this.milestoneSets = milestoneSets; }

    /**
     * This is really a one-to-one relationship, made possible by the unique identifier.
     * 
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      unique="true"
     * @return The default milestone set of this project.
     */
    public MilestoneSet getDefaultMilestoneSet() { return defaultMilestoneSet; }
    public void setDefaultMilestoneSet(MilestoneSet defaultMilestoneSet) { this.defaultMilestoneSet = defaultMilestoneSet; } 

    /**
     * @hibernate.set
     *      table="tests_projects"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_test"
     *      class="gov.fnal.elab.db.Test"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of tests used in this project.
     */
    public Set getTests() { return tests; }
    public void setTests(Set tests) { this.tests = tests; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.ProjectProperty"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of project properties referencing this project.
     */
    public Set getProjectProperties() { return projectProperties; }
    public void setProjectProperties(Set projectProperties) { this.projectProperties = projectProperties; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.PropertyName"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of property names this project contains.
     */
    public Set getPropertyNames() { return propertyNames; }
    public void setPropertyNames(Set propertyNames) { this.propertyNames = propertyNames; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Comment"
     * @hibernate.collection-key
     *      column="fk_project"
     * @return The set of comments made while in this project.
     */
    public Set getComments() { return comments; }
    public void setComments(Set comments) { this.comments = comments; }



    /**
     * Removes the given group from this project
     */
    public void removeGroup(Group l){
        if(groups != null)
            groups.remove(l);
    }

    /**
     * Add a group for this project.
     */
    public void addGroup(Group l){
        if(groups == null){
            groups = new HashSet();
        }
        groups.add(l);
    }

    /**
     * Removes the given test from this project
     */
    public void removeTest(Milestone m){
        if(tests != null)
            tests.remove(m);
    }

    /**
     * Add a test for this project.
     */
    
    public void addTest(Milestone m){
        if(tests == null){
            tests = new HashSet();
        }
        tests.add(m);
    }
    
    /**
     * Removes the given milestone set from this project
     */
    public void removeMilestone(MilestoneSet m){
        if(milestoneSets != null)
            milestoneSets.remove(m);
    }

    /**
     * Add a milestone set for this project.
     */
    
    public void addMilestone(MilestoneSet m){
        if(milestoneSets == null){
            milestoneSets = new HashSet();
        }
        milestoneSets.add(m);
    }
    
    /**
     * Removes the given contact from this project
     */
    public void removeContact(Manager m){
        if(contacts != null)
            contacts.remove(m);
    }

    /**
     * Add a contact for this project.
     */
    public void addContact(Manager m){
        if(contacts == null){
            contacts = new HashSet();
        }
        contacts.add(m);
    }

} 
