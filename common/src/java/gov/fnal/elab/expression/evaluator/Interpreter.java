/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator;

import gov.fnal.elab.expression.data.engine.DataEngine;
import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.evaluator.functions.Data;
import gov.fnal.elab.expression.evaluator.functions.Function;
import gov.fnal.elab.expression.evaluator.functions.Log;
import gov.fnal.elab.expression.evaluator.functions.Abs;
import gov.fnal.elab.expression.evaluator.functions.Threshold;
import gov.fnal.elab.expression.evaluator.functions.Value;
import gov.fnal.elab.expression.evaluator.parser.I2u2expConstants;

import java.util.HashMap;
import java.util.Map;
import java.util.WeakHashMap;

import net.percederberg.grammatica.parser.Node;

public class Interpreter implements I2u2expConstants {
    private Node n;
    private DataEngine engine;
    private Map<String, Function> functions;
    private Map<Node, Value> cache;

    public Interpreter(Node n, DataEngine engine) {
        this.n = n;
        this.engine = engine;
        cache = new WeakHashMap<Node, Value>();
        createFunctionSet();
    }

    private void createFunctionSet() {
        functions = new HashMap<String, Function>();
        functions.put("data", new Data(this));
        functions.put("log", new Log());
        functions.put("threshold", new Threshold());
        functions.put("abs", new Abs());
    }

    public DataEngine getEngine() {
        return engine;
    }

    public DataSet run() throws EvaluationException {
        reduce(n);
        return ((Value) n.getValue(0)).getDataSetValue();
    }

    private void reduce(Node n) throws EvaluationException {
        switch (n.getId()) {
            case NUMBER:
                Value v = new Value((Number) n.getValue(0));
                n.removeAllValues();
                n.addValue(v);
                break;
            case STRING:
                Value s = new Value((String) n.getValue(0));
                n.removeAllValues();
                n.addValue(s);
                break;
            case INVOCATION:
                Value value;
                synchronized(cache) {
                    value = cache.get(n);
                }
                if (value == null) {
                    Value[] args = new Value[n.getChildCount() - 1];
                    for (int i = 1; i < n.getChildCount(); i++) {
                        reduce(n.getChildAt(i));
                        args[i - 1] = (Value) n.getChildAt(i).getValue(0);
                    }
                    Function fn = getFunction((String) n.getChildAt(0).getValue(0));
                    value = fn.invoke(args);
                }
                n.removeAllValues();
                n.addValue(value);
                synchronized(cache) {
                    cache.put(n, value);
                }
                break;
            default:
                throw new EvaluationException("Unknown node type in parse tree: " + n);
        }
    }

    private Function getFunction(String name) throws EvaluationException {
        Function f = functions.get(name);
        if (f == null) {
            throw new EvaluationException("No such function: " + name);
        }
        return f;
    }
}
