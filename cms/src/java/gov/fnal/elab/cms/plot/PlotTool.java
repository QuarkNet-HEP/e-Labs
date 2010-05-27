/*
 * Created on May 26, 2010
 */
package gov.fnal.elab.cms.plot;

import gov.fnal.elab.Elab;
import gov.fnal.elab.cms.dataset.Dataset;
import gov.fnal.elab.cms.dataset.DatasetLoadException;
import gov.fnal.elab.cms.dataset.Leaf;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.RenderingHints;
import java.awt.Stroke;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.LogAxis;
import org.jfree.chart.axis.LogarithmicAxis;
import org.jfree.chart.plot.DefaultDrawingSupplier;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

public class PlotTool {
    public static final String VERSION = "0.2";
    
    public static File[] getOrCreatePlot(Elab elab, Dataset dataset, String runs, String plot)
            throws PlotException {
        try {
            String digest = getDigest(dataset, runs, plot);
            String path = elab.getProperty("plot.image.cache");
            File fplot = new File(path, digest + ".png");
            File fthm = new File(path, digest + "-thm.png");
            synchronized (PlotTool.class) {
                if (!fplot.exists()) {
                    createPlot(fplot, fthm, elab, dataset, runs, plot);
                }
            }
            return new File[] { fplot, fthm };
        }
        catch (Exception e) {
            throw new PlotException(e);
        }
    }

    private static void createPlot(File fplot, File fthm, Elab elab, Dataset dataset,
            String runs, String plot) throws IOException, DatasetLoadException {
        String[] plots = plot.split("\\s+");
        List<Map<Integer, Integer>> histograms = new ArrayList<Map<Integer, Integer>>();
        List<Leaf> leaves = new ArrayList<Leaf>();
        List<Map<String, String>> opts = new ArrayList<Map<String, String>>();
        double binWidth = 1;
        String path = null;
        for (String p : plots) {
            Map<String, String> options = parseOptions(p);
            opts.add(options);
            Map<Integer, Integer> histogram = new HashMap<Integer, Integer>();
            path = options.get("path");
            leaves.add(dataset.getLeaf(path));
            String[] pruns = runs.split("\\s+");
            for (String r : pruns) {
                loadData(histogram, binWidth, dataset, r, options.get("path"));
            }
            histograms.add(histogram);
        }
        createPlotImages(histograms, binWidth, fplot, fthm, leaves, opts);
    }

