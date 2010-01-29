/*
 * Created on Jan 28, 2010
 */
package gov.fnal.elab.ligo.data.engine;

import gov.fnal.elab.expression.data.engine.AbstractDataSet;
import gov.fnal.elab.expression.data.engine.DataPath;
import gov.fnal.elab.expression.data.engine.MetricUnit;
import gov.fnal.elab.expression.data.engine.Range;
import gov.fnal.elab.expression.data.engine.Unit;

public class NumberArrayDataSet extends AbstractDataSet {
    private Number[] data;
    private DataPath dp;
    private Range xrange, yrange;
    private String units;

    public NumberArrayDataSet(DataPath dp, Range xrange, Range yrange, Number[] data, String units) {
        this.dp = dp;
        this.xrange = xrange;
        this.yrange = yrange;
        this.data = data;
        this.units = units;
    }

    public String getLabel() {
        return dp.getName();
    }

    public Number getX(int index) {
        return xrange.getStart().doubleValue() + index * xrange.getRange().doubleValue() / data.length;
    }

    public String getXLabel() {
        return "GPSTime";
    }

    public Range getXRange() {
        return xrange;
    }

    public Unit getXUnit() {
        return new MetricUnit("s");
    }

    public Number getY(int index) {
        return data[index];
    }

    public String getYLabel() {
        return dp.getName();
    }

    public Range getYRange() {
        return yrange;
    }

    public Unit getYUnit() {
        return new MetricUnit(units);
    }

    public Number map(Number x) {
        return getY((int) ((x.doubleValue() - xrange.getStart().doubleValue()) / xrange.getRange().doubleValue() * data.length));
    }

    public int size() {
        return data.length;
    }

}
