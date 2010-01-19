/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.evaluator;

import gov.fnal.elab.expression.data.engine.DataEngine;
import gov.fnal.elab.expression.data.engine.DataSet;
import gov.fnal.elab.expression.data.engine.FakeDataEngine;
import gov.fnal.elab.expression.evaluator.parser.Parser;
import net.percederberg.grammatica.parser.Node;
import net.percederberg.grammatica.parser.ParserCreationException;
import net.percederberg.grammatica.parser.ParserLogException;

public class Evaluator {
    private DataEngine engine;
    
    public Evaluator(DataEngine engine) {
        this.engine = engine;
    }
    
    public DataSet evaluate(String expr) {
        try {
            Parser p = new Parser(expr);
            Node n = p.parse();
            Interpreter interp = new Interpreter(n, engine);
            return interp.run();
        }
        catch (ParserCreationException e) {
            throw new RuntimeException("Failed to create parser", e);
        }
        catch (ParserLogException e) {
            throw new RuntimeException("Failed to parse input", e);
        }
    }
    
    private static final Evaluator INSTANCE = new Evaluator(new FakeDataEngine());
    
    public static Evaluator getDefault() {
        return INSTANCE;
    }
}
