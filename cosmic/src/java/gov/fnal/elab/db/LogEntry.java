/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Date;
import java.util.Set;

/**
 * LogEntry is a Comment with a tag if it's an obsolete entry. It belongs to
 * a certain lobgook.
 * 
 * @hibernate.subclass
 *      discriminator-value="LogEntry"
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class LogEntry extends Comment {

    private boolean isObsolete = false;
    
    /**
     * Empty constructor for Hibernate.
     */
    public LogEntry() {}

    /**
     * @hibernate.property
     *      column="is_obsolete"
     * @return True if this entry is obsolete
     */
    public boolean getIsObsolete() { return isObsolete; }
    public void setIsObsolete(boolean isObsolete) { this.isObsolete = isObsolete; }

}
