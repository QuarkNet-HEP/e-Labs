/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * FAQ is for any frequently asked questions and answers.
 * 
 * @hibernate.subclass
 *      discriminator-value="FAQ"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class FAQ extends Comment {

    private String question;

    /**
     * Default Constructor
     */
    public FAQ() { }

    /**
     * @hibernate.property
     *      column="question"
     *      type="text"
     * @return The question this FAQ answers.
     */
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

}
