/*
 * Created on Jul 30, 2007
 */
package gov.fnal.elab.analysis;

import java.util.HashMap;
import java.util.Map;

public class ProgressTracker {
    private Map progressMap = new HashMap();

    public int getTotal(String type) {
        synchronized (progressMap) {
            Integer t = (Integer) progressMap.get(type);
            if (t == null) {
                return -1;
            }
            else {
                return t.intValue();
            }
        }
    }

    public void setTotal(String type, int total) {
        synchronized (progressMap) {
            progressMap.put(type, new Integer(total));
        }
    }
}
