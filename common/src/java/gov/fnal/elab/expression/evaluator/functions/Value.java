/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataSet;

public class Value {
    public static enum Types { 
    	DATASET(0), 
    	NUMBER(1), 
    	STRING(2);
    	
    	public final int value; 
    	
    	Types(int value) {
    		this.value = value; 
    	}
    	
    	public int value() { return value; }
    }; 
    
    private Object value;
    private Types type;
    
    public Value(Types type, Object value) {
        this.type = type;
        this.value = value;
    }
    
    public Value(String val) {
        this(Types.STRING, val);
    }
    
    public Value(Number val) {
        this(Types.NUMBER, val);
    }
    
    public Value(DataSet val) {
        this(Types.DATASET, val);
    }
    
    public String getStringValue() {
        if (type != Types.STRING) {
            throw new TypeException(value + " is not a string");
        }
        else {
            return (String) value;
        }
    }
    
    public Number getNumericValue() {
        if (type != Types.NUMBER) {
            throw new TypeException(value + " is not a number");
        }
        else {
            return (Number) value;
        }
    }
    
    public DataSet getDataSetValue() {
        if (type != Types.DATASET) {
            throw new TypeException(value + " is not a dataset");
        }
        else {
            return (DataSet) value;
        }
    }
    
    public Object getValue() {
        return value;
    }
    
    public static String niceType(Types type) {
        switch (type) {
            case NUMBER: return "Number";
            case STRING: return "String";
            case DATASET: return "Dataset";
            default: return "?";
        }
    }

    public Types getType() {
        return type;
    }
}
