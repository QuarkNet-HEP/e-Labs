/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.parser;

import java.io.Reader;
import java.io.StringReader;

import net.percederberg.grammatica.parser.ParserCreationException;

public class Parser extends I2u2expParser {

    public Parser(Reader in) throws ParserCreationException {
        super(in, new CustomAnalyzer());
    }
    
    public Parser(String expr) throws ParserCreationException {
        this(new StringReader(expr));
    }
}
