/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import gov.fnal.elab.util.ElabException;

/**
 * The Permissions class holds permissions a login has on an object (by
 * posessing a {@link PermissionSet}.
 * 
 * @hibernate.class 
 * 
 * @author      Paul Nepywoda, FNAL
 * @version     %I%, %G%
 */
public class Permissions extends DBObject{

    private int id;
    private String objectName;
    private boolean userRead = false;
    private boolean userEdit = false;
    private boolean childRead = false;
    private boolean childEdit = false;
    private boolean globalRead = false;
    private boolean globalEdit = false;
    private boolean globalCreate = false;
    private PermissionSet permissionSet;

    /**
     * Special section for easy permission checking
     */
    public static final int READ = 0;
    public static final int EDIT = 1;
    public static final int CREATE = 2;
    public static final int USER = 3;
    public static final int CHILD = 4;
    public static final int GLOBAL = 5;


    /**
     * Empty Constructor
     */
    public Permissions(){ }

    /**
     * Constructor taking a boolean for each of the 9 access bits
     * @param   ur  user scope, read permission
     * @param   ue  user scope, edit permission
     * @param   cr  child scope, read permission
     * @param   ce  child scope, edit permission
     * @param   gr  global scope, read permission
     * @param   ge  global scope, edit permission
     * @param   gc  global scope, create permission
     */
    public Permissions(boolean ur, boolean ue, boolean cr, boolean ce, boolean gr, boolean ge, boolean gc){
        setUserRead(ur);
        setUserEdit(ue);
        setChildRead(cr);
        setChildEdit(ce);
        setGlobalRead(gr);
        setGlobalEdit(ge);
        setGlobalCreate(gc);
    }

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab the owners for permissions checking
     * * Owner is the owner of the set this Permissions object is in *
     */
    public Set grabOwners(){
        if(permissionSet != null){
            return permissionSet.grabOwners();
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
        if(objectName != null){
            s += objectName;
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this Permission.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property
     *      column="object_name"
     *      not-null="true"
     * @return The name of the object these permissions refer to.
     */
    public String getObjectName() { return objectName; }
    public void setObjectName(String objectName) { this.objectName = objectName; }

    /**
     * @hibernate.property
     *      column="user_read"
     *      not-null="true"
     * @return True if this user can read the objectName.
     */
    public boolean getUserRead() { return userRead; }
    public void setUserRead(boolean userRead) { this.userRead = userRead; }

    /**
     * @hibernate.property
     *      column="user_edit"
     *      not-null="true"
     * @return True if this user can edit the objectName.
     */
    public boolean getUserEdit() { return userEdit; }
    public void setUserEdit(boolean userEdit) { this.userEdit = userEdit; }

    /**
     * @hibernate.property
     *      column="child_read"
     *      not-null="true"
     * @return True if this user can read the objectName.
     */
    public boolean getChildRead() { return childRead; }
    public void setChildRead(boolean childRead) { this.childRead = childRead; }

    /**
     * @hibernate.property
     *      column="child_edit"
     *      not-null="true"
     * @return True if this user can edit the objectName.
     */
    public boolean getChildEdit() { return childEdit; }
    public void setChildEdit(boolean childEdit) { this.childEdit = childEdit; }

    /**
     * @hibernate.property
     *      column="global_read"
     *      not-null="true"
     * @return True if this user can read the objectName.
     */
    public boolean getGlobalRead() { return globalRead; }
    public void setGlobalRead(boolean globalRead) { this.globalRead = globalRead; }

    /**
     * @hibernate.property
     *      column="global_edit"
     *      not-null="true"
     * @return True if this user can edit the objectName.
     */
    public boolean getGlobalEdit() { return globalEdit; }
    public void setGlobalEdit(boolean globalEdit) { this.globalEdit = globalEdit; }

    /**
     * @hibernate.property
     *      column="global_create"
     *      not-null="true"
     * @return True if this user can create the objectName.
     */
    public boolean getGlobalCreate() { return globalCreate; }
    public void setGlobalCreate(boolean globalCreate) { this.globalCreate = globalCreate; }

    /**
     * @hibernate.many-to-one
     *      column="fk_permission_set"
     * @return The permission set which this permissions object belongs to.
     */
    public PermissionSet getPermissionSet() { return permissionSet; }
    public void setPermissionSet(PermissionSet permissionSet) { this.permissionSet = permissionSet; }
    

    /**
     * Get a specific scope and action permission
     * @param   scope   the scope
     * @param   action  the action
     */
    public boolean getPermission(int scope, int action) throws ElabException{
        if(scope < USER || scope > GLOBAL){
            throw new ElabException("Scope must be USER, CHILD or GLOBAL");
        }
        if(action < READ || action > CREATE){
            throw new ElabException("Action must be READ, EDIT or CREATE");
        }

        if(scope == USER){
            if(action == READ){
                return getUserRead();
            }
            else if(action == EDIT){
                return getUserEdit();
            }
        }
        else if(scope == CHILD){
            if(action == READ){
                return getChildRead();
            }
            else if(action == EDIT){
                return getChildEdit();
            }
        }
        else if(scope == GLOBAL){
            if(action == READ){
                return getGlobalRead();
            }
            else if(action == EDIT){
                return getGlobalEdit();
            }
            else if(action == CREATE){
                return getGlobalCreate();
            }
        }

        //should never reach this
        return false;
    }

}
