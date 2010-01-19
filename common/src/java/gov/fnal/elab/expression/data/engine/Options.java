/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class Options {
    private int samples;
    
    public Options() {
        samples = 1024;
    }
    
    public Options setSamples(int samples) {
        this.samples = samples;
        return this;
    }

    public int getSamples() {
        return samples;
    }
}
