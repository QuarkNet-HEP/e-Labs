/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class Range {
    private final Number start, end;
    
    public Range(Number start, Number end) {
        this.start = start;
        this.end = end;
    }
    
    public Number getStart() {
        return start;
    }
    
    public Number getEnd() {
        return end;
    }
    
    @SuppressWarnings("unchecked")
    public Number getRange() {
        if (start instanceof Integer) {
            return new Integer(end.intValue() - start.intValue());
        }
        else if (start instanceof Double) {
            return new Double(end.doubleValue() - start.doubleValue());
        }
        else {
            throw new ClassCastException();
        }
    }

    @Override
    public String toString() {
        return "[" + start + ", " + end + "]";
    }
}
