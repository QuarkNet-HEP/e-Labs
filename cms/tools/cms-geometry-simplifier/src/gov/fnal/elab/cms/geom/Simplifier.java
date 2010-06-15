//----------------------------------------------------------------------
//This code is developed as part of the Java CoG Kit project
//The terms of the license can be found at http://www.cogkit.org/license
//This message may not be removed or altered.
//----------------------------------------------------------------------

/*
 * Created on Jun 5, 2010
 */
package gov.fnal.elab.cms.geom;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.JsonParser.Feature;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.map.SerializationConfig;
import org.codehaus.jackson.node.ArrayNode;
import org.codehaus.jackson.node.ObjectNode;

public class Simplifier {
    public static final boolean modelOnly = true;

    public static void main(String[] args) {
        try {
            new Simplifier().run(args[0], args[1]);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run(String input, String output) throws Exception {
        ObjectMapper im = new ObjectMapper();
        im.configure(Feature.ALLOW_SINGLE_QUOTES, true);
        JsonNode iRoot = im.readValue(new ParenFixerInputStream(input), JsonNode.class);
        JsonNode iCol = iRoot.path("Collections");

        ObjectMapper om = new ObjectMapper();
        ObjectNode oRoot = om.createObjectNode();
        ObjectNode oCol = oRoot.putObject("Collections");

        processTracker(iCol, oCol);
        processEcalBarrel(iCol, oCol);
        processEcalEndcaps(iCol, oCol);
        makeEcalPreshower(iCol, oCol);
        copyData(iCol, oCol, "HcalBarrel3D", false);
        copyData(iCol, oCol, "HcalEndcap3D", false);
        copyData(iCol, oCol, "HcalOuter3D", false);
        copyData(iCol, oCol, "HcalForward3D", false);
        processDriftTubes(iCol, oCol);
        copyData(iCol, oCol, "CSC3D", false);
        processRPCs(iCol, oCol);

        om.configure(SerializationConfig.Feature.INDENT_OUTPUT, true);
        om.writeValue(new File(output), oRoot);
    }

    private void processEcalEndcaps(JsonNode iCol, ObjectNode oCol) {
        JsonNode iEcalEndcap = iCol.path("EcalEndcap3D_V1");
        ArrayNode oModelEcalEndcap = oCol.putArray("EcalEndcap3D_MODEL");
        ArrayNode oModelEndcapArray = oModelEcalEndcap.addArray();
        ArrayNode oEcalEndcap = oCol.putArray("EcalEndcap3D_VS");

        Wireframe w = new Wireframe();
        
        ArrayList<Integer> l = new ArrayList<Integer>();
        double lastx = 0;
        int lasti = 0;
        int rate = 0;
        for (int i = 0; i < iEcalEndcap.size(); i++) {
            JsonNode b1 = iEcalEndcap.get(i);
            double x = getPoint(b1, 1).get(0).getDoubleValue();
            if (Math.abs(x - lastx) > 0.01) {
                lastx = x;
                if (i - lasti != rate) {
                    l.add(lasti);
                    rate = i - lasti;
                }
                lasti = i;
            }
            
            if (!modelOnly) {
                JsonNode first = iEcalEndcap.get(i);
                add(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(first, 3), getPoint(first, 4), getPoint(first, 5), getPoint(first, 6),
                        getPoint(first, 7));
            }
        }

        int[] counts = new int[] { 0, 60, 120, 270, 570, 710, 1080, 1500 };
        for (int i = 0; i < counts.length - 1; i++) {
            JsonNode first = iEcalEndcap.get(counts[i]);
            JsonNode last = iEcalEndcap.get(counts[i + 1] - 1);
            addDiagonal(oModelEndcapArray, getPoint(first, 1), getPoint(last, 2));
        }
        
        w.dump(oEcalEndcap);
    }

    private void copyData(JsonNode iCol, ObjectNode oCol, String name, boolean force) {
        JsonNode in = iCol.path(name + "_V1");
        ArrayNode outModel = oCol.putArray(name + "_MODEL");
        ArrayNode out = oCol.putArray(name + "_VS");
        outModel.add(true);
        Wireframe w = new Wireframe();

        if (!modelOnly || force) {
            for (int i = 0; i < in.size(); i++) {
                JsonNode first = in.get(i);
                add(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(first, 3), getPoint(first, 4), getPoint(first, 5), getPoint(first, 6),
                        getPoint(first, 7));
            }
        }
        w.dump(out);
    }
    
    private class Point implements Comparable<Point> {
        public double x, y, z;
        private Double mag;
     
        public Point(double x, double y, double z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        
        public double distance(Point p) {
            return Math.sqrt(square(p.x - x) + square(p.y - y) + square(p.z - z));
        }
        
        public double mag() {
            if (mag == null) {
                mag = Math.sqrt(square(x) + square(y) + square(z));
            }
            return mag;
        }

        private double square(double d) {
            return d * d;
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Point) {
                Point op = (Point) obj;
                return distance(op) < 0.0002;
            }
            else {
                return false;
            }
        }
        
        public int hashCode() {
            return (int) Double.doubleToLongBits(mag());
        }

        @Override
        public int compareTo(Point o) {
            return sgn(mag() - o.mag());
        }
        
        public int sgn(double d) {
            if (d > 0) {
                return 1;
            }
            if (d < 0) {
                return -1;
            }
            return 0;
        }

        public void dump(ArrayNode points) {
            ArrayNode pts = points.addArray();
            pts.add(x);
            pts.add(y);
            pts.add(z);
        }
    }
    
    private class Line {
        public int p1, p2;
        
        public Line(int p1, int p2) {
            this.p1 = p1;
            this.p2 = p2;
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Line) {
                Line l = (Line) obj;
                return p1 == l.p1 && p2 == l.p2;
            }
            else {
                return false;
            }
        }

        @Override
        public int hashCode() {
            return p1 * 10000 + p2;
        }

        public void dump(ArrayNode lines) {
            ArrayNode pts = lines.addArray();
            pts.add(p1);
            pts.add(p2);
        }
        
        
    }
    
    private class Wireframe {
        public Map<Point, Integer> points;
        public SortedMap<Integer, Point> spoints;
        public Set<Line> lines;
        
        public Wireframe() {
            points = new HashMap<Point, Integer>();
            spoints = new TreeMap<Integer, Point>();
            lines = new HashSet<Line>();
        }
        
        public int addPoint(Point p) {
            Integer i = points.get(p);
            if (i == null) {
                i = points.size();
                points.put(p, i);
                spoints.put(i, p);
            }
            return i;
        }
        
        public void addLine(Point p1, Point p2) {
            lines.add(new Line(addPoint(p1), addPoint(p2)));
        }
        
        public void dump(ArrayNode out) {
            ArrayNode a = out.addArray();
            ArrayNode points = a.addArray();
            ArrayNode lines = a.addArray();

            for (Map.Entry<Integer, Point> e : this.spoints.entrySet()) {
                e.getValue().dump(points);
            }
            for (Line l : this.lines) {
                l.dump(lines);
            }
            System.out.println("Dumped " + spoints.size() + " points and " + lines.size() + " lines");
        }
    }

    private void processRPCs(JsonNode iCol, ObjectNode oCol) {
        JsonNode in = iCol.path("RPC3D_V1");
        ArrayNode outModel = oCol.putArray("RPC3D_MODEL");
        ArrayNode out = oCol.putArray("RPC3D_VS");
        Wireframe w = new Wireframe();
        Wireframe wm = new Wireframe();

        for (int i = 0; i < in.size(); i++) {
            if (i < 1020) {
                JsonNode first = in.get(i);
                addQuad(wm, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(first, 3), 1);
            }
            if (!modelOnly) {
                JsonNode first = in.get(i);
                addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(first, 3), 1);
            }
        }
        w.dump(out);
        wm.dump(outModel);
    }

