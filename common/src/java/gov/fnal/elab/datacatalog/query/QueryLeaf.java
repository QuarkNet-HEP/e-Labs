/*
 * Created on Mar 13, 2007
 */
package gov.fnal.elab.datacatalog.query;

public abstract class QueryLeaf implements QueryElement {
    private final int type;
    private String key;
    private Object value1;
    private Object value2; 
    
    public QueryLeaf(int type, String key, Object value) {
        this(type, key, value, null);
    }
    
    public QueryLeaf(int type, String key, Object value1, Object value2) {
    	this.type = type;
        this.key = key;
        this.value1 = value1;
    	this.value2 = value2; 
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public Object getValue() {
        return this.getValue1();
    }
    
    public Object getValue1() {
    	return value1;
    }
    
    public Object getValue2() {
    	return value2; 
    }

    public void setValue(Object value) {
        setValue1(value);
    }
    
    public void setValue1(Object value) {
    	this.value1 = value; 
    }
    
    public void setValue2(Object value) {
    	this.value2 = value; 
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
        sb.append(value1);
        if (value2 != null) {
        	sb.append(", ");
            sb.append(value2);
        }
        sb.append(')');
        return sb.toString();
    }
}
