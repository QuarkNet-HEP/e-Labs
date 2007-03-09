/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Set;

/**
 * The response to a question on a test.
 *
 * @hibernate.class
 *      discriminator-value="Response"
 * @hibernate.discriminator
 *      column="discriminator"
 *      type="string"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public abstract class Response extends DBObject {

    private int id;
    private Question question;
    private ResponseSheet responsesheet;

    /**
     * Grab the owners for permissions checking
     */
    public Set grabOwners(){
        return responsesheet.grabOwners();
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this response.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_question"
     * @return The question for a user's response. (Think Jeopardy!)
     */
    public Question getQuestion() { return question; }
    public void setQuestion(Question question) { this.question = question; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_responsesheet"
     * @return The response sheet this response was written on.
     */
    public ResponseSheet getResponseSheet() { return responsesheet; }
    public void setResponseSheet(ResponseSheet responsesheet) { this.responsesheet = responsesheet; }
}
