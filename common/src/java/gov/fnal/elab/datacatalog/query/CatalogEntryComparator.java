package gov.fnal.elab.datacatalog.query;

import java.util.Comparator;

public class CatalogEntryComparator implements Comparator<CatalogEntry> {
    private String key;
    private boolean descending;
    
    public CatalogEntryComparator(String key, boolean descending) {
        this.key = key;
        this.descending = descending;
    }

    public int compare(CatalogEntry e1, CatalogEntry e2) {
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