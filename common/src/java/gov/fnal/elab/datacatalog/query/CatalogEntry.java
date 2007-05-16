/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

import gov.fnal.elab.datacatalog.DataCatalogProvider;
import gov.fnal.elab.datacatalog.Tuple;

import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * This class implements a single entry returned by a data catalog query
 * function.
 */
public abstract class CatalogEntry {
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
    public abstract Iterator tupleIterator();

    /**
     * To make JSP EL happy. This method is equivalent to {@link tupleIterator}.
     */
    public Iterator getTupleIterator() {
        return tupleIterator();
    }

    public abstract Collection getTuples();

    public Map getTupleMap() {
        return new AbstractMap() {
            public Set entrySet() {
                return new AbstractSet() {
                    public Iterator iterator() {
                        final Iterator i = tupleIterator();
                        return new Iterator() {
                            public boolean hasNext() {
                                return i.hasNext();
                            }

                            public Object next() {
                                final Tuple t = (Tuple) i.next();
                                return new Map.Entry() {
                                    public Object getKey() {
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
