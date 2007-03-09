/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * A question which is part of a test.
 *
 * @hibernate.class
 *      discriminator-value="Question"
 * @hibernate.discriminator
 *      column="discriminator"
 *      type="string"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Question extends DBObject {

    private int id;
    private String text;
    private String sequenceNumber;
    private Set responses;
    private Set choices;
    private Set tests;

    /**
     * Empty constructor for Hibernate.
     */
    public Question() {}

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
        for(Iterator i=tests.iterator(); i.hasNext(); ){
            Test test = (Test)i.next();
            owners.addAll(test.grabOwners());
        }
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(text != null){
            s += text;
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this question.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="text"
     * @return The text of the question.
     */
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    
    /**
     * @hibernate.property
     *      column="sequence_number"
     * @return Used for ordering of questions on a test.
     */
    public String getSequenceNumber() { return sequenceNumber; }
    public void setSequenceNumber(String sequenceNumber) { this.sequenceNumber = sequenceNumber; }
    
    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse='"true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Response"
     * @hibernate.collection-key
     *      column="fk_question"
     * @return The responses given by users to this question.
     */
    public Set getResponses() { return responses; }
    public void setResponses(Set responses) { this.responses = responses; }

    /**
     * @hibernate.set
     *      table="questions_tests"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_tests"
     *      class="gov.fnal.elab.db.Test"
     * @hibernate.collection-key
     *      column="fk_question"
     * @return The set of tests which contain this question.
     */
    public Set getTests() { return tests; }
    public void setTests(Set tests) { this.tests = tests; }
}
