/*
 * Created on Apr 19, 2007
 */
package gov.fnal.elab.analysis;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpSession;

public class AnalysisManager {
    public static final String SESSION_ANALYSES = "elab:analyses";
    
    public static void registerAnalysisRun(HttpSession session, AnalysisRun run) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            a.put(run.getId(), run);
        }
    }
    
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

    public static Collection getAnalysisRunIDs(HttpSession session) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            return new ArrayList(a.keySet());
        }
    }

    public static AnalysisRun getAnalysisRun(HttpSession session, String id) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            return (AnalysisRun) a.get(id);
        }
    }

    public static void removeAnalysisRun(HttpSession session, String id) {
        Map a = getAnalysisRuns(session);
        synchronized (a) {
            a.remove(id);
        }
    }
}
