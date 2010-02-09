<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.ligo.data.engine.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>

<%
	File datadir = new File("/home/mike/work/i2u2/ligo/data/trend/minute-trend/RAW/");

	DateFormat df = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss zzz");
	NumberFormat nf = new DecimalFormat("0000.00");
	Date gpsepoch = df.parse("01/06/1980 00:00:00 GMT");
	
	int CHUNK_SIZE = 1000000;
	int SAMPLING_INTERVAL = 60;
	int SAMPLES_PER_CHUNK = 16667;
	int SAMPLES_PER_REQUEST = 1200;
	
	SortedMap sm = new TreeMap();
	sm.put(new Long(0), null);
	
	Map m = (Map) session.getAttribute("dc");
	if (m == null) {
	    m = new HashMap();
	    session.setAttribute("dc", m);
	}
	
	LIGOFileDataEngine de = (LIGOFileDataEngine) session.getAttribute("de");
	if (de == null) {
	    de = new LIGOFileDataEngine("/mnt/ubuntu/tmp/test/");
	    //de = new LIGOFileDataEngine("/mnt/ubuntu/tmp/funny/");
	    session.setAttribute("de", de);
	}
	
	    
	String fn = request.getParameter("fn");
	String params = request.getParameter("params");
	if (fn == null || fn.equals("")) {
		out.write("Error: missing function");
	}
	else if (fn.equals("getChannels")) {
	    List<DataPath> paths = de.getPaths();
	    for (DataPath p : paths) {
	        out.write(p.getName());
	        out.write(" ");
	    }
	}
	else if (fn.equals("getTimeRange")) {
	    List<DataPath> paths = de.getPaths();
	    double min = Double.MAX_VALUE, max = Double.MIN_VALUE;
	    for (DataPath dp : paths) {
	        if (dp.getTotalRange().getStart().doubleValue() < min) {
	            min = dp.getTotalRange().getStart().doubleValue();
	        }
	        
	        if (dp.getTotalRange().getEnd().doubleValue() > max) {
	            max = dp.getTotalRange().getEnd().doubleValue();
	        }
	    }
		out.write(nf.format(min));
		out.write(" ");
		out.write(nf.format(max));
	}
	else if (fn.equals("getData")) {
		String[] p = params.split(",");
		String channel = p[0];
		double start = Double.parseDouble(p[2]);
		double end = Double.parseDouble(p[3]);
		
		out.write(p[1]);
		out.write(" ");
		
		DataSet ds = de.get(new DataPath(channel), new Range(start, end), new Options().setSamples(SAMPLES_PER_REQUEST));
		for (int i = 0; i < ds.size(); i++) {
			out.write(ds.getX(i).toString());
			out.write(" ");
			out.write(ds.getY(i).toString());
			out.write(" ");
		}
	}
	else if (fn.equals("convolve")) {
	    Double[] p = new Double[0];
	    Double[] d0 = (Double[]) ((ArrayList) m.get("0")).toArray(p);
	    Double[] d1 = (Double[]) ((ArrayList) m.get("1")).toArray(p);
	    double s;
	    for(int j = - d0.length / 2; j < d0.length / 2; j++) {
	        s = 0;
	    	for(int i = 0; i < d0.length; i++) {
	    	    if (i + j < d0.length && i + j > 0) {
	    	        s += d0[i].doubleValue() * d1[i + j].doubleValue();
	    	    }
	    	}
	    	out.write(s + " ");
	    }
	}
	else if (fn.equals("ft")) {
	    Double[] p = new Double[0];
		Double[] d0 = (Double[]) ((ArrayList) m.get("0")).toArray(p);
		double s;
		for (int i = 6; i < d0.length; i++) {
		    double sc = (double) i / d0.length;
		    s = 0;
		    for (int j = 0; j < d0.length; j++) {
		        s += d0[j].doubleValue() * Math.sin(sc * j);
		        //s = Math.sin(sc * j);
		    }
		    out.write(s + " ");
		}
	}
%>