/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class MetricUnit extends Unit {
    private final String base;
    
    public MetricUnit(String base) {
        this(base, false);
    }
    
    public MetricUnit(String base, boolean logarithmic) {
        super(logarithmic);
        this.base = base;
    }

    public String format(Number n) {
        return n + " " + base;
    }

    @Override
    public Unit log() {
        return new MetricUnit(base, true);
    }

    @Override
    public String toString() {
        return base + " " + (isLogarithmic() ? "(log)" : "");
    }
}
