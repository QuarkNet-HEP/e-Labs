package gov.fnal.elab;

import java.util.*;
import java.text.*;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
 
public class SessionListener implements HttpSessionListener {
    private static int sessionCount;
    private static ArrayList sessions = new ArrayList();
    DateFormat df = new SimpleDateFormat("MMM dd yyyy HH:MM:SS");
	
    public static int getTotalActiveSession() {
    	return sessionCount;
    }
    public static ArrayList getTotalSessionUsers() {
    	return sessions;
    }

    public static int getUserLoginsCount(String username) {
    	int count = 0;
    	boolean validSession = true;
    	if (sessions.size() > 0) {
    		for (int i = 0; i < sessions.size(); i++) {
    			HttpSession s = (HttpSession) sessions.get(i);
    			Enumeration att_names = s.getAttributeNames();
    			while (att_names.hasMoreElements()) {
    				String attr = (String) att_names.nextElement();
    				if (attr.equals("elab")) {
    					validSession = true;
    				}
    			}
    			if (validSession) {
    				ElabGroup eu = (ElabGroup) s.getAttribute("elab.user");
    				if (eu != null) {
	    				if (eu.getName().equals(username)) {
	    					count++;
	    				}
    				}
    			}
    			
    		}
    	}
    	return count;
    }//end of getUserLoginsCount
    
    @Override
    public void sessionCreated(HttpSessionEvent event) {
        synchronized (this) {
        	sessionCount++;
        	HttpSession s = event.getSession();
        	sessions.add(s);
        }
    }
    @Override
    public void sessionDestroyed(HttpSessionEvent event) {
        synchronized (this) {
        	if (sessionCount > 0) {
	        	sessionCount--;
	        	HttpSession s = event.getSession();
	        	sessions.remove(s);
        	}
        }
    }		
}