/*
 * Created on Apr 19, 2007
 */
package org.griphyn.common.catalog.replica;

import gov.fnal.elab.RawDataFileResolver;

import java.io.File;
import java.util.AbstractSet;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Properties;
import java.util.Set;

import org.griphyn.common.catalog.ReplicaCatalog;
import org.griphyn.common.catalog.ReplicaCatalogEntry;

public class ElabRC implements ReplicaCatalog {
    private static ThreadLocal dataDir = new ThreadLocal();
    
    public static void setDataDir(String dataDir) {
         ElabRC.dataDir.set(dataDir);
    }
    
    public static String getDataDir() {
        return (String) ElabRC.dataDir.get();
    }
    
    private boolean closed;
    private Map map;
    
    public ElabRC() {
        closed = true;
        map = new HashMap();
    }

    public int clear() {
        return 0;
    }

    public int delete(Map x, boolean matchAttributes) {
        map.keySet().removeAll(x.keySet());
        return map.size();
    }

    public int delete(String lfn, String pfn) {
        map.remove(lfn);
        return map.size();
    }

    public int delete(String lfn, ReplicaCatalogEntry tuple) {
        return 0;
    }

    public int delete(String lfn, String name, Object value) {
        return 0;
    }

    public int deleteByResource(String lfn, String handle) {
        return 0;
    }

    public int insert(Map x) {
        return 0;
    }

    public int insert(String lfn, ReplicaCatalogEntry tuple) {
        return 0;
    }

    public int insert(String lfn, String pfn, String handle) {
        return 0;
    }

    public Set list() {
        return null;
    }

    public Set list(String constraint) {
        return null;
    }
    
    private String lfnToPfn(String lfn) {
        File f = new File(RawDataFileResolver.getDefault().resolve(getDataDir(), lfn));
        if (f.exists()) {
            return f.getAbsolutePath();
        }
        else {
            return null;
        }
    }

    public Collection lookup(String lfn) {
        return lookupNoAttributes(lfn);
    }

    public Map lookup(Set lfns) {
        Map m = new HashMap();
        Iterator i = lfns.iterator();
        while (i.hasNext()) {
            String lfn = (String) i.next();
            m.put(lfn, lfnToPfn(lfn));
        }
        return m;
    }

    public Map lookup(Map constraints) {
        return null;
    }

    public String lookup(String lfn, String handle) {
        return lfnToPfn(lfn);
    }

    public Map lookup(Set lfns, String handle) {
        return lookup(lfns);
    }

    public Set lookupNoAttributes(String lfn) {
        return new OneElementSet(lfnToPfn(lfn));
    }

    public Map lookupNoAttributes(Set lfns) {
        return lookup(lfns);
    }

    public Map lookupNoAttributes(Set lfns, String handle) {
        return lookup(lfns);
    }

    public int remove(String lfn) {
        return 0;
    }

    public int remove(Set lfns) {
        return 0;
    }

    public int removeByAttribute(String handle) {
        return 0;
    }

    public int removeByAttribute(String name, Object value) {
        return 0;
    }

    public void close() {
        closed = true;
    }

    public boolean connect(Properties props) {
        closed = false;
        return true;
    }

    public boolean isClosed() {
        return closed;
    }

    public static class OneElementSet extends AbstractSet {
        private Object element;
        
        public OneElementSet(Object element) {
            this.element = element;
        }

        public Iterator iterator() {
            return new Iterator() {
                private boolean nextCalled; 

                public boolean hasNext() {
                    return !nextCalled;
                }

                public Object next() {
                    if (nextCalled) {
                        throw new NoSuchElementException();
                    }
                    return element;
                }

                public void remove() {
                    throw new UnsupportedOperationException();
                }                
            };
        }

        public int size() {
            return 1;
        }
    }
}
