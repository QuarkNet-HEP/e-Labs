/*
 * Created on Sep 3, 2009
 */
package gov.fnal.elab.cosmic.estimation;

import static java.lang.Math.log;

import java.util.List;

public class LinearMinLogSquaredNewtonFitter implements Fitter {
    
    private double a, b;

    public void fit(List<Entry> l, double[] guess) {
        long start = System.currentTimeMillis();
        double a = guess[0];
        double b = guess[1];
        if (a <= 0) {
            a = 0.1;
        }
        if (b < 1) {
            b = 1;
        }
        double lerr = 0;
        PrecomputedCoefficients pc = precomputeCoefficients(l, a, b);
        double err = calcErrors(pc);
        int k = 0;

        while ((Math.abs(err - lerr) > 0.000001 || k < 3) && k < 100) {
            Vec2 F = new Vec2(dfda(l, pc), dfdb(l, pc));

            double d2fdadb = d2fdadb(l, pc);

            Matrix2x2 J = new Matrix2x2(
                    d2fdada(l, pc), d2fdadb, 
                    d2fdadb, d2fdbdb(l, pc)
            );

            Vec2 dP = J.inverse().times(F);

            a = a - dP.v1;
            b = b - dP.v2;

            k++;
            lerr = err;
            pc = precomputeCoefficients(l, a, b);
            err = calcErrors(pc);
        }
        System.out.println((System.currentTimeMillis() - start) + " ms, " + k + " steps");
        this.a = a;
        this.b = b;
    }

    private PrecomputedCoefficients precomputeCoefficients(List<Entry> l, double a, double b) {
        PrecomputedCoefficients pc = new PrecomputedCoefficients(l.size());
        for (int i = 0; i < l.size(); i++) {
            Entry e = l.get(i);
            pc.f[i] = e.x * a + b;
            pc.logresidue[i] = log(e.y / pc.f[i]);
            pc.fsquared[i] = pc.f[i] * pc.f[i];
        }
        return pc;
    }

    private double calcErrors(PrecomputedCoefficients pc) {
        double e = 0;
        for (int i = 0; i < pc.size; i++) {
            e += pc.logresidue[i] * pc.logresidue[i];
        }
        return e;
    }

    private double dfda(List<Entry> l, PrecomputedCoefficients pc) {
        double s = 0;
        for (int i = 0; i < pc.size; i++) {
            s += l.get(i).x / pc.f[i] * pc.logresidue[i];
        }
        return -s * 2;
    }

    private double dfdb(List<Entry> l, PrecomputedCoefficients pc) {
        double s = 0;
        for (int i = 0; i < pc.size; i++) {
            s += 1 / pc.f[i] * pc.logresidue[i];
        }
        return -s * 2;
    }

    private double d2fdada(List<Entry> l, PrecomputedCoefficients pc) {
        double s = 0;
        for (int i = 0; i < pc.size; i++) {
            double x = l.get(i).x;
            s += x * x / pc.fsquared[i] * (1 + pc.logresidue[i]);
        }
        return s * 2;
    }

    private double d2fdadb(List<Entry> l, PrecomputedCoefficients pc) {
        double s = 0;
        for (int i = 0; i < pc.size; i++) {
            s += l.get(i).x / pc.fsquared[i] * (1 + pc.logresidue[i]);
        }
        return s * 2;
    }

    private double d2fdbda(List<Entry> l, PrecomputedCoefficients pc) {
        return d2fdadb(l, pc);
    }

    private double d2fdbdb(List<Entry> l, PrecomputedCoefficients pc) {
        double s = 0;
        for (int i = 0; i < pc.size; i++) {
            s += 1 / pc.fsquared[i] * (1 + pc.logresidue[i]);
        }
        s = s * 2;
        return s;
    }

    public double getParameter(int index) {
        if (index == 1) {
            return a;
        }
        else if (index == 2) {
            return b;
        }
        else {
            throw new IllegalArgumentException();
        }
    }

    private static class Matrix2x2 {
        private double a11, a12, a21, a22;
        
        public Matrix2x2(double a11, double a12, double a21, double a22) {
            this.a11 = a11;
            this.a12 = a12;
            this.a21 = a21;
            this.a22 = a22;
        }
        
        public Matrix2x2 inverse() {
            double det = determinant();
            return new Matrix2x2(
                a22 / det, -a21 / det,
                -a12 /det, a11 / det
            );
        }
        
        public double determinant() {
            return a11 * a22 - a12 * a21;
        }
        
        public Vec2 times(Vec2 v) {
            return new Vec2(
                a11 * v.v1 + a12 * v.v2,
                a21 * v.v1 + a22 * v.v2
            );
        }
        
        public String toString() {
            return "[" + a11 + " " + a12 + "]\n[" + a21 + " " + a22 + "]";  
        }
    }

    private static class Vec2 {
        private double v1, v2;

        public Vec2(double v1, double v2) {
            this.v1 = v1;
            this.v2 = v2;
        }
        
        public String toString() {
            return "[" + v1 + ", " + v2 + "]";
        }
    }

    private static class PrecomputedCoefficients {
        double f[], logresidue[], fsquared[];
        int size;

        public PrecomputedCoefficients(int size) {
            this.size = size;
            f = new double[size];
            logresidue = new double[size];
            fsquared = new double[size];
        }
    }
}
