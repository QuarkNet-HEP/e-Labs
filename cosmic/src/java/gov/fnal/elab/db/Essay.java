/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * An essay a user wrote in response to a question.
 *
 * @hibernate.subclass
 *      discriminator-value="Essay"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 * @see         Response
 */
public class Essay extends Response {
    private String text;

    public boolean isValid(){
        return true;
    }

    public String grabIdentifier(){
        String s = "";
        if(text != null){
            s += text;
        }
        return s;
    }

    /**
     * @hibernate.property
     *      column="text"
     *      type="text"
     * @return The text of this essay.
     */
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
}
