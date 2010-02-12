/*
 * Created on Jan 26, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class DataPath {
    private final String name;
    private final Range totalRange;
    
    public DataPath(String name) {
        this(name, null);
    }
    
    public DataPath(String name, Range totalRange) {
        this.name = name;
        this.totalRange = totalRange;
    }

    public String getName() {
        return name;
    }

    public Range getTotalRange() {
        return totalRange;
    }

    @Override
    public String toString() {
        return name + (totalRange == null ? "" : totalRange.toString());
    }
}
