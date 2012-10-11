/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.Tuple;

import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.Collection;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * This class implements a single entry returned by a data catalog query
 * function.
 */
public abstract class CatalogEntry implements Iterable<Tuple> {
    private String lfn;

    /**
     * Returns the value of a metadata entry for this entry with the specified
     * key.
     * 
     * @param key
     *            The metadata key
     * @return The corresponding metadata entry value
     */
    public abstract Object getTupleValue(String key);

    /**
     * Allows setting a metadata entry for this <code>CatalogEntry</code>.
     * Implementations are not required to commit such changes to the backing
     * store. Instead the metadata entry will be kept in memory and committed
     * using {@link DataCatalogProvider.insert}.
     */
    public abstract void setTupleValue(String key, Object value);

    /**
     * Returns an iterator that can be used to go over all the metadata tuples
     * in this <code>CatalogEntry</code>. Each item returned by the
     * {@link Iterator.next} method is of type {@link Tuple}.
     */
    public abstract Iterator<Tuple> tupleIterator();

    /**
     * To make JSP EL happy. This method is equivalent to {@link tupleIterator}.
     */
    public Iterator<Tuple> getTupleIterator() {
        return tupleIterator();
    }
    
    public Iterator<Tuple> iterator() {
    	return tupleIterator(); 
    }

    public abstract Collection<?> getTuples();

    public Map<String, Object> getTupleMap() {
        return new AbstractMap<String, Object>() {
            public Set<Entry<String, Object>> entrySet() {
                return new AbstractSet<Entry<String, Object>>() {
                    public Iterator<Entry<String, Object>> iterator() {
                        final Iterator<Tuple> i = tupleIterator();
                        return new Iterator<Entry<String, Object>>() {
                            public boolean hasNext() {
                                return i.hasNext();
                            }

                            public Entry<String, Object> next() {
                                final Tuple t = i.next();
                                return new Entry<String, Object>() {
                                    public String getKey() {
                                        return t.getKey();
                                    }

                                    public Object getValue() {
                                        return t.getValue();
                                    }

                                    public Object setValue(Object value) {
                                        throw new UnsupportedOperationException("setValue");
                                    }
                                };
                            }

                            public void remove() {
                                throw new UnsupportedOperationException(
                                        "remove");
                            }
                        };
                    }

                    public int size() {
                        return getTuples().size();
                    }
                };
            }
        };
    }

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
        Iterator<Tuple> i = tupleIterator();
        while (i.hasNext()) {
            Tuple t = i.next();
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
    
    public static class KEY_COMPARATOR_DESCENDING extends KEY_COMPARATOR {
		public KEY_COMPARATOR_DESCENDING(String key) {
			super(key, true);
		}
    }
    
    public static class KEY_COMPARATOR_ASCENDING extends KEY_COMPARATOR {
    	public KEY_COMPARATOR_ASCENDING(String key) {
    		super(key, false);
    	}
    }
    
    private static class KEY_COMPARATOR implements Comparator<CatalogEntry> {
        private String key;
        private boolean descending;
        
        public KEY_COMPARATOR(String key, boolean descending) {
        	this.key = key; 
        	this.descending = true; 
        }

		@SuppressWarnings("unchecked")
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
                        if (v1 instanceof Comparable<?>) {
                            c = ((Comparable<Object>) v1).compareTo(v2);
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
