package gov.fnal.elab;

import java.util.*;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
 
public class SessionListener implements HttpSessionListener {
    private static int sessionCount;
    private static TreeMap<String, HttpSession> sessions = new TreeMap<String, HttpSession>();

    public static int getTotalActiveSession() {
    	return sessionCount;
    }
    public static TreeMap<String, HttpSession> getTotalSessionUsers() {
    	return sessions;
    }
    @Override
    public void sessionCreated(HttpSessionEvent event) {
        synchronized (this) {
        	sessionCount++;
        	HttpSession s = event.getSession();
        	sessions.put(s.getId(), s);
        }
    }
    @Override
    public void sessionDestroyed(HttpSessionEvent event) {
        synchronized (this) {
        	sessionCount--;
        	HttpSession s = event.getSession();
        	sessions.remove(s.getId());
        }
    }

}