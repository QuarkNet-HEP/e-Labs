/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;

/**
 * Contains a name of a property which a Login has when they're associated
 * with a specific Project. {@link PropertyValue} contains the value of this
 * property name.
 * 
 * @hibernate.class
 *      table="propertyname"
 *      discriminator-value="PropertyName"
 * @hibernate.discriminator
 *      column="discriminator"
 *      type="string"
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class PropertyName extends DBObject {

    private int id;
    private String name;
    private Project project;
    private Set values;

    /**
     * Empty constructor for Hibernate.
     */
    public PropertyName() {}
     
    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Owners same as the owners of the Project this property name is part of *
     */
    public Set grabOwners(){
        if(project != null){
            return project.grabOwners();
        }
        else{
            return null;
        }
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(name != null){
            s += name + " ";
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this property name.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="name"
     * @return The name of this property.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_project"
     * @return The project this property belongs to.
     */
    public Project getProject() { return project; }
    public void setProject(Project project) { this.project = project; }
    
    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.PropertyValue"
     * @hibernate.collection-key
     *      column="fk_propertyname"
     * @return The set of property values this name has.
     */
    public Set getValues() { return values; }
    public void setValues(Set values) { this.values = values; }

}
