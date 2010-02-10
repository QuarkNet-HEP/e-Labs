/*
 * Created on Feb 4, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import java.text.DecimalFormat;
import java.text.NumberFormat;

public class Record {
    public final boolean valid;
    public final double time;
    public final Number sum;
    
    public Record(boolean valid, double time, Number sum) {
        this.valid = valid;
        this.time = time;
        this.sum = sum;
    }
    
    private static final NumberFormat NF = new DecimalFormat("0000.000");
    
    public String toString() {
        return NF.format(time) + ": " + sum + (valid ? "" : " (invalid)");
    }
}
