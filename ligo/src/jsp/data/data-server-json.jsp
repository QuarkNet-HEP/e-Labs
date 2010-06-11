<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.ligo.data.engine.*" %>
<%@ page import="gov.fnal.elab.ligo.data.json.*"%>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.google.gson.*" %>

<%@ page contentType="application/json" %>

<%
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
	
	LIGOFileDataEngine de;
	synchronized(session) {
		de = (LIGOFileDataEngine) session.getAttribute("de");
		if (de == null) {
		    de = LIGOFileDataEngine.getEngine("/disks/i2u2-dev/ligo/data/streams", 
		            ServiceLIGOFileReader.getFactory("http://data2:8100"));
		    session.setAttribute("de", de);
		}
	}
	
	String fn = request.getParameter("fn");
	if (fn == null || fn.equals("")) {
		out.write("Error: missing function");
	}
	else if (fn.equals("getChannels")) {
		/* Call with data-server.jsp?fn=getChannels */
	    List<DataPath> paths = de.getPaths();
	    Gson gson = new Gson();
	    out.write(gson.toJson(paths));
	}
	else if (fn.equals("getTimeRange")) {
		/* Call with data-server.jsp?fn=getTimeRange */
		/* TODO: Fix this so it isn't slow. The speed is unacceptable for the first load. 
	    List<DataPath> paths = de.getPaths();
	    double min = Double.MAX_VALUE, max = Double.MIN_VALUE;
	    for (DataPath dp : paths) {
	    	try {
		        if (dp.getTotalRange().getStart().doubleValue() < min) {
		            min = dp.getTotalRange().getStart().doubleValue();
		        } 	        
		        if (dp.getTotalRange().getEnd().doubleValue() > max) {
		            max = dp.getTotalRange().getEnd().doubleValue();
		        }
	    	}
	    	catch(NullPointerException nfe) {
	    		// do nothing if the data is missing start/end data. 
	    	}
	    }
	    */
	    
	    // Temporarily hardcode this for SPEED. Need fixing
	    final double min = 730922400.0; 
	    final double max = 949814519.0; 
	    JsonObject jo = new JsonObject();
	    jo.addProperty("minTime", min);
	    jo.addProperty("maxTime", max);
	    out.write(jo.toString());
	}
	else if (fn.equals("getData")) {
		/* Call with data-server.jsp?fn=getData&channels=foo,bar,zed&startTime=e&endTime=e */
		
		List<String> exceptionList = new ArrayList();
				
		if (StringUtils.isBlank(request.getParameter("channels"))) {
			exceptionList.add("Please specify a channel to lookup"); 
		}
		if (StringUtils.isBlank(request.getParameter("startTime"))) {
			exceptionList.add("Please specify a start time");
		}
		if (StringUtils.isBlank(request.getParameter("endTime"))) {
			exceptionList.add("Please specify an end time");
		}
				
		if (exceptionList.size() > 0) {
			// write out exception log 
		}
		else { 
			String[] channels = request.getParameter("channels").split(",");
			double startTime = Double.parseDouble(request.getParameter("startTime"));
			double endTime = Double.parseDouble(request.getParameter("endTime"));
			
			GsonBuilder gb = new GsonBuilder();
			gb.registerTypeAdapter(NumberArrayDataSet.class, new GPSConvertingJSMillisDataSetSerializer());
			Gson gson = gb.serializeNulls().create();
			
			Collection<DataSet> dataList = new ArrayList(); 
			for(String channel : channels) {
				try {
					NumberArrayDataSet nads = (NumberArrayDataSet) de.get(new DataPath(channel), new Range(startTime, endTime), new Options().setSamples(SAMPLES_PER_REQUEST));
					dataList.add(nads);
				}
				catch(Exception e) {
					// the data doesn't exist, don't add it. Flag user
					exceptionList.add(channel + " doesn't exist");
				}
			}
			out.write(gson.toJson(dataList).replaceAll("NaN", "null"));
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