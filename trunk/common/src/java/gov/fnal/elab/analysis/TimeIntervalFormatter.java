/*
 * Created on Jan 30, 2009
 */
package gov.fnal.elab.analysis;

import java.util.Date;

public class TimeIntervalFormatter {
    public static String format(Date start, Date end) {
        if (end == null || start == null) {
            return "-";
        }
        return format(end.getTime() - start.getTime());
    }

    private static int seconds(int secondsInterval) {
        return secondsInterval % 60;
    }

    private static int minutes(int secondsInterval) {
        return (secondsInterval / 60) % 60;
    }

    private static int hours(int secondsInterval) {
        return secondsInterval / 3600;
    }
    
    private static void pad(StringBuffer sb, int value) {
        if (value < 10) {
            sb.append('0');
        }
        sb.append(String.valueOf(value));
    }
    
    public static String format(long milliSecondInterval) {
    	return formatSeconds((int) (milliSecondInterval / 1000));
    }

    public static String formatSeconds(int seconds) {
        if (seconds < 0) {
            return "-";
        }
        StringBuffer sb = new StringBuffer();
        pad(sb, hours(seconds));
        sb.append(':');
        pad(sb, minutes(seconds));
        sb.append(':');
        pad(sb, seconds(seconds));
        return sb.toString();
    }
}
