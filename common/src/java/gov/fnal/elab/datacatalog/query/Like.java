//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Jan 22, 2009
 */
package gov.fnal.elab.datacatalog.query;

public class Like extends QueryLeaf {
    public Like(String key, Object value) {
        super(QueryElement.LIKE, key, value);   
    }
}
