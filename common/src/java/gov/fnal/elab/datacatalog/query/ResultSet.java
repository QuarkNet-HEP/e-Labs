/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

public class ResultSet implements Collection {
    public static final ResultSet EMPTY_RESULT_SET = new ResultSet();

    private List entries;

    public ResultSet() {
        entries = new ArrayList();
    }

    public Iterator iterator() {
        return entries.iterator();
    }

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
    
    public String[] getLfnArray() {
        String[] lfna = new String[entries.size()];
        for (int i = 0; i < lfna.length; i++) {
            lfna[i] = ((CatalogEntry) entries.get(i)).getLFN();
        }
        return lfna;
    }
}
