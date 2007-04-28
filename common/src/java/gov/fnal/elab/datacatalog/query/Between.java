//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog.query;

public class Between extends And {
    public Between(String key, Object value1, Object value2) {
        super.add(new GreaterThan(key, value1));
        super.add(new LessThan(key, value2));
    }
}
