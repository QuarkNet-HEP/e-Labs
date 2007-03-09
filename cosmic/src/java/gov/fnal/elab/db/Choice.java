/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * A choice for a question on a test.
 *
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Choice extends DBObject {

    private int id;
    private String text;
    private MultipleChoice multiplechoice;
    private MultipleChoice correct;
    private Set responses;

    /**
     * Empty constructor for Hibernate.
     */
    public Choice() {}

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Same as the MultipleChoice this Choice is a part of *
     */
    public Set grabOwners(){
        if(multiplechoice != null){
            return multiplechoice.grabOwners();
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
     * @return The id of this choice.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="text"
     * @return The text of the choice.
     */
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    
    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_multiplechoice"
     * @return The multiple choice question that this choice part of.
     */
    public MultipleChoice getMultipleChoice() { return multiplechoice; }
    public void setMultipleChoice(MultipleChoice multiplechoice) { this.multiplechoice = multiplechoice; }

    /**
     * This is really a one-to-one relationship, made possible by the unique identifier.
     * 
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      unique="true"
     * @return The correct response to the MultipleChoice question.
     */
    public MultipleChoice getCorrect() { return correct; }
    public void setCorrect(MultipleChoice correct) { this.correct = correct; } 

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.MultipleChoiceResponse"
     * @hibernate.collection-key
     *      column="fk_choice"
     * @return The set of user responses that chose this choice in a multiple choice question on a test.
     */
    public Set getMultipleChoiceResponses() { return responses; }
    public void setMultipleChoiceResponses(Set responses) { this.responses = responses; }

}
