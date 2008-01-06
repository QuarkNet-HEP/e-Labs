//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Mar 14, 2007
 */
package gov.fnal.elab.datacatalog.impl.vds;

import gov.fnal.elab.datacatalog.Tuple;
import gov.fnal.elab.datacatalog.query.CatalogEntry;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;

public class VDSCatalogEntry extends CatalogEntry {
    private List tuples;
    
    protected void setTuples(List tuples) {
        this.tuples = tuples;
    }

    public Object getTupleValue(String key) {
        Iterator i = tuples.iterator();
        while (i.hasNext()) {
            org.griphyn.vdl.annotation.Tuple t = (org.griphyn.vdl.annotation.Tuple) i.next();
            if (t.getKey().equals(key)) {
                return t.getValue();
            }
        }
        return null;
    }
    
    public void setTupleValue(String key, Object value) {
        Iterator i = tuples.iterator();
        while (i.hasNext()) {
            org.griphyn.vdl.annotation.Tuple t = (org.griphyn.vdl.annotation.Tuple) i.next();
            if (t.getKey().equals(key)) {
                t.setValue(value);
            }
        }
    }
    
    public Iterator tupleIterator() {
        return new It(tuples.iterator());
    }
    
    public Collection getTuples() {
        return new Col();
    }
    
    class Col implements Collection {

        public boolean add(Object o) {
            throw new UnsupportedOperationException();
        }

        public boolean addAll(Collection c) {
            throw new UnsupportedOperationException();
        }

        public void clear() {
            throw new UnsupportedOperationException();
        }

        public boolean contains(Object o) {
            throw new UnsupportedOperationException();
        }

        public boolean containsAll(Collection c) {
            throw new UnsupportedOperationException();
        }

        public boolean isEmpty() {
            return tuples.isEmpty();
        }

        public Iterator iterator() {
            return new It(tuples.iterator());
        }

        public boolean remove(Object o) {
            throw new UnsupportedOperationException();
        }

        public boolean removeAll(Collection c) {
            throw new UnsupportedOperationException();
        }

        public boolean retainAll(Collection c) {
            throw new UnsupportedOperationException();
        }

        public int size() {
            return tuples.size();
        }

        public Object[] toArray() {
            throw new UnsupportedOperationException();
        }

        public Object[] toArray(Object[] a) {
            throw new UnsupportedOperationException();
        }
    }
    
    class It implements Iterator {
        private java.util.Iterator it;
        
        public It(Iterator it) {
            this.it = it;
        }

        public boolean hasNext() {
            return it.hasNext();
        }

        public Object next() {
            org.griphyn.vdl.annotation.Tuple t = 
                (org.griphyn.vdl.annotation.Tuple) it.next();
            return new Tuple(t.getKey(), t.getValue());
        }

        public void remove() {
            it.remove();
        }
    }
}
