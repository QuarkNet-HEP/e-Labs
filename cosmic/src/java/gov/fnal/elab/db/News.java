/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Date;

/**
 * Post news about happenings on the site and elsewhere.
 * 
 * @hibernate.subclass
 *      discriminator-value="News"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class News extends Comment {

    private Date expirationDate;

    /**
     * Default Constructor
     */
    public News() { }

    /**
     * @hibernate.property
     *      column="expiration_date"
     * @return The date/time when this news item expires.
     */
    public Date getExpirationDate() { return expirationDate; }
    public void setExpirationDate(Date expirationDate) { this.expirationDate = expirationDate; }

}
