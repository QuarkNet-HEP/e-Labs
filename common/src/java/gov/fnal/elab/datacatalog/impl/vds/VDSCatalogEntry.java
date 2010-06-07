//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 14, 2007
 */
package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.datacatalog.query.CatalogEntry;

import java.util.AbstractCollection;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class VDSCatalogEntry extends CatalogEntry {
    private List<org.griphyn.vdl.annotation.Tuple> tuples;
    
    protected void setTuples(List<org.griphyn.vdl.annotation.Tuple> tuples) {
        this.tuples = tuples; 
    }
    
    public Object getTupleValue(String key) {
    	for (org.griphyn.vdl.annotation.Tuple t : tuples) {
    		if (t.getKey().equals(key)) {
    			return t.getValue();
    		}
    	}
    	return null; 
    }
    
    public void setTupleValue(String key, Object value) {
    	for (org.griphyn.vdl.annotation.Tuple t : tuples) {
    		if (t.getKey().equals(key)) {
    			t.setValue(value);
    			return; 
    		}
    	}
    }
    
    public Iterator<gov.fnal.elab.datacatalog.Tuple> tupleIterator() {
        return new It(tuples.iterator());
    }
    
    public AbstractCollection<org.griphyn.vdl.annotation.Tuple> getTuples() {
        return new Col();
    }
    
    public void sort() { 
    	Collections.sort(tuples, new VDSTupleComparator()); 
    }
    
    class Col extends AbstractCollection<org.griphyn.vdl.annotation.Tuple> {
    	@Override 
        public boolean isEmpty() {
            return tuples.isEmpty();
        }

    	@Override
        public Iterator iterator() {
            return new It(tuples.iterator());
        }

    	@Override
        public int size() {
            return tuples.size();
        }
    }
    
    class It implements Iterator<gov.fnal.elab.datacatalog.Tuple> {
        private java.util.Iterator<org.griphyn.vdl.annotation.Tuple> it;
        
        public It(Iterator it) {
            this.it = it;
        }

        public boolean hasNext() {
            return it.hasNext();
        }

        public gov.fnal.elab.datacatalog.Tuple next() {
        	org.griphyn.vdl.annotation.Tuple t = (org.griphyn.vdl.annotation.Tuple) it.next();
            return new gov.fnal.elab.datacatalog.Tuple(t.getKey(), t.getValue());
        }

        public void remove() {
            it.remove();
        }
    }

}
