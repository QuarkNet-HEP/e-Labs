/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

public abstract class QueryLeaf implements QueryElement {
    private final int type;
    private String key;
    private Object value;
    
    public QueryLeaf(int type, String key, Object value) {
        this.type = type;
        this.key = key;
        this.value = value;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public Object getValue() {
        return value;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    public int getType() {
        return type;
    }
    
    public boolean isLeaf() {
        return true;
    }
    
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append(NAMES[type]);
        sb.append('(');
        sb.append(key);
        sb.append(", ");
        sb.append(value);
        sb.append(')');
        return sb.toString();
    }
}
