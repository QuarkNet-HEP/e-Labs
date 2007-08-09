/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.cosmic.util;

import gov.fnal.elab.Elab;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class AnalysisParameterTools {
    public static String getDetectorIds(String[] rawData) {
        StringBuffer db = new StringBuffer();
        for (int i = 0; i < rawData.length; i++) {
            String s = rawData[i];
            db.append(getDetectorId(s));
            if (i < rawData.length - 1) {
                db.append(' ');
            }
        }
        return db.toString();
    }

    public static String getDetectorId(String rawData) {
        return rawData.substring(0, rawData.indexOf("."));
    }

    public static List getThresholdFiles(Elab elab, String[] rawData) {
        List l = new ArrayList(rawData.length);
        for (int i = 0; i < rawData.length; i++) {
            String s = new File(rawData[i]).getName();
            String detectorID = s.substring(0, s.indexOf("."));
            l.add(elab.getProperties().getDataDir() + File.separator
                    + detectorID + File.separator + s + ".thresh");
        }
        return l;
    }
}
