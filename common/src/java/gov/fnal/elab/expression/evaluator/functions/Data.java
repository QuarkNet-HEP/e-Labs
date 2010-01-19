/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.Options;
import gov.fnal.elab.expression.data.engine.Range;
import gov.fnal.elab.expression.evaluator.Interpreter;

public class Data extends Function {
    public static final int[] TYPES = new int[] { Value.STRING, Value.NUMBER, Value.NUMBER, Value.NUMBER };

    public Data(Interpreter interpreter) {
        super(interpreter);
    }

    @Override
    public Value invoke(Value[] args) {
        checkArgs(args, TYPES);
        Range range;
        if (args[1].getNumericValue() instanceof Integer) {
            range = new Range(args[1].getNumericValue().intValue(), args[2].getNumericValue().intValue());
        }
        else {
            range = new Range(args[1].getNumericValue().doubleValue(), args[2].getNumericValue().doubleValue());
        }
        return new Value(getInterpreter().getEngine().get(args[0].getStringValue(), range,
            new Options().setSamples(args[3].getNumericValue().intValue())));
    }
}
