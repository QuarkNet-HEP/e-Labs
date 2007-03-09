/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

/**
 * Reference item.
 * 
 * @hibernate.subclass
 *      discriminator-value="Reference"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Reference extends Comment {

    /**
     * Default Constructor
     */
    public Reference() { }
}
