/*
 * Created on Jul 9, 2007
 */
package gov.fnal.elab.util;

import java.util.Date;

public class NanoDate extends Date {
    private int nanoSecondsFraction, nanoSeconds, microSeconds, milliSeconds;

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

    public int getMilliSeconds() {
        return milliSeconds;
    }

    public void setMilliSeconds(int milliSeconds) {
        this.milliSeconds = milliSeconds;
    }

    public void setNanoSecondsFraction(int nanoSecondsFraction) {
    	this.nanoSecondsFraction = nanoSecondsFraction;
    }
    
    public int getNanoSecondsFraction() {
    	return nanoSecondsFraction;
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
