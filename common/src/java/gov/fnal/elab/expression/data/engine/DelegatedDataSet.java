/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class DelegatedDataSet extends AbstractDataSet {

    private DataSet ds;
    
    public DelegatedDataSet(DataSet ds) {
        this.ds = ds;
    }

    public String getLabel() {
        return ds.getLabel();
    }

    public Number getX(int index) {
        return ds.getX(index);
    }

    public String getXLabel() {
        return ds.getXLabel();
    }

    public Range getXRange() {
        return ds.getXRange();
    }

    public Unit getXUnit() {
        return ds.getXUnit();
    }

    public Number getY(int index) {
        return ds.getY(index);
    }

    public String getYLabel() {
        return ds.getYLabel();
    }

    public Range getYRange() {
        return ds.getYRange();
    }

    public Unit getYUnit() {
        return ds.getYUnit();
    }

    public Number map(Number x) {
        return ds.map(x);
    }

    public int size() {
        return ds.size();
    }
}
