/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * A single response made for a multiple choice question.
 *
 * @hibernate.subclass
 *      discriminator-value="MultipleChoiceResponse"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class MultipleChoiceResponse extends Response {
    private Choice choice;

    public boolean isValid(){
        return choice == null;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(choice != null){
            s += choice.getText();
        }
        return s;
    }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_choice"
     * @return The choice from a multiple choice questin which this response corresponds to.
     */
    public Choice getChoice() { return choice; }
    public void setChoice(Choice choice) { this.choice = choice; }
}
