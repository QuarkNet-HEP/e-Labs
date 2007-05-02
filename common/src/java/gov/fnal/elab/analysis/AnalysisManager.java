/*
 * Created on Apr 19, 2007
 */
package gov.fnal.elab.analysis;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpSession;

/**
 * This class is used to manage a set of analyses in a session
 */
public class AnalysisManager {
    public static final String SESSION_ANALYSES = "elab:analyses";

    /**
     * Registers an analysis run in the specified session
     */
    public static void registerAnalysisRun(HttpSession session, AnalysisRun run) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            a.put(run.getId(), run);
        }
    }

    /**
     * Returns a {id -> run} map of analysis runs registered with the specified
     * session.
     */
    protected static Map getAnalysisRuns(HttpSession session) {
        Map a;
        synchronized (session) {
            a = (Map) session.getAttribute(SESSION_ANALYSES);
            if (a == null) {
                a = new TreeMap();
            }
            session.setAttribute(SESSION_ANALYSES, a);
        }
        return a;
    }

    /**
     * Returns a collection of IDs of analyses registered in the specified
     * session
     */
    public static Collection getAnalysisRunIDs(HttpSession session) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            return new ArrayList(a.keySet());
        }
    }

    /**
     * Retrieves an analysis run registered in a session based on its ID
     */
    public static AnalysisRun getAnalysisRun(HttpSession session, String id) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            return (AnalysisRun) a.get(id);
        }
    }

    /**
     * Removes an analysis run from a session
     */
    public static void removeAnalysisRun(HttpSession session, String id) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            a.remove(id);
        }
    }
}
