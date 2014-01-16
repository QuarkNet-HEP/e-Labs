package gov.fnal.elab;

import gov.fnal.elab.Pair;
import java.util.*;
import java.text.*;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
 
public class SessionListener implements HttpSessionListener {
    private static int sessionCount;
    private static TreeMap<String, List<Pair>> sessions = new TreeMap<String, List<Pair>>();
	DateFormat df = new SimpleDateFormat("MMM dd yyyy HH:MM:SS");
	
    public static int getTotalActiveSession() {
    	return sessionCount;
    }
    public static TreeMap<String, List<Pair>> getTotalSessionUsers() {
    	return sessions;
    }
    @Override
    public void sessionCreated(HttpSessionEvent event) {
        synchronized (this) {
        	sessionCount++;
            List<Pair> sessionDetails = new ArrayList<Pair>();
        	HttpSession s = event.getSession();
        	sessionDetails.add(new Pair("session", s));
        	sessionDetails.add(new Pair("starttime", df.format(new Date())));
        	sessions.put(s.getId(), sessionDetails);
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