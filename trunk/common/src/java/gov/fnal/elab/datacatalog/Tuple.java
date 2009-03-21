/*
 * Created on Mar 23, 2007
 */
package gov.fnal.elab.datacatalog;

public class Tuple {
    private final String key;
    private final Object value;
    
    public Tuple(String key, Object value) {
        this.key = key;
        this.value = value;
    }

    public String getKey() {
        return key;
    }

    public Object getValue() {
        return value;
    }
}
