/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import java.io.Serializable;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.type.Type;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.db.HibernateUtil;

/**
 * Authenticate with a username and password. This is the main object in the
 * database which holds all major user information and user-object 
 * relationships.
 * <br/><br/>
 * NOTE TO ELAB DEVELOPERS: keep this class in sync with
 * {@link gov.fnal.elab.util.SessionLogin}.
 *
 * @hibernate.class
 *      table="login"
 *      discriminator-value="Login"
 * @hibernate.discriminator
 *      column="discriminator"
 *      type="string"
 *
 * @author      Paul Neppy, Hao Zhou
 * @version     %I%, %G%
 */
public class Login extends DBObject {

    private int id;
    private String username;
    private String password;
    private String firstName;
    private String lastName;
    private String email;
    private boolean isFirstTimeLoggingIn = false;
    private boolean isTestAccount = false;
    private boolean isTestRequired = false;
    private PermissionSet permissionSet;
    private Set responseSheets;
    private Set comments;
    private Set groups;
    private Institution institution;
    private Set uses;
    private Set jobs;
    private Set propertyValues;

    /**
     */
    public Login() {
    }

    /**
     * Is this bean valid?
     */
    public boolean isValid(){
        return true;
    }

    /**
     * Grab a unique string which can be used as a short identifier
     */
    public String grabIdentifier(){
        String s = "";
        if(username != null){
            s += username + " ";
        }
        return s;
    }

