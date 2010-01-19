/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.parser;

import static org.junit.Assert.assertTrue;
import net.percederberg.grammatica.parser.Node;
import net.percederberg.grammatica.parser.ParserCreationException;
import net.percederberg.grammatica.parser.ParserLogException;

import org.junit.Test;

public class ParserTest implements I2u2expConstants {
    
    @Test public void testSimpleInvocation() throws ParserCreationException, ParserLogException {
        Parser p = new Parser("a()");
        Node r = p.parse();
        
        assertTrue(r.getId() == INVOCATION);
        assertTrue(r.getChildCount() == 1);
        assertTrue(r.getChildAt(0).getId() == IDENT);
        assertTrue(r.getChildAt(0).getValueCount() == 1);
        assertTrue(r.getChildAt(0).getValue(0).equals("a"));
    }

    @Test public void testNumbers() throws ParserCreationException, ParserLogException {
        Parser p = new Parser("a(1, -1, 1.0, +0.2, 123.33, 12e2, 4e-3, 5e+2, -1.2e-2)");
        Node r = p.parse();
        
        assertTrue(r.getId() == INVOCATION);
        assertTrue(r.getChildCount() == 10);
        assertTrue(r.getChildAt(0).getId() == IDENT);
        assertTrue(r.getChildAt(0).getValueCount() == 1);
        assertTrue(r.getChildAt(0).getValue(0).equals("a"));
        assertNumberEquals(r.getChildAt(1), new Integer(1));
        assertNumberEquals(r.getChildAt(2), new Integer(-1));
        assertNumberEquals(r.getChildAt(3), new Double(1.0));
        assertNumberEquals(r.getChildAt(4), new Double(0.2));
        assertNumberEquals(r.getChildAt(5), new Double(123.33));
        assertNumberEquals(r.getChildAt(6), new Double(12e2));
        assertNumberEquals(r.getChildAt(7), new Double(4e-3));
        assertNumberEquals(r.getChildAt(8), new Double(5e+2));
        assertNumberEquals(r.getChildAt(9), new Double(-1.2e-2));
    }
    
    @Test public void testStrings() throws ParserCreationException, ParserLogException {
        Parser p = new Parser("xyz(\"a\", \"ab\", \"abc\", \"\\n-\\t-\\\"\\\\\")");
        Node r = p.parse();
        
        assertTrue(r.getId() == INVOCATION);
        assertTrue(r.getChildCount() == 5);
        assertTrue(r.getChildAt(0).getId() == IDENT);
        assertTrue(r.getChildAt(0).getValueCount() == 1);
        assertTrue(r.getChildAt(0).getValue(0).equals("xyz"));
        assertStringEquals(r.getChildAt(1), "a");
        assertStringEquals(r.getChildAt(2), "ab");
        assertStringEquals(r.getChildAt(3), "abc");
        assertStringEquals(r.getChildAt(4), "\n-\t-\"\\");
    }

    private void assertNumberEquals(Node n, Number v) {
        assertTrue(n.getId() == NUMBER);
        assertTrue(n.getChildCount() == 0);
        assertTrue(n.getValueCount() == 1);
        assertTrue(v.equals(n.getValue(0)));
    }
    
    private void assertStringEquals(Node n, String v) {
        assertTrue(n.getId() == STRING);
        assertTrue(n.getChildCount() == 0);
        assertTrue(n.getValueCount() == 1);
        assertTrue(v + " == " + n.getValue(0), v.equals(n.getValue(0)));
    }
}
