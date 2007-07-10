/*
 * Created on Jul 9, 2007
 */
package gov.fnal.elab.util;

import java.util.Date;

public class NanoDate extends Date {
    private int nanoSeconds, microSeconds;

    public NanoDate() {
        super();
    }

    public NanoDate(long date) {
        super(date);
    }

    public int getNanoSeconds() {
        return nanoSeconds;
    }

    public void setNanoSeconds(int nanoSeconds) {
        this.nanoSeconds = nanoSeconds;
    }

    public int getMicroSeconds() {
        return microSeconds;
    }

    public void setMicroSeconds(int microSeconds) {
        this.microSeconds = microSeconds;
    }

    public int compareTo(Date anotherDate) {
        int dc = super.compareTo(anotherDate);
        if (dc == 0 && anotherDate instanceof NanoDate) {
            NanoDate nd = (NanoDate) anotherDate;
            dc = microSeconds - nd.microSeconds;
            if (dc == 0) {
                return nanoSeconds - nd.nanoSeconds;
            }
            else {
                return dc;
            }
        }
        else {
            return dc;
        }
    }

    public boolean equals(Object obj) {
        if (obj instanceof NanoDate) {
            NanoDate nd = (NanoDate) obj;
            return super.equals(obj) && microSeconds == nd.microSeconds
                    && nanoSeconds == nd.nanoSeconds;
        }
        else {
            return super.equals(obj);
        }
    }
}
