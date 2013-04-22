<%@ page import="java.util.*"
         import="java.io.*"
		 import="java.text.*"
		 import="gov.fnal.elab.ligo.data.engine.*"
		 import="gov.fnal.elab.ligo.data.json.*"
		 import="gov.fnal.elab.expression.data.engine.*"
		 import="org.apache.commons.lang.*"
		 import="com.google.gson.*" %>

<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
	if (user != null) { // require login to access data 
		response.setContentType("application/json");
	
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
			    de = LIGOFileDataEngine.getEngine("/disks/i2u2/ligo/data/streams", 
			            ServiceLIGOFileReader.getFactory("http://localhost:8100"));
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
		    final double max = 1022544015.0;
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

				Collection<DataSet> dataList = new ArrayList(); 
				for(String channel : channels) {
					try {
						NumberArrayDataSet nads = (NumberArrayDataSet) de.get(new DataPath(channel), new Range(startTime, endTime), new Options().setSamples(SAMPLES_PER_REQUEST));
						dataList.add(nads);
					}
					catch(Exception e) {
						String msg = e.toString();
						// the data doesn't exist, don't add it. Flag user
						exceptionList.add(channel + " doesn't exist");
					}
				}
				
				String format = request.getParameter("format");
				
				if (format == null || format.equals("")) {
					format = "JSON";
				}
				
				if (format.equals("JSON")) {
					GsonBuilder gb = new GsonBuilder();
					gb.registerTypeAdapter(NumberArrayDataSet.class, new GPSConvertingJSMillisDataSetSerializer());
					Gson gson = gb.serializeNulls().create();
					out.write(gson.toJson(dataList).replaceAll("NaN", "null"));
				}
				else if (format.equals("text")) {
					for (DataSet ds : dataList) {
	        			out.write("# label: ");out.write(ds.getLabel());out.write("\n");
	        			out.write("# xlabel: ");out.write(ds.getXLabel());out.write("\n");
	        			out.write("# ylabel: ");out.write(ds.getYLabel());out.write("\n");
	        			out.write("# xunit: ");out.write(String.valueOf(ds.getXUnit()));out.write("\n");
	        			out.write("# yunit: ");out.write(String.valueOf(ds.getYUnit()));out.write("\n");
	        			out.write("# xrange: ");out.write(String.valueOf(ds.getXRange()));out.write("\n");
	        			out.write("# yrange: ");out.write(String.valueOf(ds.getYRange()));out.write("\n");
	        			out.write("# size: ");out.write(String.valueOf(ds.size()));out.write("\n");
	        			out.write("#\n");
	        			for (int i = 0; i < ds.size(); i++) {
				            out.write(String.valueOf(ds.getX(i)));
				            out.write("\t");
				            Number n = ds.getY(i);
				            if (!(n instanceof Double) || !Double.isNaN((Double) n)) {
				            	out.write(String.valueOf(n));
				            }
				            out.write("\n");
				        }
				        out.write("\n\n");
				    }
				}
				else {
					out.write("Error: invalid format");
				}
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
	}
%>
