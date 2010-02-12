/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.parser;

import net.percederberg.grammatica.parser.Node;
import net.percederberg.grammatica.parser.ParseException;
import net.percederberg.grammatica.parser.Production;
import net.percederberg.grammatica.parser.ProductionPattern;
import net.percederberg.grammatica.parser.Token;

public class CustomAnalyzer extends I2u2expAnalyzer {

    @Override
    protected Node exitNumber(Token node) throws ParseException {
        if (node.getImage().contains(".") || node.getImage().contains("e")) {
            node.addValue(new Double(node.getImage()));
        }
        else {
            node.addValue(new Integer(node.getImage()));
        }
        return node;
    }

    @Override
    protected Node exitLparen(Token node) throws ParseException {
        return null;
    }

    @Override
    protected Node exitRparen(Token node) throws ParseException {
        return null;
    }

    @Override
    protected Node exitComma(Token node) throws ParseException {
        return null;
    }

    @Override
    protected Node exitMain(Production node) throws ParseException {
        return node.getChildAt(0);
    }

    @Override
    protected Node exitString(Token node) throws ParseException {
        node.addValue(processString(node, node.getImage()));
        return node;
    }

    private String processString(Token t, String s) throws ParseException {
        StringBuilder sb = new StringBuilder();
        boolean esc = false;
        for (int i = 1; i < s.length() - 1; i++) {
            char c = s.charAt(i);
            if (esc) {
                switch (c) {
                    case '\\':
                        break;
                    case 'n':
                        c = '\n';
                        break;
                    case 't':
                        c = '\t';
                        break;
                    case 'r':
                        c = '\r';
                        break;
                    case 'b':
                        c = '\b';
                        break;
                    case 'f':
                        c = '\f';
                        break;
                    case '"':
                        c = '"';
                        break;
                    default:
                        throw new ParseException(ParseException.UNEXPECTED_CHAR_ERROR, "Invalid escape sequence: \\"
                                + c, t.getStartLine(), t.getStartColumn());
                }
                sb.append(c);
                esc = false;
            }
            else {
                if (c == '\\') {
                    esc = true;
                }
                else {
                    sb.append(c);
                }
            }
        }
        return sb.toString();
    }

    @Override
    protected Node exitItem(Production node) throws ParseException {
        return node.getChildAt(0);
    }

    @Override
    protected Node exitIdent(Token node) throws ParseException {
        node.addValue(node.getImage());
        return node;
    }

    @Override
    protected Production newProduction(ProductionPattern pattern) {
        return new CacheableProduction(pattern);
    }
}
