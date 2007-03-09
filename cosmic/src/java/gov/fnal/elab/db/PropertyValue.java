/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import gov.fnal.elab.util.ElabException;

/**
 * Contains a value for a {@link PropertyName}. This pair is used for
 * project specific attributes that a Login has. 
 * 
 * @hibernate.class
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class PropertyValue extends DBObject {

    private int id;
    private String value;
    private Login login;
    private PropertyName name;

    /**
     * Empty constructor for Hibernate.
     */
    public PropertyValue() {}
     
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
        String s = "";
        if(value != null){
            s += value + " ";
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this property value.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="value"
     *      type="text"
     * @return The value of this property.
     */
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_login"
     * @return The login that has this property value.
     */
    public Login getLogin() { return login; }
    public void setLogin(Login login) { this.login = login; }
    
    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_propertyname"
     * @return The property name that this value pertains to.
     */
    public PropertyName getPropertyName() { return name; }
    public void setPropertyName(PropertyName name) { this.name = name; }

    /**
     * overloaded setPropertyName
     */
    
    public void setPropertyName(String sname) throws ElabException
    {
        try {
        this.name = (PropertyName)DBObject.findByName("PropertyName",sname);
        } catch (Exception e) {
            throw new ElabException(e.getMessage());
        }
    }
    
}
