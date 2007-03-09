/**
 * License inserted a later time.
 */

package gov.fnal.elab.db;

import java.util.*;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.type.Type;
import gov.fnal.elab.util.ElabException;
import gov.fnal.elab.db.HibernateUtil;

/**
 * Manager represents a particular type of login that can monitor a set of 
 * logins and groups.  In addition, they possess particular information not 
 * kept for regular users, like a phone number.
 * 
 * @hibernate.subclass
 *      discriminator-value="Manager"
 *
 * @author      Eric Gilbert, FNAL
 * @author      Paul Nepywoda, FNAL
 * @author      Hao Zhou, FNAL
 * @version     %I%, %G%
 */
public class Manager extends Login {

    private String phoneNumber;
    private String phoneNumber2;
    private String faxNumber;
    private Set managedGroups;
    private Set projectContacts;
    private Set managedPermissionSets;
    
    /**
     * Default Constructor
     */
    public Manager() {
        super();
    }
    
    /**
     * @hibernate.property
     *      column="phone_number"
     * @return The primary phone number.
     */
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    /**
     * @hibernate.property
     *      column="phone_number2"
     * @return The secondary phone number.
     */
    public String getPhoneNumber2() { return phoneNumber2; }
    public void setPhoneNumber2(String phoneNumber2) { this.phoneNumber2 = phoneNumber2; }

    /**
     * @hibernate.property
     *      column="fax_number"
     * @return The fax number.
     */
    public String getFaxNumber() { return faxNumber; }
    public void setFaxNumber(String faxNumber) { this.faxNumber = faxNumber; }
    
    /**
     * @hibernate.set
     *      table="groups_managers"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_group"
     *      class="gov.fnal.elab.db.Group"
     * @hibernate.collection-key
     *      column="fk_manager"
     * @return The groups that this manager manages.
     */
    public Set getManagedGroups() { return managedGroups; }
    public void setManagedGroups(Set managedGroups) { this.managedGroups = managedGroups; }

    /**
     * @hibernate.set
     *      table="projects_contacts"
     *      cascade="save-update"
     *      lazy="true"
     * @hibernate.collection-many-to-many
     *      column="fk_project"
     *      class="gov.fnal.elab.db.Project"
     * @hibernate.collection-key
     *      column="fk_manager"
     * @return The set of projects that this manager is a contact for.
     */
    public Set getProjectContacts() { return projectContacts; }
    public void setProjectContacts(Set projectContacts) { this.projectContacts = projectContacts; }

    /**
     * @hibernate.set
     *      cascade="save-update"
     *      lazy="true"
     *      inverse="true"
     * @hibernate.collection-one-to-many
     *      class="gov.fnal.elab.db.PermissionSet"
     * @hibernate.collection-key
     *      column="fk_manager"
     * @return The set of PermissionSets this manager has created.
     */
    public Set getManagedPermissionSets() { return managedPermissionSets; }
    public void setManagedPermissionSets(Set managedPermissionSets) { this.managedPermissionSets = managedPermissionSets; }


    /*
     * Special functions for managing other logins
     */
    public Set getManagedLogins(){
        Set logins = new HashSet();
        if(managedGroups != null){
            for(Iterator i=managedGroups.iterator(); i.hasNext(); ){
                Group g = (Group)i.next();
                logins.addAll(g.grabOwners());
            }
            return logins;
        }
        else{
            return null;
        }
    }

    /**
     * Delete all relations to this login before calling superclass delete().
     */
    public void delete() throws ElabException{
        // set any permission set it owns to null owner
        if (managedPermissionSets != null)
            for (Iterator i = managedPermissionSets.iterator(); i.hasNext();)
                ((PermissionSet)i.next()).setCreator(null);
        
        // set any groups it owns to null control
        if (managedGroups != null)
            for (Iterator i = managedGroups.iterator(); i.hasNext(); )
            {
                Set managers = ((Group)i.next()).getManagers();
                // remove this manager from this 
                if (managers != null)
                    for (Iterator j = managers.iterator(); j.hasNext(); )
                        if ( ((Manager)j.next()) == this)
                            j.remove();
            }
        
        // set any projects it owns to null control
        if (projectContacts != null)
            for (Iterator i = projectContacts.iterator(); i.hasNext(); )
            {
                Set managers = ((Project)i.next()).getContacts();
                // remove this manager from this 
                if (managers != null)
                    for (Iterator j = managers.iterator(); j.hasNext(); )
                        if ( (Manager)j.next() == this)
                            j.remove();
            }
        super.delete();
    }
    
    /**
     * Removes a managed group from this manager
     */
    public void removeManagedGroup(Group m){
        if(managedGroups != null)
            managedGroups.remove(m);
    }

    /**
     * Add a managed group for this manager.
     */
    public void addManagedGroup(Group m){
        if(managedGroups == null){
            managedGroups = new HashSet();
        }
        managedGroups.add(m);
    }
}
