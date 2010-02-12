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
            for (int i = 0; i < getChildCount(); i++) {
                if (!getChildAt(i).equals(other.getChildAt(i))) {
                    return false;
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
        int hc = getPattern().getName().hashCode();
        for (int i = 0; i < getChildCount(); i++) {
            hc += getChildAt(i).hashCode();
        }
        return hc;
    }
}
