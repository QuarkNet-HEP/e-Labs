/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.DelegatedDataSet;
import gov.fnal.elab.expression.data.engine.Range;
import gov.fnal.elab.expression.data.engine.Unit;

public class Abs extends Function {
    public static final Value.Types[] TYPES = new Value.Types[] { Value.Types.DATASET };

    @Override
    public Value invoke(Value[] args) {
        checkArgs(args, TYPES);
        final DataSet ds = args[0].getDataSetValue();
        return new Value(new DelegatedDataSet(ds) {
            
            public Number getY(int index) {
                return abs(ds.getY(index));
            }

            public String getYLabel() {
                return ds.getYLabel() + " (abs)";
            }

            public Range getYRange() {
                return new Range(0, Math.abs(ds.getYRange().getEnd().doubleValue()));
            }

            public Unit getYUnit() {
                return ds.getYUnit().log();
            }

            public Number map(Number x) {
                return abs(ds.map(x).doubleValue());
            }
            
            private Number abs(Number n) {
                if (n == null) {
                    return null;
                }
                else {
                    return Math.abs(n.doubleValue());
                }
            }
        });
    }
}
