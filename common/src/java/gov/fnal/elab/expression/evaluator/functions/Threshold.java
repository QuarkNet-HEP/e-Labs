/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.DelegatedDataSet;
import gov.fnal.elab.expression.data.engine.Range;

public class Threshold extends Function {
    public static final int[] TYPES = new int[] { Value.DATASET, Value.NUMBER, Value.NUMBER };

    @Override
    public Value invoke(Value[] args) {
        checkArgs(args, TYPES);
        final DataSet ds = args[0].getDataSetValue();
        final double min = args[1].getNumericValue().doubleValue();
        final double max = args[2].getNumericValue().doubleValue();
        return new Value(new DelegatedDataSet(ds) {

            @Override
            public Range getYRange() {
                double rmin = Math.max(min, super.getYRange().getStart().doubleValue());
                double rmax = Math.min(max, super.getYRange().getEnd().doubleValue());
                return new Range(rmin, rmax);
            }

            @Override
            public Number getY(int index) {
                return threshold(super.getY(index));
            }

            @Override
            public Number map(Number x) {
                return threshold(super.map(x));
            }
            
            private Number threshold(Number n) {
                if (n == null) {
                    return null;
                }
                double value = n.doubleValue();
                if (value < min || value > max) {
                    return null;
                }
                else {
                    return value;
                }
            }
           
        });
    }
}
