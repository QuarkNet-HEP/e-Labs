/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public abstract class Unit {
    private final boolean logarithmic;
    
    protected Unit(boolean logarithmic) {
        this.logarithmic = logarithmic;
    }
    
    public abstract String format(Number n);

    public boolean isLogarithmic() {
        return logarithmic;
    }

    public abstract Unit log();
}
