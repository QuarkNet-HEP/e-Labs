/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.Date;
import java.util.Set;

/**
 * Log when a login makes use of the site.
 *
 * @hibernate.class
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Use extends DBObject {

    private int id;
    private Date date;
    private Login login;

    /**
     * Empty constructor for Hibernate.
     */
    public Use() {
        date = new Date();
    }

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Since we use Use for tracking, only site admins own these objects *
     */
    public Set grabOwners(){
        return null;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(date != null){
            s += date + " ";
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this use.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="date_entered"
     * @return The date timestamp at which this use was made.
     */
    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_login"
     * @return The login that made this use.
     */
    public Login getLogin() { return login; }
    public void setLogin(Login login) { this.login = login; }
}
