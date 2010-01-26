/*
 * Created on Jan 26, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LIGOFile implements Comparable<LIGOFile> {
    public final int trend, site;
    public final File f;

    public LIGOFile(int site, int trend, File f) {
        this.site = site;
        this.trend = trend;
        this.f = f;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof LIGOFile) {
            LIGOFile other = (LIGOFile) obj;
            return f.getAbsolutePath().equals(other.f.getAbsolutePath());
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return f.getName().hashCode() + trend * 113 + site * 9771;
    }
    
    public static final Pattern RE_FILE_GPS_TIME = Pattern.compile("[H|L]-[T|M]-(\\d+)-(\\d+).gwf");

    public int compareTo(LIGOFile o) {
        if (this.equals(o)) {
            return 0;
        }
        Matcher m1 = RE_FILE_GPS_TIME.matcher(this.f.getName());
        if (m1.matches()) {
            long t1 = Long.parseLong(m1.group(1));
            int d1 = Integer.parseInt(m1.group(2));
            Matcher m2 = RE_FILE_GPS_TIME.matcher(o.f.getName());
            if (m2.matches()) {
                long t2 = Long.parseLong(m2.group(1));
                int d2 = Integer.parseInt(m2.group(2));
                // <--> 1
                // (--) 2
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
                    if (trend == ImportData.SECOND_TREND) {
                        return 1;
                    }
                    if (o.trend == ImportData.SECOND_TREND) {
                        return -1;
                    }
                    throw new RuntimeException("This should be unreachable 1");
                }
                // <--(---->--) or (--<----)-->
                // this shouldn't actually be happening, since data is aligned
                if (t1 <= t2 && t1 + d1 > t2 || t2 <= t1 && t2 + d2 > t1) {
                    if (trend == ImportData.SECOND_TREND) {
                        return 1;
                    }
                    if (o.trend == ImportData.SECOND_TREND) {
                        return -1;
                    }
                    throw new RuntimeException("This should be unreachable 2");
                }
                throw new RuntimeException("This should be unreachable 3");
            }
        }
        throw new RuntimeException("Invalid ligo file: " + f);
    }

    @Override
    public String toString() {
        return f.getName();
    }
    
}