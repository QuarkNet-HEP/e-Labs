/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import java.util.AbstractCollection;
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
public class ResultSet extends AbstractCollection<CatalogEntry> {
    public static final ResultSet EMPTY_RESULT_SET = new ResultSet();

    private List<CatalogEntry> entries;

    /**
     * Constructs an empty <code>ResultSet</code>
     */
    public ResultSet() {
        entries = new ArrayList<CatalogEntry>();
    }

    /**
     * Returns an {@link Iterator} for this <code>ResultSet</code>.
     */
    public Iterator<CatalogEntry> iterator() {
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

    public boolean add(CatalogEntry e) {
        return addEntry(e);
    }

    public boolean addAll(Collection<? extends CatalogEntry> c) {
        return entries.addAll(c);
    }

    public void clear() {
        entries.clear();
    }

    public boolean contains(CatalogEntry e) {
        return entries.contains(e);
    }

    public int size() {
        return entries.size();
    }

    /**
     * Returns an array of logical file names extracted from all the entries in
     * this <code>ResultSet</code>.
     */
    public String[] getLfnArray() {
        String[] lfna = new String[entries.size()];
        for (int i = 0; i < lfna.length; i++) {
            lfna[i] = entries.get(i).getLFN();
        }
        return lfna;
    }
    
    public void sort(String key, boolean descending) {
        Collections.sort(entries, new CatalogEntryComparator(key, descending));
    }
    
    public void sort(String key) {
    	this.sort(key, true);
    }
      
}
