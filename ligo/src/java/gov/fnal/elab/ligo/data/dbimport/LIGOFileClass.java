/*
 * Created on Jan 27, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

public class LIGOFileClass {
    public final int trend, site;
    
    public LIGOFileClass(int site, int trend) {
        this.site = site;
        this.trend = trend;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof LIGOFileClass) {
            LIGOFileClass cls = (LIGOFileClass) obj;
            return site == cls.site && trend == cls.trend;
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return site << 1 + trend;
    }
}
