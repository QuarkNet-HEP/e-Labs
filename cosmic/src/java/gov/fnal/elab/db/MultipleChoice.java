/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Set;

/**
 * A multiple choice question contains choices and a correct choice (the "answer").
 *
 * @hibernate.subclass
 *      discriminator-value="MultipleChoice"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class MultipleChoice extends Question {

    private Choice correct;
    private Set choices;

    /**
     * This is really a one-to-one relationship, made possible by the unique identifier.
     * 
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      unique="true"
     * @return The correct choice to this question.
     */
    public Choice getCorrect() { return correct; }
    public void setCorrect(Choice correct) { this.correct = correct; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse='"true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Choice"
     * @hibernate.collection-key
     *      column="fk_multiplechoice"
     * @return The multiple choices for this question.
     */
    public Set getChoices() { return choices; }
    public void setChoices(Set choices) { this.choices = choices; }
}
