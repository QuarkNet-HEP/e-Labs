/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

public class SimpleQuery {
    private List constraints;
    
    public SimpleQuery() {
        constraints = new LinkedList();
    }
    
    public void addConstraint(Tuple c) {
        constraints.add(c);
    }

    public Collection getConstraints() {
        return constraints;
    }
}
