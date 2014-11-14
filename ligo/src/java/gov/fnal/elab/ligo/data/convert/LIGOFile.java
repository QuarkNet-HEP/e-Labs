/*
 * Created on Jan 26, 2010
 */
package gov.fnal.elab.ligo.data.convert;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LIGOFile implements Comparable<LIGOFile> {
    public static final int SECOND_TREND = 0;
    public static final int MINUTE_TREND = 0;
    
    public final int trend, site;
    private int duration;
    private long startTime;
    public final File file;
   
    public LIGOFile(int site, int trend, File f) {
        this.site = site;
        this.trend = trend;
        this.file = f;
        parse();
    }

    public static final Pattern RE_FILE_GPS_TIME = Pattern.compile("[H|L]-[T|M]-(\\d+)-(\\d+).gwf");
    
    private void parse() {
        Matcher m = RE_FILE_GPS_TIME.matcher(this.file.getName());
        if (!m.matches()) {
            throw new IllegalArgumentException("Invalid ligo file (does not match expected pattern): " + file);
        }
        startTime = Long.parseLong(m.group(1));
        duration = Integer.parseInt(m.group(2));
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof LIGOFile) {
            LIGOFile other = (LIGOFile) obj;
            /*
             * Can't use absolute path because some files appear twice.
             * Maybe this is just a Bluestone requirement, but it happens
             */
            return file.getName().equals(other.file.getName());
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return file.getName().hashCode() + trend * 113 + site * 9771;
    }

    public int compareTo(LIGOFile o) {
        if (this.equals(o)) {
            return 0;
        }
        long t1 = this.startTime;
        int d1 = this.duration;
        long t2 = o.startTime;
        int d2 = o.duration;
        // <--> 1 (this)
        // (--) 2
        // -1 - this < o
        //  0 - this == o
        //  1 - this > o
        // <---->--(------)
        if (t1 + d1 <= t2) {
            return -1;
        }
        // (----)--<------>
        if (t2 + d2 <= t1) {
            return 1;
        }
        // <-(----)--> or (--<---->---)
        if (t1 <= t2 && t1 + d1 >= t2 + d2 || t2 <= t1 && t2 + d2 >= t1 + d1) {
            if (trend == SECOND_TREND) {
                return -1;
            }
            if (o.trend == SECOND_TREND) {
                return 1;
            }
            throw new RuntimeException("This should be unreachable 1 (" + this + ", " + o + ")");
        }
        // <--(---->--) or (--<----)-->
        // this shouldn't actually be happening, since data is aligned
        if (t1 <= t2 && t1 + d1 > t2 || t2 <= t1 && t2 + d2 > t1) {
            if (trend == SECOND_TREND) {
                return -1;
            }
            if (o.trend == SECOND_TREND) {
                return 1;
            }
            throw new RuntimeException("This should be unreachable 2 (" + this + ", " + o + ")");
        }
        throw new RuntimeException("This should be unreachable 3 (" + this + ", " + o + ")");
    }

    @Override
    public String toString() {
        return file.getName();
    }
    
    public int getFileDurationInSeconds() {
        return duration;
    }
    
    public long getFileGPSTime() {
        return startTime;
    }
}