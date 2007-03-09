/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * Feedback and questions on the portal from users.
 * 
 * @hibernate.subclass
 *      discriminator-value="Feedback"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Feedback extends Comment {

    private String type;
    private String name;

    /**
     * Default Constructor
     */
    public Feedback() { }

    /**
     * @hibernate.property
     *      column="type"
     *      type="text"
     * @return The type of feedback this is.
     */
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    /**
     * @hibernate.property
     *      column="name"
     *      type="text"
     * @return The name of this feedback item.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

}
