/*
 * Created on Sep 3, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import java.util.List;

public interface Fitter {
    public class Entry {
        public final double x, y;
        
        public Entry(double x, double y) {
            this.x = x;
            this.y = y;
        }
    }

    void fit(List<Entry> l, double[] guess);

    double getParameter(int index);
}
