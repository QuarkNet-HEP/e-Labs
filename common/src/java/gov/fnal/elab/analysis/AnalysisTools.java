/*
 * Created on Apr 21, 2007
 */
package gov.fnal.elab.analysis;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;

/**
 * A class with some convenience methods related to analyses
 */
public class AnalysisTools {

    /**
     * Encode parameters to an analysis as URL parameters
     */
    public static String encodeParameters(ElabAnalysis analysis) {
        try {
            boolean first = true;
            StringBuffer sb = new StringBuffer();
            Map params = analysis.getParameters();
            Iterator i = params.entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry e = (Map.Entry) i.next();
                String name = (String) e.getKey();
                Object o = e.getValue();
                if (analysis.isDefaultValue(name, o)) {
                    continue;
                }
                if (o instanceof Collection) {
                    Iterator j = ((Collection) o).iterator();
                    while (j.hasNext()) {
                        first = encodeOne(sb, name, j.next(), first);
                    }
                }
                else {
                    first = encodeOne(sb, name, o, first);
                }
            }
            return sb.toString();
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException(
                    "Oh my. UTF-8 is not supported on this platform.");
        }
    }

    protected static boolean encodeOne(StringBuffer sb, String name,
            Object value, boolean first) throws UnsupportedEncodingException {
        if (value != null) {
            if (!first) {
                sb.append('&');
            }
            sb.append(URLEncoder.encode(name, "UTF-8"));
            sb.append('=');
            sb.append(URLEncoder.encode(value.toString(), "UTF-8"));
            return false;
        }
        else {
            return first;
        }
    }

    public static String getStatusString(AnalysisRun run) {
        switch (run.getStatus()) {
            case AnalysisRun.STATUS_CANCELED:
                return "Canceled";
            case AnalysisRun.STATUS_RUNNING:
                return "Running";
            case AnalysisRun.STATUS_FAILED:
                return "Failed";
            case AnalysisRun.STATUS_COMPLETED:
                return "Completed";
            default:
                return "Unknown";
        }
    }

    public static double getProgress(AnalysisRun run) {
        switch (run.getStatus()) {
            case AnalysisRun.STATUS_COMPLETED:
                return 1.0;
            case AnalysisRun.STATUS_FAILED:
                return 0.0;
            case AnalysisRun.STATUS_RUNNING:
                return run.getProgress();
            case AnalysisRun.STATUS_CANCELED:
                return 0.0;
            case AnalysisRun.STATUS_NONE:
                return 0.0;
            default:
                return 0.0;
        }
    }
}
