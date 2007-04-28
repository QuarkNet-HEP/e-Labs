/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.cosmic.util;

import java.util.ArrayList;
import java.util.List;

public class AnalysisParameterTools {
    public static String getDetectorIds(String[] rawData) {
        StringBuffer db = new StringBuffer();
        for (int i = 0; i < rawData.length; i++) {
            String s = rawData[i];
            String detectorID = s.substring(0, s.indexOf("."));
            db.append(detectorID);
            if (i < rawData.length - 1) {
                db.append(' ');
            }
        }
        return db.toString();
    }

    public static List getThresholdFiles(String[] rawData) {
        List l = new ArrayList(rawData.length);
        for (int i = 0; i < rawData.length; i++) {
            String s = rawData[i];
            String detectorID = s.substring(0, s.indexOf("."));
            l.add(detectorID + "/" + s + ".thresh");
        }
        return l;
    }
}
