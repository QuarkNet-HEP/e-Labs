<%@page import="org.jfree.chart.axis.*,java.text.*"%><%@ page import="java.io.*,org.jfree.chart.encoders.*,org.jfree.chart.*,org.jfree.data.general.*,org.jfree.data.xy.*,org.jfree.data.*,java.util.*,javax.imageio.*" %><%

final int index = Integer.parseInt(request.getParameter("index"));
boolean large = "yes".equals(request.getParameter("large"));
List<List<Double>>  datav = (List<List<Double>>) session.getAttribute("calibration-datav");
List<List<Integer>>  datac = (List<List<Integer>>) session.getAttribute("calibration-datac");
List<SortedMap<Double, Integer>> cdata = (List<SortedMap<Double, Integer>>) session.getAttribute("calibration-data2");
final List<Double>[] keys = new List[2];
final List<Integer>[] values = new List[2];
for (int i = 0; i < 2; i++) {
    keys[i] = new ArrayList<Double>();
    values[i] = new ArrayList<Integer>();
}
if (datav != null) {
    for (int i = 0; i < datav.size(); i++) {
        keys[0].add(datav.get(i).get(index));
        values[0].add(datac.get(i).get(index));
    }
}
if (cdata != null) {
    Iterator<Map.Entry<Double, Integer>> it = cdata.get(index).entrySet().iterator();
    while (it.hasNext()) {
		Map.Entry<Double, Integer> e = it.next();
		keys[1].add(e.getKey());
		values[1].add(e.getValue());
    }
}

XYDataset ds = new IntervalXYDataset() {
    
    public DomainOrder getDomainOrder() {
        return DomainOrder.ASCENDING;
    }

    public int getItemCount(int series) {
        return keys[series].size();
    }
    
    public Number getStartX(int series, int item) {
		return keys[series].get(item);
	}
    
    public Number getEndX(int series, int item) {
		return keys[series].get(item);
	}
   
    public Number getX(int series, int item) {
		return keys[series].get(item);
	}

	public double getXValue(int series, int item) {
    	return keys[series].get(item);
	}
	
	public double getStartXValue(int series, int item) {
    	return keys[series].get(item);
	}
	
	public double getEndXValue(int series, int item) {
    	return keys[series].get(item);
	}

	public Number getY(int series, int item) {
		return values[series].get(item);
	}
	
	public Number getStartY(int series, int item) {
		double v = values[series].get(item);
		return v - Math.sqrt(v);
	}
	
	public Number getEndY(int series, int item) {
		double v = values[series].get(item);
		return v - Math.sqrt(v);
	}

	public double getYValue(int series, int item) {
    	return values[series].get(item);
	}
	
	public double getEndYValue(int series, int item) {
    	double v = values[series].get(item);
    	return v + Math.sqrt(v);
	}
	
	public double getStartYValue(int series, int item) {
    	double v = values[series].get(item);
    	return v - Math.sqrt(v);
	}
	
	public int indexOf(Comparable key) {
	    if ("Coincidence".equals(key)) {
	    	return 1;
	    }
	    else {
	     	return 0;   
	    }
    }

    public void addChangeListener(DatasetChangeListener l) {
    }

    public DatasetGroup getGroup() {
            return null;
    }

    public void removeChangeListener(DatasetChangeListener l) {
    }

    public void setGroup(DatasetGroup dg) {
    }

    public int getSeriesCount() {
		return 2;
    }

    public Comparable getSeriesKey(int series) {
            switch (series) {
                    case 0:
                            return "C " + (index + 1);
                    case 1:
                        	return "Coincidence";
                    default:
                            return "?";
            }
    }

};

JFreeChart chart = ChartFactory.createScatterPlot(null, "Voltage (v)", "Counts (cpm)", ds, org.jfree.chart.plot.PlotOrientation.VERTICAL, false, false, false);
org.jfree.chart.renderer.xy.XYErrorRenderer r = new org.jfree.chart.renderer.xy.XYErrorRenderer();
r.setAutoPopulateSeriesPaint(false);
r.setAutoPopulateSeriesShape(false);
r.setLinesVisible(true);
r.setSeriesPaint(0, java.awt.Color.BLUE);
r.setSeriesPaint(1, java.awt.Color.RED);
r.setBaseShape(new java.awt.Rectangle(-2, -1, 4, 2));
chart.getXYPlot().setRenderer(r);
chart.getXYPlot().setDomainAxis(new NumberAxis());
chart.getXYPlot().getDomainAxis().setLabel("Voltage (v)");
chart.getXYPlot().getDomainAxis().setLowerBound(0.4);
NumberAxis na = new NumberAxis();
na.setTickUnit(new NumberTickUnit(1, new DecimalFormat("0")), false, false);
na.setLabel("Counts (cpm)");
chart.getXYPlot().setRangeAxis(na);
KeypointPNGEncoderAdapter encoder = new KeypointPNGEncoderAdapter();
encoder.setEncodingAlpha(true);
int width = large ? 800 : 400;
int height = large ? 600 : 180;
byte[] b = encoder.encode(chart.createBufferedImage(width, height, java.awt.image.BufferedImage.BITMASK, null));
response.setContentType("image/png");
OutputStream os = response.getOutputStream();
os.write(b);
os.close();
%>