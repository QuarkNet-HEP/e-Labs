/*
 * Created on Apr 27, 2007
 */
package gov.fnal.elab;

import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class ElabTeacher extends ElabUser {
    private String email;
    private List groups;

    public ElabTeacher(Elab elab, ElabUserManagementProvider provider) {
        super(elab, provider);
        groups = new ArrayList();
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Collection getGroups() {
        return groups;
    }
    
    public void addGroup(ElabGroup group) {
        if (groups.isEmpty()) {
            super.setGroup(group);
        }
        groups.add(group);
    }
}
