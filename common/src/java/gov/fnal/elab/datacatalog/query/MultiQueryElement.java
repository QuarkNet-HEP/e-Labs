//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 22, 2007
 */
package gov.fnal.elab.datacatalog.query;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public abstract class MultiQueryElement implements QueryElement {
    private final int type;
    private List children;
            
    public MultiQueryElement(int type) {
        this.type = type;
        children = new LinkedList();
    }
    
    public void add(QueryElement c) {
        children.add(c);
    }

    public Collection getAll() {
        return children;
    }

    public int getType() {
        return type;
    }
    
    public boolean isLeaf() {
        return false;
    }
    
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(NAMES[type]);
        sb.append('(');
        Iterator i = children.iterator();
        while (i.hasNext()) {
            sb.append(i.next().toString());
            if (i.hasNext()) {
                sb.append(", ");
            }
        }
        sb.append(')');
        return sb.toString();
    }
}
