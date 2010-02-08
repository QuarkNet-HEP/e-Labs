/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.convert;

class DataReaderEntry<ValueType extends Number, SumType extends Number> {
    public final boolean valid;
    public final double gpstime;
    public final SumType sum, ssq;

    public DataReaderEntry(boolean valid, double gpstime, SumType sum, SumType ssq) {
        this.valid = valid;
        this.gpstime = gpstime;
        this.sum = sum;
        this.ssq = ssq;
    }

    public String toString() {
        return (valid ? "V " : "I ") + gpstime + ":" + sum + ":" + ssq;
    }
}