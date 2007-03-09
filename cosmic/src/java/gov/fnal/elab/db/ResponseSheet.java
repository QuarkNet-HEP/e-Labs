/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * A login can complete one or more response sheets for a test.
 *
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class ResponseSheet extends DBObject {
    private int id;
    private Test test;
    private Login login;
    private Set responses;

    /**
     * Empty constructor for Hibernate.
     */
    public ResponseSheet() {}

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     */
    public Set grabOwners(){
        Set owners = new HashSet();
        owners.add(login);
        return owners;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        return "for login: " + login.getUsername();
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this response sheet.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 
    
    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_test"
     * @return The test this response sheet was made for.
     */
    public Test getTest() { return test; }
    public void setTest(Test test) { this.test = test; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_login"
     * @return The login who wrote this response sheet.
     */
    public Login getLogin() { return login; }
    public void setLogin(Login login) { this.login = login; }

    /**
     * @hibernate.set
     *      lazy="true"
     *      inverse='"true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Response"
     * @hibernate.collection-key
     *      column="fk_responsesheet"
     * @return The set of responses written on this sheet.
     */
    public Set getResponses() { return responses; }
    public void setResponses(Set responses) { this.responses = responses; }
}