    private void processDriftTubes(JsonNode iCol, ObjectNode oCol) {
        JsonNode iDTs = iCol.path("DTs3D_V1");
        ArrayNode oModelDTs = oCol.putArray("DTs3D_MODEL");
        ArrayNode oDTs = oCol.putArray("DTs3D_VS");
        
        Wireframe w = new Wireframe();
        Wireframe wm = new Wireframe();

        for (int i = 0; i < iDTs.size(); i++) {
            JsonNode first = iDTs.get(i);
            if (!modelOnly) {
                addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(first, 3), 1);
                addQuad(w, getPoint(first, 4), getPoint(first, 5), getPoint(first, 6),
                        getPoint(first, 7), 1);
            }
            // these are too weird to do manually
            addQuad(wm, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                    getPoint(first, 3), 1);
            addQuad(wm, getPoint(first, 4), getPoint(first, 5), getPoint(first, 6),
                    getPoint(first, 7), 1);
        }
        w.dump(oDTs);
        wm.dump(oModelDTs);
    }

    private void processEcalBarrel(JsonNode iCol, ObjectNode oCol) {
        JsonNode iEcalBarrel = iCol.path("EcalBarrel3D_V1");
        ArrayNode oModelEcalBarrel = oCol.putArray("EcalBarrel3D_MODEL");
        ArrayNode oEcalBarrel = oCol.putArray("EcalBarrel3D_VS");

        Wireframe w = new Wireframe();
        // internal radius is the same all over
        ArrayNode v = oModelEcalBarrel.addArray();
        v.add(mag(getPoint(iEcalBarrel.get(0), 0)));
        ArrayNode pos = v.addArray();
        ArrayNode fradii = v.addArray();
        ArrayNode ahpos = v.addArray();

        ArrayList<Double[]> spos = new ArrayList<Double[]>();
        ArrayList<Double> hpos = new ArrayList<Double>();

        JsonNode leftend = null;
        JsonNode rightend = null;
        int ringSkip = 5;
        for (int section = 0; section < 170 / ringSkip; section++) {
            int fsection = (section * ringSkip) * 360;
            int esection = (section * ringSkip + ringSkip - 1) * 360;
            JsonNode b1 = null;
            JsonNode b4 = null;
            for (int i = 0; i < 360 / 4; i++) {
                int p = i * 4;
                b1 = iEcalBarrel.get(fsection + p);
                JsonNode b2 = iEcalBarrel.get(fsection + p + 3);
                JsonNode b3 = iEcalBarrel.get(esection + p + 3);
                b4 = iEcalBarrel.get(esection + p);
                if (!modelOnly) {
                    addQuad(w, getPoint(b1, 2), getPoint(b2, 1), getPoint(b3, 0),
                            getPoint(b4, 3), 1);
                    addQuad(w, getPoint(b1, 6), getPoint(b2, 5), getPoint(b3, 4),
                            getPoint(b4, 7), 1);
                }
            }
            leftend = b4;
            if (section == 80 / ringSkip) {
                rightend = b4; 
            }
            spos.add(new Double[] { mag(getPoint(b1, 6)),
                    getPoint(b1, 6).get(2).getDoubleValue() });
            hpos.add(getPoint(b1, 2).get(2).getDoubleValue());
        }
        spos.add(new Double[] { mag(getPoint(leftend, 6)),
                getPoint(leftend, 6).get(2).getDoubleValue() });
        hpos.add(getPoint(leftend, 2).get(2).getDoubleValue());
        if (rightend != null) {
            spos.add(new Double[] { mag(getPoint(rightend, 6)),
                    getPoint(rightend, 6).get(2).getDoubleValue() });
            hpos.add(getPoint(rightend, 2).get(2).getDoubleValue());
        }
        Collections.sort(spos, new Comparator<Double[]>() {
            @Override
            public int compare(Double[] o1, Double[] o2) {
                double v = o1[1] - o2[1];
                if (v < 0) {
                    return -1;
                }
                else if (v > 0) {
                    return 1;
                }
                else {
                    return 0;
                }
            }
        });
        Collections.sort(hpos);
        for (Double[] d : spos) {
            fradii.add(d[0]);
            pos.add(d[1]);
        }
        for (Double d : hpos) {
            ahpos.add(d);
        }
        w.dump(oEcalBarrel);
    }
    
    private void makeEcalPreshower(JsonNode iCol, ObjectNode oCol) {
        ArrayNode oModelPreshower = oCol.putArray("EcalPreshower3D_MODEL");
        oModelPreshower.add(true);
    }

    private void processTracker(JsonNode iCol, ObjectNode oCol) {
        JsonNode iTracker = iCol.path("Tracker3D_V1");
        ArrayNode oModelTracker = oCol.putArray("Tracker3D_MODEL");
        oModelTracker.add(true);
        ArrayNode oTracker = oCol.putArray("Tracker3D_VS");
        
        Wireframe w = new Wireframe();

        if (modelOnly) {
            return;
        }
        int TR1 = 96 * 8;
        // TR1 = 1410;
        int TR2 = 1440;
        int TR3 = 4164;
        int TR4 = 4980;
        int TR5 = iTracker.size();
        for (int set = 0; set < TR1 / 8; set++) {
            int index = set * 8;
            JsonNode first = iTracker.get(index);
            JsonNode last = iTracker.get(index + 7);
            addQuad(w, getPoint(first, 0), getPoint(last, 1), getPoint(last, 2),
                    getPoint(first, 3), 0);
        }
        {
            int g = TR1 / 4 / 24;
            for (int c = 0; c < 5; c++) {
                for (int o = 0; o < 24; o++) {
                    int index = g * 4 * 24 + c * 24 * 7 + o * 4;
                    JsonNode first = iTracker.get(index);
                    JsonNode last = iTracker.get(index + 3);
                    addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(last,
                            2), getPoint(last, 3), 0);
                }
                for (int o = 0; o < 24; o++) {
                    int index = g * 4 * 24 + c * 24 * 7 + 4 * 24 + o * 3;
                    JsonNode first = iTracker.get(index);
                    JsonNode last = iTracker.get(index + 2);
                    addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(last,
                            2), getPoint(last, 3), 0);
                }
            }
        }
        int cnt = 0;
        boolean flag = true;
        for (int set = TR2 / 6; set < TR3 / 6; set++) {
            int index = set * 6;
            JsonNode first = iTracker.get(index);
            JsonNode last = iTracker.get(index + 4);
            if (flag) {
                addQuad(w, getPoint(first, 0), getPoint(last, 1), getPoint(last, 2),
                        getPoint(first, 3), 0);
            }
            else {
                addQuad(w, getPoint(last, 0), getPoint(first, 1), getPoint(first, 2),
                        getPoint(last, 3), 0);
            }
            if (cnt == 25) {
                flag = false;
            }
            if (cnt == 81) {
                flag = true;
            }
            if (cnt == 111) {
                flag = false;
            }
            if (cnt == 145) {
                flag = true;
            }
            if (cnt == 217) {
                flag = false;
            }
            if (cnt > 254) {
                break;
            }
            cnt++;
        }
        for (int g = TR3; g < TR4; g++) {
            int index = g;
            JsonNode first = iTracker.get(index);
            addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                    getPoint(first, 3), 1);
        }
        for (int g = TR4; g < TR5; g++) {
            int index = g;
            JsonNode first = iTracker.get(index);
            addQuad(w, getPoint(first, 0), getPoint(first, 1), getPoint(first, 2),
                    getPoint(first, 3), 1);
        }
        w.dump(oTracker);
    }

    private double mag(JsonNode point) {
        double x = point.get(0).getDoubleValue();
        double y = point.get(1).getDoubleValue();
        return Math.sqrt(x * x + y * y);
    }

    private void addQuad(ArrayNode n, JsonNode point1, JsonNode point2, JsonNode point3,
            JsonNode point4, int intensity) {
        ArrayNode q = n.addArray();
        q.add(point1);
        q.add(point2);
        q.add(point3);
        q.add(point4);
    }
    
    private void addQuad(Wireframe w, JsonNode point1, JsonNode point2, JsonNode point3,
            JsonNode point4, int intensity) {
        Point p1 = makePoint(point1);
        Point p2 = makePoint(point2);
        Point p3 = makePoint(point3);
        Point p4 = makePoint(point4);
        w.addLine(p1, p2);
        w.addLine(p2, p3);
        w.addLine(p3, p4);
        w.addLine(p4, p1);
    }
    
    private void add(Wireframe w, JsonNode point1, JsonNode point2, JsonNode point3,
            JsonNode point4, JsonNode point5, JsonNode point6, JsonNode point7,
            JsonNode point8) {
        Point p1 = makePoint(point1);
        Point p2 = makePoint(point2);
        Point p3 = makePoint(point3);
        Point p4 = makePoint(point4);
        Point p5 = makePoint(point5);
        Point p6 = makePoint(point6);
        Point p7 = makePoint(point7);
        Point p8 = makePoint(point8);
        w.addLine(p1, p2);
        w.addLine(p2, p3);
        w.addLine(p3, p4);
        w.addLine(p4, p1);
        
        w.addLine(p5, p6);
        w.addLine(p6, p7);
        w.addLine(p7, p8);
        w.addLine(p8, p5);
        
        w.addLine(p1, p5);
        w.addLine(p2, p6);
        w.addLine(p3, p7);
        w.addLine(p4, p8);
    }
    
    private Point makePoint(JsonNode p) {
        return new Point(p.get(0).getDoubleValue(), p.get(1).getDoubleValue(), p.get(2).getDoubleValue());
    }

    private void addDiagonal(ArrayNode n, JsonNode point1, JsonNode point2) {
        ArrayNode q = n.addArray();
        q.add(point1);
        q.add(point2);
    }

    private JsonNode getPoint(JsonNode n, int i) {
        return n.get(i + 1);
    }
}
