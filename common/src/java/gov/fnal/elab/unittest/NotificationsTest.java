package gov.fnal.elab.unittest;

import org.junit.*;
import static org.junit.Assert.*;
import gov.fnal.elab.notifications.*;
import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabFactory;
import gov.fnal.elab.ElabGroup;
import gov.fnal.elab.ElabProperties;
import java.util.*;

public class NotificationsTest {
	public Elab cosmicElab = Elab.getElab(null, "cosmic");
	public Elab cmsElab = Elab.getElab(null, "cms");
	public Elab ligoElab = Elab.getElab(null, "ligo");
    public List<Integer> projectIds = new ArrayList<Integer>();
    public List<ElabGroup> groupsToNotify = new ArrayList(); 
    public List<ElabGroup> eg = new ArrayList<ElabGroup>();
    
	@Test
	public void test_Notification() {
		Notification n1 = new Notification(1, "Test", 23, 123456789, 123456799, 1, false, false);
		assertNotNull(n1);
	}

	@Test
	public void test_AddProjectNotification() {
		ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) cosmicElab);
        Notification n = getNotification(23,"For the Newsbox", false, System.currentTimeMillis() + 1000 * 3600, 1);
	    projectIds.add(cosmicElab.getId());
	    try {
	    	np.addProjectNotification(projectIds, n);
	    } catch (Exception e) {
	    	
	    }
	}
	
	@Test
	public void test_AddGroupNotification() {	    
		ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) cmsElab);
        Notification n = getNotification(23,"Message to TestTeacher", false, System.currentTimeMillis() + 1000 * 3600, 0);
	    projectIds.add(cmsElab.getId());
	    try {
	    	ElabGroup user = cosmicElab.authenticate("TestTeacher", "i2u2tt");
	        groupsToNotify.add(user);
	        np.addNotification(groupsToNotify, projectIds, n);
    	} catch (Exception e) {
    	
    	}
	}
	
	@Test
	public void test_AddTeacherNotification() {
	    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) ligoElab);
        Notification n = getNotification(23,"Hello teachers", false, System.currentTimeMillis() + 1000 * 3600, 2);
        try {
	    	ElabGroup teacher = cosmicElab.authenticate("TestTeacher", "i2u2tt");
	    	eg.add(teacher);
	        np.addTeacherNotification(eg, n);	
        } catch (Exception e) {
        	
        }
	}
	
	@Test
	public void test_GetGroupName() {
	    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) ligoElab);
	    String groupName = np.getGroupName(694);
	    assertTrue(groupName.equals("TestTeacher"));
	}

	public Notification getNotification(int groupId, String msg, boolean broadcast, long exp, int type) {
		Notification n = new Notification();
        n.setCreatorGroupId(groupId);
        n.setMessage(msg);
        n.setBroadcast(broadcast);
	    n.setExpirationDate(exp);  
        n.setType(Notification.MessageType.fromCode(type));
		return n;
	}
	
}//end of NotificationsTest