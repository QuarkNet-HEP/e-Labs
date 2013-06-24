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
import java.awt.RenderingHints;
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

import org.apache.commons.codec.digest.*; 

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.LogarithmicAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
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
            	//EPeronja-06/24/2013: png exists but thumbnail doesn't and the code was ignoring that
                if (!fplot.exists() || !fthm.exists()) {
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
        
        /* Parse binWidth; temporarily disable since it seems to not be working :(
        if (options.containsKey("binwidth")) {
        	binWidth = Double.parseDouble(options.get("binwidth"));
        }
        */ 
        
        boolean logx = "true".equals(options.get("logx"));
        boolean logy = "true".equals(options.get("logy"));

        XYSeriesCollection col = new XYSeriesCollection();
        for (int i = 0; i < histograms.size(); i++) {
            Leaf leaf = leaves.get(i);
            System.out.println("plotting " + leaf.getId());
            Map<Integer, Integer> h = histograms.get(i);
            XYSeries s = new XYSeries("");
            List<Integer> l = new ArrayList<Integer>(h.keySet());
            Collections.sort(l);
            int lasty = 0;
            //EPeronja-06/11/2013: View thumbnail: do no assume that l.size() > 0!!!!!
            if (l.size() > 0) {
	            for (int bin = l.get(0); bin <= l.get(l.size() - 1); bin++) {
	                double x = bin * binWidth;
	                if (x < minx || x > maxx) {
	                    continue;
	                }
	                Integer y = h.get(bin);
	                if (y == null) {
	                    continue;
	                }
	                s.add(x - 0.0001, lasty);
	                s.add(x, y);
	                s.add(x + binWidth - 0.0001, y);
	                lasty = y;
	            }
            }//end of checking l.size()
            col.addSeries(s);
        }
        JFreeChart chart = ChartFactory.createXYLineChart("", "", "", col,
                PlotOrientation.VERTICAL, false, false, false);
        for (int i = 0; i < histograms.size(); i++) {
            XYItemRenderer r = ((XYPlot) chart.getPlot()).getRenderer();
            r.setSeriesPaint(i, COLORS.get(opts.get(i).get("color").toLowerCase()));
            r.setSeriesStroke(i, new BasicStroke(4.0f));
        }
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
        
        ChartUtilities.saveChartAsPNG(fplot, chart, 769, 380);
        BufferedImage src = ImageIO.read(fplot);
        int thmh = 100;
        int thml = 200;
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
    	return DigestUtils.md5Hex((VERSION + dataset.getName() + runs + plot).getBytes());
    }
}
