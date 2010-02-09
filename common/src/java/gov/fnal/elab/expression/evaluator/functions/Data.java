/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataBackendException;
import gov.fnal.elab.expression.data.engine.DataPath;
import gov.fnal.elab.expression.data.engine.Options;
import gov.fnal.elab.expression.data.engine.Range;
import gov.fnal.elab.expression.evaluator.EvaluationException;
import gov.fnal.elab.expression.evaluator.Interpreter;

public class Data extends Function {
    public static final Value.Types[] TYPES = new Value.Types[] { Value.Types.STRING, Value.Types.NUMBER, Value.Types.NUMBER, Value.Types.NUMBER };

    public Data(Interpreter interpreter) {
        super(interpreter);
    }

    @Override
    public Value invoke(Value[] args) throws EvaluationException {
        checkArgs(args, TYPES);
        Range range;
        if (args[1].getNumericValue() instanceof Integer) {
            range = new Range(args[1].getNumericValue().intValue(), args[2].getNumericValue().intValue());
        }
        else {
            range = new Range(args[1].getNumericValue().doubleValue(), args[2].getNumericValue().doubleValue());
        }
        try {
            return new Value(getInterpreter().getEngine().get(new DataPath(args[0].getStringValue()), range,
                new Options().setSamples(args[3].getNumericValue().intValue())));
        }
        catch (DataBackendException e) {
            throw new EvaluationException(e);
        }
    }
}
