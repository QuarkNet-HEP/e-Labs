/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog;

import java.util.LinkedList;
import java.util.List;

public class Query {
    private List constraints;
    
    public Query() {
        constraints = new LinkedList();
    }
    
    public void addConstraint(Tuple c) {
        constraints.add(c);
    }
}
