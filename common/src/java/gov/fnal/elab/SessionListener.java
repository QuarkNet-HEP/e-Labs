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