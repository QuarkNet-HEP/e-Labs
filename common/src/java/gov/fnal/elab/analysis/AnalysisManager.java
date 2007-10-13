/*
 * Created on Apr 19, 2007
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.Elab;
import gov.fnal.elab.ElabGroup;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.log4j.Logger;

/**
 * This class is used to manage a set of analyses in a session
 */
public class AnalysisManager {
    public static final Logger logger = Logger.getLogger(AnalysisManager.class);

    /**
     * The interval, in milliseconds at which the reaper wakes and reaps
     * analyses
     */
    public static final int REAPER_WAKE_INTERVAL = 60 * 60 * 1000;
    public static final int MAX_ANALYSES = 80;

    public static final String ANALYSES = "elab:analyses";

    private static Map reapers = new HashMap();

    /**
     * Registers an analysis run in the specified session
     */
    public static void registerAnalysisRun(Elab elab, ElabGroup user,
            AnalysisRun run) {
        Map a = getAnalysisRuns(elab, user);
        synchronized (a) {
            a.put(run.getId(), run);
        }
    }

    /**
     * Returns a {id -> run} map of analysis runs registered with the specified
     * session.
     */
    public static Map getAnalysisRuns(Elab elab, ElabGroup user) {
        Map a;
        synchronized (AnalysisManager.class) {
            Map users = getAnalysisRuns(elab);
            a = (Map) users.get(user.getName());
            if (a == null) {
                a = new TreeMap(new IDComparator());
                users.put(user.getName(), a);
            }
        }
        return a;
    }

    private static Map getAnalysisRuns(Elab elab) {
        synchronized (AnalysisManager.class) {
            Map users = (Map) elab.getAttribute(ANALYSES);
            if (users == null) {
                users = new HashMap();
                elab.setAttribute(ANALYSES, users);
                initializeReaper(elab);
            }
            return users;
        }
    }

    private static void initializeReaper(Elab elab) {
        AnalysisReaper reaper = (AnalysisReaper) reapers.get(elab.getName());
        if (reaper == null) {
            reaper = new AnalysisReaper(elab);
            reaper.start();
        }
    }

    /**
     * Returns a collection of IDs of analyses registered in the specified
     * session
     */
    public static Collection getAnalysisRunIDs(Elab elab, ElabGroup user) {
        Map a = getAnalysisRuns(elab, user);
        synchronized (a) {
            return new ArrayList(a.keySet());
        }
    }

    /**
     * Retrieves an analysis run registered in a session based on its ID
     */
    public static AnalysisRun getAnalysisRun(Elab elab, ElabGroup user,
            String id) {
        Map a = getAnalysisRuns(elab, user);
        synchronized (a) {
            return (AnalysisRun) a.get(id);
        }
    }

    /**
     * Removes an analysis run from a session
     */
    public static void removeAnalysisRun(Elab elab, ElabGroup user, String id) {
        Map a = getAnalysisRuns(elab, user);
        synchronized (a) {
            a.remove(id);
        }
    }

    private static class AnalysisReaper extends Thread {
        private final Elab elab;
        private long lifetime;

        public AnalysisReaper(Elab elab) {
            super("Analysis Reaper: " + elab.getName());
            setDaemon(true);
            this.elab = elab;
            String hr = elab.getProperty("max.analysis.lifetime");
            try {
                lifetime = Integer.parseInt(hr);
            }
            catch (Exception e) {
                lifetime = 1;
                logger.warn("Invalid max.analysis.lifetime: " + hr
                        + ". Using default: " + lifetime + " hr");
            }
            lifetime *= 3600 * 1000;
        }

        public void run() {
            try {
                while (true) {
                    Thread.sleep(REAPER_WAKE_INTERVAL);
                    Map runs = getAnalysisRuns(elab);
                    Map copy;
                    synchronized (AnalysisManager.class) {
                        copy = new HashMap(runs);
                    }
                    Iterator i = copy.entrySet().iterator();
                    while (i.hasNext()) {
                        Map.Entry e = (Map.Entry) i.next();
                        Map analyses = (Map) e.getValue();
                        Collection r = reap(analyses);
                        synchronized (analyses) {
                            analyses.keySet().removeAll(r);
                        }
                    }
                }
            }
            catch (InterruptedException e) {
            }
        }

        private Collection reap(Map analyses) {
            List l = new ArrayList();
            if (analyses != null) {
                Date now = new Date();
                int index = 1;
                Iterator i = analyses.entrySet().iterator();
                while (i.hasNext()) {
                    Map.Entry e = (Map.Entry) i.next();
                    String id = (String) e.getKey();
                    AnalysisRun run = (AnalysisRun) e.getValue();
                    Date started = run.getStartTime();
                    if (started == null) {
                        logger.warn("Missing start time for run " + id);
                    }
                    else {
                        if (started.getTime() + lifetime < now.getTime()
                                || index + MAX_ANALYSES < analyses.size()) {
                            logger.info("Reaping run " + id);
                            l.add(id);
                        }
                    }
                    index++;
                }
            }
            return l;
        }
    }
    
    private static class IDComparator implements Comparator {
        public int compare(Object o1, Object o2) {
            String id1 = (String) o1;
            String id2 = (String) o2;
            int i1 = Integer.parseInt(id1);
            int i2 = Integer.parseInt(id2);
            return i1 - i2;
        }
    }
}
