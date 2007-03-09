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
 *
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class ProjectProperty extends DBObject {

    private int id;
    private String name;
    private String value;
    private Project project;

    /**
     * Empty constructor for Hibernate.
     */
    public ProjectProperty() {}
     
    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Owners are same as the owners for the Project this is a property for *
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
     * @return The id of this property.
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
     * @hibernate.property
     *      column="value"
     * @return The value of this property.
     */
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_project"
     * @return The project this property belongs to.
     */
    public Project getProject() { return project; }
    public void setProject(Project project) { this.project = project; }
    
}
