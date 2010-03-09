/*
 * Created on Mar 8, 2010
 */
package gov.fnal.elab.analysis;

import gov.fnal.elab.analysis.notifiers.DefaultAnalysisNotifier;
import gov.fnal.elab.analysis.notifiers.UploadNotifier;

import java.util.HashMap;
import java.util.Map;

public class AnalysisNotifierFactory {
    private static final Map<String, Class<? extends AnalysisNotifier>> NOTIFIERS;
    
    static {
        NOTIFIERS = new HashMap<String, Class<? extends AnalysisNotifier>>();
        NOTIFIERS.put("default", DefaultAnalysisNotifier.class);
        NOTIFIERS.put("upload", UploadNotifier.class);
    }
    
    
    public static AnalysisNotifier newNotifier(String type) {
        Class<? extends AnalysisNotifier> cls = NOTIFIERS.get(type);
        if (cls == null) {
            throw new IllegalArgumentException("No such notifier type: " + type);
        }
        try {
            return cls.newInstance();
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
