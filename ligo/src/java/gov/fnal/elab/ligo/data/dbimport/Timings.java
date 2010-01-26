/*
 * Created on Jan 26, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.util.HashMap;
import java.util.Map;

public class Timings {
    
    private static Map<String, Long> timingInfo = new HashMap<String, Long>();
    
    public static void timingStart(String key) {
        timingInfo.put("#" + key, System.currentTimeMillis());
    }

    public static void timingEnd(String key) {
        Long l = timingInfo.get(key);
        if (l == null) {
            l = 0L;
        }
        timingInfo.put(key, l + System.currentTimeMillis() - timingInfo.remove("#" + key));
    }

    public static void print() {
        System.out.println(timingInfo);
    }
}
