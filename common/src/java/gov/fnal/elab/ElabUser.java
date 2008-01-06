/*
 * Created on Jun 7, 2007
 */
package gov.fnal.elab;

import javax.servlet.http.HttpSession;

import gov.fnal.elab.usermanagement.ElabUserManagementProvider;

public class ElabUser extends ElabGroup {
    public ElabUser(Elab elab, ElabUserManagementProvider provider) {
        super(elab, provider);
    }
    
    public static ElabGroup getUser(HttpSession session) {
        return ElabGroup.getUser(session);
    }
    
    public static void setUser(HttpSession session, ElabGroup user) {
        ElabGroup.setUser(session, user);
    }
    
    public static boolean isUserLoggedIn(HttpSession session) {
        return ElabGroup.isUserLoggedIn(session);
    }
}
