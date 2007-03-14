//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 14, 2007
 */
package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.datacatalog.CatalogEntry;

import java.util.List;

public class VDSCatalogEntry extends CatalogEntry {
    private List tuples;
    
    protected void setTuples(List tuples) {
        this.tuples = tuples;
    }

    public Object getTupleValue(String key) {
        return null;
    }

}