    private static void createPlotImages(List<Map<Integer, Integer>> histograms,
            double binWidth, File fplot,
            File fthm, List<Leaf> leaves, final List<Map<String, String>> opts)
            throws IOException {

        Map<String, String> options = opts.get(0);
        double minx = -Double.MAX_VALUE;
        double maxx = Double.MAX_VALUE;
        if (options.containsKey("maxx")) {
            maxx = Double.parseDouble(options.get("maxx"));
        }
        if (options.containsKey("minx")) {
            minx = Double.parseDouble(options.get("minx"));
        }
        Double maxy = null;
        if (options.containsKey("maxy")) {
            maxy = Double.parseDouble(options.get("maxy"));
        }
        
        boolean logx = "true".equals(options.get("logx"));
        boolean logy = "true".equals(options.get("logy"));

        XYSeriesCollection col = new XYSeriesCollection();
        for (int i = 0; i < histograms.size(); i++) {
            Leaf leaf = leaves.get(i);
            Map<Integer, Integer> h = histograms.get(i);
            XYSeries s = new XYSeries("");
            List<Integer> l = new ArrayList<Integer>(h.keySet());
            Collections.sort(l);
            int lasty = 0;
            for (int bin = l.get(0); bin <= l.get(l.size() - 1); bin++) {
                double x = bin * binWidth;
                if (x < minx || x > maxx) {
                    continue;
                }
                int y = h.get(bin);
                s.add(x - 0.0001, lasty);
                s.add(x, y);
                s.add(x + 0.9999, y);
                lasty = y;
            }
            col.addSeries(s);
        }
        JFreeChart chart = ChartFactory.createXYLineChart("", "", "", col,
                PlotOrientation.VERTICAL, false, false, false);
        chart.getPlot().setBackgroundPaint(Color.WHITE);
        chart.getPlot().setOutlineStroke(new BasicStroke(1.5f));
        if (logy) {
            LogarithmicAxis l = new LogarithmicAxis("");
            l.setStrictValuesFlag(false);
            chart.getXYPlot().setRangeAxis(l);
        }
        if (logx) {
            chart.getXYPlot().setDomainAxis(new LogarithmicAxis(""));
        }
        if (maxy != null) {
            if (logy) {
                chart.getXYPlot().getRangeAxis().setRange(1, maxy);
            }
            else {
                chart.getXYPlot().getRangeAxis().setRange(0, maxy);
            }
        }
        
        chart.getPlot().setDrawingSupplier(new DefaultDrawingSupplier() {
            int index = 0;

            @Override
            public Paint getNextPaint() {
                return COLORS.get(opts.get(index++).get("color").toLowerCase());
            }

            @Override
            public Stroke getNextStroke() {
                return new BasicStroke(4.0f);
            }
        });
        ChartUtilities.saveChartAsPNG(fplot, chart, 769, 380);
        BufferedImage src = ImageIO.read(fplot);
        int thmh = 150;
        int thml = 150;
        BufferedImage thm = new BufferedImage(thml, thmh, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = thm.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g
                .drawRenderedImage(src, AffineTransform.getScaleInstance(thml / 769.0,
                        thmh / 380.0));
        ImageIO.write(thm, "PNG", fthm);
    }

    public static final Map<String, Color> COLORS;

    static {
        COLORS = new HashMap<String, Color>();
        COLORS.put("black", Color.BLACK);
        COLORS.put("red", Color.RED);
        COLORS.put("green", Color.GREEN);
        COLORS.put("blue", Color.BLUE);
        COLORS.put("cyan", Color.CYAN);
        COLORS.put("magenta", Color.MAGENTA);
        COLORS.put("orange", Color.ORANGE);
    }

    private static void loadData(Map<Integer, Integer> histogram, double binWidth,
            Dataset dataset,
            String run, String path) throws IOException, DatasetLoadException {
        String file = dataset.getRunFiles().get(run);
        if (file == null) {
            throw new RuntimeException("Invalid run: " + run);
        }
        BufferedReader br = new BufferedReader(new FileReader(dataset.getDataLocation() + "/"
                + file + "/"
                    + path));
        try {
            String line = br.readLine();
            while (line != null) {
                if (!line.startsWith("#")) {
                    String[] g = line.split("\\s+");
                    if (g.length > 1) {
                        for (int i = 1; i < g.length; i++) {
                            addEvent(histogram, binWidth, g[i]);
                        }
                    }
                }
                line = br.readLine();
            }
        }
        finally {
            br.close();
        }
    }

    private static void addEvent(Map<Integer, Integer> histogram, double binWidth,
            String value) {
        double val = Double.parseDouble(value);
        int bin = (int) Math.floor(val / binWidth);
        Integer count = histogram.get(bin);
        if (count == null) {
            count = 1;
        }
        else {
            count = count + 1;
        }
        histogram.put(bin, count);
    }

    private static Map<String, String> parseOptions(String plot) {
        Map<String, String> opts = new HashMap<String, String>();

        String[] sp = plot.split(",");
        for (String s : sp) {
            String[] e = s.split(":", 2);
            opts.put(e[0], e[1]);
        }
        return opts;
    }

    private static String getDigest(Dataset dataset, String runs, String plot)
            throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("md5");
        byte[] sum = md.digest((VERSION + dataset.getName() + runs + plot).getBytes());
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < sum.length; i++) {
            byte b = sum[i];
            int ln = b & 0x0f;
            int hn = (b >>> 4) & 0x0f;
            sb.append((char) (hn > 9 ? hn - 10 + 'a' : hn + '0'));
            sb.append((char) (ln > 9 ? ln - 10 + 'a' : ln + '0'));
        }
        return sb.toString();
    }
}
