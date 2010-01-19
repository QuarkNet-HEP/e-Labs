/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.DelegatedDataSet;
import gov.fnal.elab.expression.data.engine.Range;
import gov.fnal.elab.expression.data.engine.Unit;

public class Log extends Function {
    public static final int[] TYPES = new int[] { Value.DATASET };

    @Override
    public Value invoke(Value[] args) {
        checkArgs(args, TYPES);
        final DataSet ds = args[0].getDataSetValue();
        return new Value(new DelegatedDataSet(ds) {
            
            public Number getY(int index) {
                return log(ds.getY(index));
            }

            public String getYLabel() {
                return ds.getYLabel() + " (log)";
            }

            public Range getYRange() {
                return new Range(Math.log(ds.getYRange().getStart().doubleValue()), 
                    Math.log(ds.getYRange().getEnd().doubleValue()));
            }

            public Unit getYUnit() {
                return ds.getYUnit().log();
            }

            public Number map(Number x) {
                return log(ds.map(x).doubleValue());
            }
            
            private Number log(Number n) {
                if (n == null) {
                    return null;
                }
                else {
                    return Math.log(n.doubleValue());
                }
            }
        });
    }
}
