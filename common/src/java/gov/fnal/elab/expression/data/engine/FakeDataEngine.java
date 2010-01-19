/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

public class FakeDataEngine implements DataEngine {
    
    public DataSet get(String path, Range range, Options options) {
        return new FakeDataSet(path, range, options);
    }
    
    private static class FakeDataSet extends AbstractDataSet {
        public static final int SINE = 0;
        public static final int CONST = 1;
        public static final int ARCTAN = 2;
        
        private String path;
        private int samples;
        private Range xrange, yrange;
        private Unit xunit, yunit;
        private final int type;
        
        public FakeDataSet(String path, Range range, Options options) {
            this.path = path;
            
            if ("const".equals(path)) {
                type = CONST;
            }
            else if ("arctan".equals(path)) {
                type = ARCTAN;
            }
            else {
                type = SINE;
            }
            this.samples = options.getSamples();
            if (this.samples == 0) {
                throw new IllegalArgumentException("Sample size cannot be zero");
            }
            xrange = range;
            yrange = new Range(-10.0, 10.0);
            xunit = new MetricUnit("s");
            yunit = new MetricUnit("m");
        }

        public String getLabel() {
            return path;
        }

        public Number getX(int index) {
            return index * xrange.getRange().doubleValue() / samples;
        }

        public int getIndex(Number x) {
            return (int) ((x.doubleValue() - xrange.getStart().doubleValue()) * samples / xrange.getRange().doubleValue());
        }
        
        public Range getXRange() {
            return xrange;
        }

        public Unit getXUnit() {
            return xunit;
        }

        public Number getY(int index) {
            switch(type) {
                case CONST:
                    return 10;
                case ARCTAN:
                    return 10*Math.atan(getX(index).doubleValue() / 10);
                default:
                    return 10*Math.sin(getX(index).doubleValue() / 10);
            }
        }

        public Range getYRange() {
            return yrange;
        }

        public Unit getYUnit() {
            return yunit;
        }

        public Number map(Number x) {
            return getY(getIndex(x));
        }

        public int size() {
            return samples;
        }

        public String getXLabel() {
            return "time";
        }

        public String getYLabel() {
            return "x";
        }
    }
}
