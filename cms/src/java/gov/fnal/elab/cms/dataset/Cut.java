/*
 * Created on Jul 30, 2010
 */
package gov.fnal.elab.cms.dataset;

public class Cut implements Comparable<Cut> {
    private final double min, max;
    private final String leaf, label, units;

    public Cut(String leaf, String units, String label, double min, double max) {
        this.min = min;
        this.max = max;
        this.leaf = leaf;
        this.label = label;
        this.units = units;
    }

    public double getMin() {
        return min;
    }

    public double getMax() {
        return max;
    }

    public String getLeaf() {
        return leaf;
    }

    public String getLabel() {
        return label;
    }
    
    public String getUnits() {
        return units;
    }

    public String toString() {
        return min + ":" + max + ":" + leaf + ":" + units + ":" + label;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Cut) {
            Cut other = (Cut) obj;
            return min == other.min && max == other.max && leaf.equals(other.leaf);
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return (int) (Double.doubleToLongBits(min) + Double.doubleToLongBits(max) + leaf.hashCode());
    }

    @Override
    public int compareTo(Cut o) {
        int lc = leaf.compareTo(o.leaf);
        if (lc != 0) {
            return lc;
        }
        lc = sgn(min - o.min);
        if (lc != 0) {
            return lc;
        }
        return sgn(max - o.max);
    }

    private int sgn(double d) {
        if (d > 0) {
            return 1;
        }
        else if (d < 0) {
            return -1;
        }
        else {
            return 0;
        }
    }
}