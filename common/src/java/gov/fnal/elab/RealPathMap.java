/*
 * Created on Jan 25, 2008
 */
package gov.fnal.elab;

import java.io.File;
import java.util.Collection;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletContext;

public class RealPathMap implements Map {
    private Elab elab;
    private ServletContext context;
    
    public RealPathMap(Elab elab, ServletContext context) {
        this.elab = elab;
        this.context = context;
    }

    public void clear() {
        throw new UnsupportedOperationException();
    }

    public boolean containsKey(Object key) {
        return true;
    }

    public boolean containsValue(Object value) {
        if (value instanceof String) {
            return new File((String) value).exists();
        }
        else {
            return false;
        }
    }

    public Set entrySet() {
        throw new UnsupportedOperationException();
    }

    public Object get(Object key) {
        return context.getRealPath("/" + elab.getName() + "/" + key);
    }

    public boolean isEmpty() {
        return false;
    }

    public Set keySet() {
        throw new UnsupportedOperationException();
    }

    public Object put(Object key, Object value) {
        throw new UnsupportedOperationException();
    }

    public void putAll(Map t) {
        throw new UnsupportedOperationException();
    }

    public Object remove(Object key) {
        throw new UnsupportedOperationException();
    }

    public int size() {
        return 0;
    }

    public Collection values() {
        throw new UnsupportedOperationException();
    }
}
