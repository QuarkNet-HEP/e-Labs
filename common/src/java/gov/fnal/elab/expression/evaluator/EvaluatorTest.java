/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator;

import org.junit.Test;

public class EvaluatorTest {
    @Test public void testBasicWorkings() {
        Evaluator.getDefault().evaluate("log(threshold(data(\"sine\", 0, 40, 100), 1, 5))");
    }
}
