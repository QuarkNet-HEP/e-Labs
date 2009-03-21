/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

/**
 * This class implements the default {@link Collection} returned by data catalog
 * query functions. Each element in the {@link Collection} is a
 * {@link CatalogEntry}.
 */
public class ResultSet implements Collection {
    public static final ResultSet EMPTY_RESULT_SET = new ResultSet();

    private List entries;

    /**
     * Constructs an empty <code>ResultSet</code>
     */
    public ResultSet() {
        entries = new ArrayList();
    }

    /**
     * Returns an {@link Iterator} for this <code>ResultSet</code>.
     */
    public Iterator iterator() {
        return entries.iterator();
    }

    /**
     * Adds an entry to this <code>ResultSet</code>
     * 
     * @param e
     *            A {@link CatalogEntry} to be added to this
     *            <code>ResultSet</code>
     * @return <code>true</code> to unnecessarily conform to the
     *         {@link Collection.add} method contract.
     */
    public boolean addEntry(CatalogEntry e) {
        return entries.add(e);
    }

    public boolean isEmpty() {
        return entries.isEmpty();
    }

    public boolean add(Object o) {
        return addEntry((CatalogEntry) o);
    }

    public boolean addAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public void clear() {
        entries.clear();
    }

    public boolean contains(Object o) {
        return entries.contains(o);
    }

    public boolean containsAll(Collection c) {
        throw new UnsupportedOperationException();
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
        return entries.size();
    }

    public Object[] toArray() {
        throw new UnsupportedOperationException();
    }

    public Object[] toArray(Object[] a) {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns an array of logical file names extracted from all the entries in
     * this <code>ResultSet</code>.
     */
    public String[] getLfnArray() {
        String[] lfna = new String[entries.size()];
        for (int i = 0; i < lfna.length; i++) {
            lfna[i] = ((CatalogEntry) entries.get(i)).getLFN();
        }
        return lfna;
    }
    
    public void sort(String key, boolean descending) {
        Collections.sort(entries, new EntryComparator(key, descending));
    }
    
    private static class EntryComparator implements Comparator {
        private String key;
        private boolean descending;
        
        public EntryComparator(String key, boolean descending) {
            this.key = key;
            this.descending = descending;
        }

        public int compare(Object o1, Object o2) {
            CatalogEntry e1 = (CatalogEntry) o1;
            CatalogEntry e2 = (CatalogEntry) o2;
            Object v1 = e1.getTupleValue(key);
            Object v2 = e2.getTupleValue(key);
            int c;
            //null < !null
            if (v1 == null) {
                if (v2 == null) {
                    c = 0;
                }
                else {
                    c = 1;
                }
            }
            else {
                if (v2 == null) {
                    c = -1;
                }
                else {
                    if (!v1.getClass().equals(v2.getClass())) {
                        throw new RuntimeException("Tuple type error");
                    }
                    else {
                        if (v1 instanceof Comparable) {
                            c = ((Comparable) v1).compareTo(v2);
                        }
                        else {
                            c = System.identityHashCode(v2) - System.identityHashCode(v1);
                        }
                    }
                }
            }
            if (descending) {
                c = -c;
            }
            return c;
        }
    }
}
