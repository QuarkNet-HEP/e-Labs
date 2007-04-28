/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import gov.fnal.elab.datacatalog.Tuple;

import java.util.Collection;
import java.util.Iterator;


public abstract class CatalogEntry {
    private String lfn;

    public abstract Object getTupleValue(String key);
    
    public abstract void setTupleValue(String key, Object value);
    
    public abstract Iterator tupleIterator();
    
    /**
     * To make JSP EL happy
     */
    public Iterator getTupleIterator() {
        return tupleIterator();
    }
    
    public abstract Collection getTuples();

    public void setLFN(String lfn) {
        this.lfn = lfn;
    }
    
    public String getLFN() {
        return this.lfn;
    }
    
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(lfn);
        sb.append('{');
        Iterator i = tupleIterator();
        while (i.hasNext()) {
            Tuple t = (Tuple) i.next();
            sb.append(t.getKey());
            sb.append('=');
            sb.append(t.getValue());
            if (i.hasNext()) {
                sb.append(", ");
            }
        }
        sb.append('}');
        return sb.toString();
    }
}
