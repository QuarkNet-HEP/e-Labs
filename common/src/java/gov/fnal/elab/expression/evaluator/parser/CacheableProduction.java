/*
 * Created on Feb 11, 2010
 */
package gov.fnal.elab.expression.evaluator.parser;

import net.percederberg.grammatica.parser.Production;
import net.percederberg.grammatica.parser.ProductionPattern;

public class CacheableProduction extends Production {

    public CacheableProduction(ProductionPattern pattern) {
        super(pattern);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof CacheableProduction) {
            CacheableProduction other = (CacheableProduction) obj;
            if (getPattern().getId() != other.getPattern().getId()) {
                return false;
            }
            if (getChildCount() != other.getChildCount()) {
                return false;
            }
            switch (getPattern().getId()) {
                case I2u2expConstants.IDENT:
                case I2u2expConstants.NUMBER:
                case I2u2expConstants.STRING:
                    if (!getValue(0).equals(other.getValue(0))) {
                        return false;
                    }
                    break;
                default:
                    for (int i = 0; i < getChildCount(); i++) {
                        if (!getChildAt(i).equals(other.getChildAt(i))) {
                            return false;
                        }
                    }
            }
            return true;
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        int hc = 0;
        switch (getPattern().getId()) {
            case I2u2expConstants.IDENT:
            case I2u2expConstants.NUMBER:
            case I2u2expConstants.STRING:
                hc += getValue(0).hashCode();
                break;
            default:
                for (int i = 0; i < getChildCount(); i++) {
                    hc += getChildAt(i).hashCode();
                }
        }
        return hc;
    }
}
