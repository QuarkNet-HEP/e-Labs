/*
 * Created on May 23, 2014
 */
package gov.fnal.elab.analysis.pqueue;

import java.util.HashMap;
import java.util.Map;

/* 
 * This class should be in cosmic, but I am adding it here 
 * now to have everything in one place
 */
public class AnalysisQueues {
    
    public static AnalysisQueue getQueue(String name) {
        AnalysisQueue queue = queues.get(name);
        if (queue == null) {
            throw new IllegalArgumentException("No such queue: " + name);
        }
        return queue;
    }
    
    private static Map<String, AnalysisQueue> queues;
    
    static {
        queues = new HashMap<String, AnalysisQueue>();
        
        queues.put("local", new DefaultAnalysisQueue(1));
        queues.put("i2u2", new DefaultAnalysisQueue(6));
        queues.put("grid", new DefaultAnalysisQueue(Integer.MAX_VALUE));
    }
}
