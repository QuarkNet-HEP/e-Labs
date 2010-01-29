/*
 * Created on Jan 12, 2010
 */
package gov.fnal.elab.expression.data.engine;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

public class FakeDataEngine implements DataEngine {

    public DataSet get(DataPath path, Range range, Options options) {
        return new FakeDataSet(path, range, options);
    }

    public static final Range R = new Range(Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);

    public static List<DataPath> PATHS = Arrays.asList(new DataPath[] { new DataPath("const", R),
            new DataPath("arctan", R), new DataPath("sine", R) });

    static {
        Method[] ms = Math.class.getMethods();
        for (int i = 0; i < ms.length; i++) {
            if (ms[i].getModifiers() == Method.PUBLIC && ms[i].getParameterTypes().length == 1
                    && ms[i].getParameterTypes()[0] == double.class) {
                PATHS.add(new DataPath(ms[i].getName(), R));
            }
        }
    }

    public List<DataPath> getPaths() {
        return PATHS;
    }

    private static class FakeDataSet extends AbstractDataSet {
        private enum functionType {
            SINE, CONST, ARCTAN, OTHER
        };

        private DataPath path;
        private int samples;
        private Range xrange, yrange;
        private Unit xunit, yunit;
        private final functionType type;

        private Method method;

        public FakeDataSet(DataPath path, Range range, Options options) {
            this.path = path;

            if ("const".equals(path)) {
                type = functionType.CONST;
            }
            else if ("arctan".equals(path)) {
                type = functionType.ARCTAN;
            }
            else if ("sine".equals(path)) {
                type = functionType.SINE;
            }
            else {
                type = functionType.OTHER;
                try {
                    method = Math.class.getMethod(path.getName(), new Class[] { double.class });
                }
                catch (NoSuchMethodException nsme) {
                    throw new IllegalArgumentException("The specified function \"" + path
                            + "\" does not exist in java.lang.Math.");
                }
                catch (SecurityException e) {
                    throw new IllegalArgumentException("The specified function \"" + path
                            + "\" has triggered a SecurityException.");
                }
                catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException(
                        "You must only use functions specifying one argument of type double.");
                }
            }
            this.samples = options.getSamples();
            if (this.samples < 1) {
                throw new IllegalArgumentException("Sample size needs to be at least one.");
            }
            xrange = range;
            yrange = new Range(-10.0, 10.0);
            xunit = new MetricUnit("s");
            yunit = new MetricUnit("m");
        }

        public String getLabel() {
            return path.getName();
        }

        public Number getX(int index) {
            return index * xrange.getRange().doubleValue() / samples;
        }

        public int getIndex(Number x) {
            return (int) ((x.doubleValue() - xrange.getStart().doubleValue()) * samples / xrange.getRange()
                .doubleValue());
        }

        public Range getXRange() {
            return xrange;
        }

        public Unit getXUnit() {
            return xunit;
        }

        public Number getY(int index) {
            switch (type) {
                case CONST:
                    return 10;
                case ARCTAN:
                    return 10 * Math.atan(getX(index).doubleValue() / 10);
                case SINE:
                    return 10 * Math.sin(getX(index).doubleValue() / 10);
                default:
                    try {
                        return (Number) method.invoke(path, getX(index).doubleValue());
                    }
                    catch (Exception e) {
                        return 0;
                    }
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
