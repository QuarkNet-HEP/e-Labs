/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import gov.fnal.elab.util.ElabException;

/**
 * Holds a bunch of {@link Permissions} objects. This is an optimization using
 * the assumption that most of the users of our system will have the same
 * permissions. The name is optional.
 * 
 * @hibernate.class 
 * 
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class PermissionSet extends DBObject{

    private int id;
    private String name;
    private Set logins;
    private Set permissions;
    private Manager creator;


    /**
     * Empty Constructor
     */
    public PermissionSet(){ }

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
        if(creator != null){
            Set s = new HashSet(1);
            s.add(creator);
            return s;
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
            s += name;
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this PermissioSet.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="name"
     *      not-null="true"
     * @return The optional name of this PermissionSet.
     */
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Login"
     * @hibernate.collection-key
     *      column="fk_permissionset"
     * @return The set of logins which have this certain PermissionSet
     */
    public Set getLogins() { return logins; }
    public void setLogins(Set logins) { this.logins = logins; }

    /**
     * @hibernate.many-to-one
     *      column="fk_manager"
     * @return The creator of this PermissionSet
     */
    public Manager getCreator() { return creator; }
    public void setCreator(Manager creator) { this.creator = creator; } 

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Permissions"
     * @hibernate.collection-key
     *      column="fk_permission_set"
     * @return The set of permissions objects contained in this set.
     */
    public Set getPermissions() { return permissions; }
    public void setPermissions(Set permissions) { this.permissions = permissions; }


    /*
     * Special section for permission setup
     */

    /**
     * Set {@link Permissions} objects for every Elab DBObject.
     * @see Permissions
     * @see PermissionSet
     */
    public void setPermissionsOnAllObjects(boolean userRead, boolean userEdit, boolean childRead, boolean childEdit, boolean globalRead, boolean globalEdit, boolean globalCreate){
        setupElabDBObject();

        Set permissionsSet = new HashSet();     //set of permissions, one for each elabDBObject
        for(Iterator i=elabDBObject.iterator(); i.hasNext(); ){
            String s = (String)i.next();
            Permissions p = new Permissions(userRead, userEdit, childRead, childEdit, globalRead, globalEdit, globalCreate);
            p.setObjectName(s);
            permissionsSet.add(p);
        }

        this.setPermissions(permissionsSet);
    }

}
