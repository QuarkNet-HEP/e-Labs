/*
 * Created on Jan 25, 2010
 */
package gov.fnal.elab.ligo.data.dbimport;

class DataReaderEntry<ValueType extends Number, SumType extends Number> {
    public final double gpstime;
    public final ValueType value;
    public final SumType sum, ssq;

    public DataReaderEntry(double gpstime, ValueType value, SumType sum, SumType ssq) {
        this.gpstime = gpstime;
        this.value = value;
        this.sum = sum;
        this.ssq = ssq;
    }

}