    /**
     * @hibernate.id 
     *      column="id" 
     *      generator-class="hilo" 
     *      unsaved-value="null"
     * @return The id of this login.
     */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; } 

    /**
     * @hibernate.property column="username" unique="true" not-null="true" 
     * @return The username.
     */
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    /**
     * @hibernate.property column="password" not-null="true" 
     * @return The login's password.
     */
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    /**
     * @hibernate.property column="first_name"
     * @return The user's first name.
     */
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    /**
     * @hibernate.property column="last_name"
     * @return The user's last name.
     */
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    /**
     * @hibernate.property column="email" 
     * @return The user's email address.
     */
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email= email; }

    /**
     * @hibernate.property column="is_first_time_logging_in"
     * @return Whether or not the user has been here before.
     */
    public boolean getIsFirstTimeLoggingIn() { return isFirstTimeLoggingIn; }
    public void setIsFirstTimeLoggingIn(boolean isFirstTimeLoggingIn) { this.isFirstTimeLoggingIn = isFirstTimeLoggingIn; }

    /**
     * @hibernate.property column="is_test_account"
     * @return Whether this account is used for internal purposes.
     */
    public boolean getIsTestAccount() { return isTestAccount; }
    public void setIsTestAccount(boolean isTestAccount) { this.isTestAccount = isTestAccount; }

    /**
     * @hibernate.property column="is_test_required"
     * @return Whether this account is required to take the required tests for the project they're in (through the groups they're part of).
     */
    public boolean getIsTestRequired() { return isTestRequired; }
    public void setIsTestRequired(boolean isTestRequired) { this.isTestRequired = isTestRequired; }


    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_permission_set"
     * @return The permission set of this login.
     */
    public PermissionSet getPermissionSet() { return permissionSet; }
    public void setPermissionSet(PermissionSet permissionSet) { this.permissionSet = permissionSet; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.ResponseSheet"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The set of answer sheets this login has completed
     */
    public Set getResponseSheets() { return responseSheets; }
    public void setResponseSheets(Set responseSheets) { this.responseSheets = responseSheets; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Comment"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The set of comments this login has made
     */
    public Set getComments() { return comments; }
    public void setComments(Set comments) { this.comments = comments; }

    /**
     * @hibernate.set
     *      table="logins_groups"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_group"
     *      class="gov.fnal.elab.db.Group"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The groups that this login belongs to.
     */
    public Set getGroups() { return groups; }
    public void setGroups(Set groups) { this.groups = groups; }

    /**
     * @hibernate.many-to-one
     *      cascade="save-update"
     *      column="fk_institution"
     * @return The institution this login is part of.
     */
    public Institution getInstitution() { return institution; }
    public void setInstitution(Institution institution) { this.institution = institution; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Use"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The uses that this login has made.
     */
    public Set getUses() { return uses; }
    public void setUses(Set uses) { this.uses = uses; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.Job"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The jobs this login owns.
     */
    public Set getJobs() { return jobs; }
    public void setJobs(Set jobs) { this.jobs = jobs; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.PropertyValue"
     * @hibernate.collection-key
     *      column="fk_login"
     * @return The property values this login has. These are the values for
     * specific property names which are part of a project the login is in.
     */
    public Set getPropertyValues() { return propertyValues; }

    /*
     * A user-friendly method, this returns the value of a given property name
     */
    public String getProperty(String propertyName) 
    {
        // for each property value, check if the name matches
        for (Iterator i = propertyValues.iterator(); i.hasNext(); )
        {
            PropertyValue propertyValue = (PropertyValue)i.next();
            if ( propertyValue.getPropertyName().getName().equals(propertyName) )
                return propertyValue.getValue();
        }
        return null;
    };
        
    public void setPropertyValues(Set propertyValues) { this.propertyValues = propertyValues; }

    /**
     * Delete all relations to this login before calling superclass delete().
     */
    public void delete() throws ElabException{
        if (permissionSet != null && permissionSet.getLogins().size() == 1)
        {
            // this is the only login using this permission set.  Therefore, we will delete it.

            // delete all the permissions in this permission set
            for (Iterator i = permissionSet.getPermissions().iterator(); i.hasNext(); )
            {
               ((Permissions)i.next()).delete();
            }
            // now we can delete the permission set
        }
        // delete all the response sheets of the login
        if (responseSheets != null)
            for (Iterator i = responseSheets.iterator(); i.hasNext(); )
            {
                ResponseSheet RS = (ResponseSheet)i.next();
                
                // delete all the responses of the response sheet
                for (Iterator j = RS.getResponses().iterator(); j.hasNext(); )
                {
                    ((Response)j.next()).delete();
                }
                // now we can delete the response sheet
                RS.delete();
            }
        // now we can delete responseSheets
        
        //sets all the comments to null owner
        for (Iterator i = comments.iterator(); i.hasNext(); )
            ((Comment)i.next()).setMaker(null);
        // delete all uses
        for (Iterator i = uses.iterator(); i.hasNext(); )
            ((Use)i.next()).delete();
        // delete all jobs
        for (Iterator i = jobs.iterator(); i.hasNext(); )
            ((Job)i.next()).delete();
        // delete all property values
        for (Iterator i = propertyValues.iterator(); i.hasNext(); )
            ((PropertyValue)i.next()).delete();

        // calls super's delete function
        super.delete();
    }
     
    /***
     * Special section for XML, ownership, and permissions checking
     **/

    /**
     * Override the super class to format certain attributes a certain way.
     */
    public String toXMLAttributes() throws ElabException {
        String s = "";
        HashSet hash = new HashSet();

        //add in special formatted attributes
        s += "\t\t\t<attr name=\"Full Name\" display=\"Full Name\">\n";
        s += "\t\t\t\t<type>String</type>\n";
        s += "\t\t\t\t<value>" + firstName + " " + lastName + "</value>\n";
        s += "\t\t\t</attr>\n";
        s += "\t\t\t<attr name=\"username\" display=\"Username\">\n";
        s += "\t\t\t\t<type>String</type>\n";
        s += "\t\t\t\t<value>" + username + "</value>\n";
        s += "\t\t\t</attr>\n";
        hash.add("firstName");
        hash.add("lastName");

        s += super.toXMLAttributes(hash);

        return s;
    }
    /**
     * Override the super class to declare the type of the Sets of empty relations.
     
    public String toXMLRelationships() throws ElabException {
        String s = "";
        HashSet hash = new HashSet();
        
        s += "\t\t\t<relationship class=\"" + type + "\" type=\"" + relType + "\" display=\"" + display + "\">\n";

        //get relationship ids
        Object obj = null;
        try{
            obj = m.invoke(this, null);
        } catch(Exception e){
            throw new ElabException("While invoking:" + e);
        }
        if(obj != null){
            if(obj instanceof Set){
                for(Iterator j=((Set)obj).iterator(); j.hasNext(); ){
                    DBObject dbobj = (DBObject)j.next();
                    int id = dbobj.getId();
                    String className = dbobj.getClass().getName();
                    className = className.substring(className.lastIndexOf(".")+1);

                    s += "\t\t\t\t<rel id=\""+ id + "\" class=\"" + className + "\"><![CDATA[" + dbobj.grabIdentifier() + "]]></rel>\n";
                }
            }
            else if(isElabDBObject(type)){
                DBObject dbobj = (DBObject)obj;
                String className = dbobj.getClass().getName();
                className = className.substring(className.lastIndexOf(".")+1);
                s += "\t\t\t\t<rel id=\""+ dbobj.getId() + "\" class=\"" + className + "\"><![CDATA[" + dbobj.grabIdentifier() + "]]></rel>\n";
            }
            else{
                s += "\t\t\t\t<rel id=\"0\" class=\"unknown object\" />\n";
            }
        }
        else{
            //s += "\t\t\t\t<empty></empty>\n";
        }

        s += "\t\t\t</relationship>\n";
        
        s += super.toXMLAttributes(hash);

        return s;
    }*/
    /**
     * Traverse up the tree and get all the {@link Manager}s for this login.
     * (The login itself is also an owner)
     */
    public Set grabOwners(){
        Set owners = new HashSet();
        owners.add(this);
        if(groups != null){
            for(Iterator i=groups.iterator(); i.hasNext(); ){
                Login login = (Login)i.next();
                owners.addAll(login.grabOwners());
            }
        }
        return owners;
    }

    /**
     * Normal Logins don't manage other Logins, only Managers so. Therefore
     * the Manager class will replace this method with the correct one
     * returning the list of managed Logins.
     */
    public Set getManagedLogins() { return null; }


    /**
     * Given an Elab DBObject, checks to see if this login has permission to
     * create a new instance of the object.
     * @param   objectName  the Elab DBObject to create
     */
    public boolean hasPermission(String objectName) throws ElabException{
        if(objectName == null){
            throw new ElabException("Object name not defined!");
        }

        if(isElabDBObject(objectName) == false){
            throw new ElabException("Object name " + objectName + " is not an object in the database (not an ElabDBObject)");
        }

        PermissionSet permissionSet = this.getPermissionSet();
        if(permissionSet != null){
            Set permissions = permissionSet.getPermissions();

            for(Iterator i=permissions.iterator(); i.hasNext(); ){
                Permissions p = (Permissions)i.next();
                if((p.getObjectName()).equals(objectName)){
                    /*
                     * found correct permissions object
                     * determine if the user has global create permission
                     */

                    if(p.getPermission(Permissions.GLOBAL, Permissions.CREATE)){
                        return true;
                    }
                    else{
                        return false;
                    }
                }
            }

            /*
             * This Login doesn't have a Permissions object for this objectName.
             * Default deny all access.
             */
            return false;
        }
        else{
            /*
             * If the Login doesn't have a PermissionSet, default deny access
             */
            return false;
        }
    }
        

    /**
     * Given an Elab DBObject and an action to perform, returns true if this
     * login has permission to take the specified action on the object.
     * @param   object  the object instance to perform the action on
     * @param   action  the action to take on the object (choose from 
     *  Permissions.READ, Permissions.EDIT, Permissions.CREATE)
     * @see Permissions
     * @see PermissionSet
     */
    public boolean hasPermission(DBObject object, int action) throws ElabException{
        if(!(action == Permissions.READ || action == Permissions.EDIT || action == Permissions.CREATE)){
            throw new ElabException("Action to take must be either Permissions.READ, Permissions.EDIT or Permissions.CREATE");
        }

        PermissionSet permissionSet = this.getPermissionSet();
        if(permissionSet != null){
            Set permissions = permissionSet.getPermissions();

            for(Iterator i=permissions.iterator(); i.hasNext(); ){
                Permissions p = (Permissions)i.next();
                String objectName = object.getClass().getName();
                objectName = objectName.substring(objectName.lastIndexOf(".")+1);  //getName() returns: gov.fnal.elab.db.DBObject
                if((p.getObjectName()).equals(objectName)){
                    /*
                     * found correct permissions object
                     * determine if the user has permission for the action
                     */

                    /*
                     * GLOBAL scope checking
                     */
                    if(p.getPermission(Permissions.GLOBAL, action)){
                        return true;
                    }

                    /*
                     * CHILD scope checking
                     * @see Manager#getManagedLogins
                     */
                    if(this instanceof Manager){
                        if(p.getPermission(Permissions.CHILD, action)){
                            Set managedLogins = this.getManagedLogins();
                            if(managedLogins != null){
                                for(Iterator j=managedLogins.iterator(); i.hasNext(); ){
                                    Login l = (Login)i.next();
                                    if(l.hasPermission(object, action)){
                                        return true;
                                    }
                                }
                            }
                        }
                    }

                    /*
                     * USER scope checking
                     */
                    if(p.getPermission(Permissions.USER, action)){
                        /*
                         * Permission is given only if the user is an owner of the
                         * object
                         */
                        if(object.grabOwners().contains(this)){
                            return true;
                        }
                        else{
                            return false;
                        }
                    }

                    /*
                     * No authorization on any scope for the object
                     */
                    return false;
                }
            }

            /*
             * This Login doesn't have a Permissions object for this object.
             * Default deny all access.
             */
            return false;
        }
        else{
            /*
             * If the Login doesn't have a PermissionSet, default deny access.
             */
            return false;
        }
    }

    /**
     * Find and return a login by their username.
     * @param   u   the username
     */
    public static Login findByUsername(String u) throws ElabException{
        java.util.List logins;
        try{
            org.hibernate.classic.Session session = HibernateUtil.getSession();
            HibernateUtil.beginTransaction();
            logins = session.find(
                    "from Login as login where login.username = ?",
                    u,
                    Hibernate.STRING
                    );
        } catch(Exception e){
            throw new ElabException(e.getMessage());
        }

        if(logins.size() == 1){
            return (Login)logins.get(0);
        }
        else{
            return null;
        }
    }

    /**
     * Find and return a login by their username and password
     * @param   u   the username
     * @param   p   the password
     */
    public static Login findByUsernameAndPassword(String u, String p) throws ElabException{
        java.util.List logins;
        try{
            org.hibernate.classic.Session session = HibernateUtil.getSession();
            HibernateUtil.beginTransaction();
            logins = session.find(
                    "from Login as login where login.username = ? and login.password = ?",
                    new Object[] {u, p},
                    new Type[] {Hibernate.STRING, Hibernate.STRING}
                    );
        } catch(Exception e){
            throw new ElabException(e.getMessage());
        }

        if(logins.size() == 1){
            return (Login)logins.get(0);
        }
        else{
            return null;
        }
    }



    /**
     * Verify that the caller posseses the old password, and that the twice-entered new
     * passwords match.
     *
     * @param oldPassword   Hopefully the existing password for this login.
     * @param newPassword   The password to set.
     * @param newPassword2  The re-typed password to check against.
     * @return True if the password was changed succesfully. False, otherwise.
     */
    public boolean changePassword(
        String oldPassword, 
        String newPassword, 
        String newPassword2) {
        if(password != null){
            if (oldPassword.equals(password) && newPassword.equals(newPassword2)) {
                password = newPassword;
                return true;
            } else
                return false;
        }
        else{
            password = newPassword;
            return true;
        }
    }
    public void DoNothing() {
        return;
    }

}
