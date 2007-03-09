/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * A Test contains questions with choices and answers. A user takes a test
 * one or more times with certain answers.
 *
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Test extends DBObject {
    private int id;
    private String name;
    private boolean isRequired = false;
    private Set projects;
    private Set questions;
    private Set responsesheets;

    /**
     * Empty constructor for Hibernate.
     */
    public Test() {}

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
        for(Iterator i=projects.iterator(); i.hasNext(); ){
            Project project = (Project)i.next();
            owners.addAll(project.grabOwners());
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
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this test.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 
    
    /**
     * @hibernate.property column="name" unique="true"
     * @return The test name.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.property column="is_required"
     * @return Is this test required for every user part of this project?
     */
    public boolean getIsRequired() { return isRequired; }
    public void setIsRequired(boolean isRequired) { this.isRequired = isRequired; }

    /**
     * @hibernate.set
     *      table="tests_projects"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_project"
     *      class="gov.fnal.elab.db.Project"
     * @hibernate.collection-key
     *      column="fk_test"
     * @return The set of projects this test is used in.
     */
    public Set getProjects() { return projects; }
    public void setProjects(Set projects) { this.projects = projects; }

    /**
     * @hibernate.set
     *      table="questions_tests"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_question"
     *      class="gov.fnal.elab.db.Question"
     * @hibernate.collection-key
     *      column="fk_test"
     * @return The set of questions on this test.
     */
    public Set getQuestions() { return questions; }
    public void setQuestions(Set questions) { this.questions = questions; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.ResponseSheet"
     * @hibernate.collection-key
     *      column="fk_test"
     * @return The set of response sheets which are part of this test
     */
    public Set getResponseSheets() { return responsesheets; }
    public void setResponseSheets(Set responsesheets) { this.responsesheets = responsesheets; }
}
