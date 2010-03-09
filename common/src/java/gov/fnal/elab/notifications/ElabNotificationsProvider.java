/*
 * Created on Feb 26, 2010
 */
package gov.fnal.elab.notifications;

import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProvider;
import gov.fnal.elab.util.ElabException;

import java.util.List;

public interface ElabNotificationsProvider extends ElabProvider {
    int getUnreadNotificationsCount(ElabGroup group) throws ElabException;
    
    List<Notification> getNotifications(ElabGroup group, int max) throws ElabException;
    
    List<Notification> getNotifications(ElabGroup group, int max, boolean includeOld) throws ElabException;
    
    List<Notification> getSystemNotifications(ElabGroup admin, int count) throws ElabException;
    
    void addNotification(ElabGroup group, Notification notification) throws ElabException;
    
    void markAsRead(Notification notification);
    
    void markAsRead(ElabGroup user, int id) throws ElabException;
    
    void markAsDeleted(ElabGroup user, int id) throws ElabException;
    
    void removeNotification(ElabGroup admin, int id) throws ElabException;
}
