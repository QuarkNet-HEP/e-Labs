/*
 * Created on Jan 13, 2010
 */
package gov.fnal.elab.expression.evaluator.functions;

import gov.fnal.elab.expression.data.engine.DataSet;

public class Value {
    public static final int DATASET = 0;
    public static final int NUMBER = 1;
    public static final int STRING = 2;
    
    private Object value;
    private int type;
    
    public Value(int type, Object value) {
        this.type = type;
        this.value = value;
    }
    
    public Value(String val) {
        this(STRING, val);
    }
    
    public Value(Number val) {
        this(NUMBER, val);
    }
    
    public Value(DataSet val) {
        this(DATASET, val);
    }
    
    public String getStringValue() {
        if (type != STRING) {
            throw new TypeException(value + " is not a string");
        }
        else {
            return (String) value;
        }
    }
    
    public Number getNumericValue() {
        if (type != NUMBER) {
            throw new TypeException(value + " is not a number");
        }
        else {
            return (Number) value;
        }
    }
    
    public DataSet getDataSetValue() {
        if (type != DATASET) {
            throw new TypeException(value + " is not a dataset");
        }
        else {
            return (DataSet) value;
        }
    }
    
    public Object getValue() {
        return value;
    }
    
    public static String niceType(int type) {
        switch (type) {
            case NUMBER: return "Number";
            case STRING: return "String";
            case DATASET: return "Dataset";
            default: return "?";
        }
    }

    public int getType() {
        return type;
    }
}
