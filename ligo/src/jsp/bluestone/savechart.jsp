<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.ligo.data.engine.*" %>
<%@ page import="gov.fnal.elab.ligo.data.json.*"%>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="org.jfree.*" %>
<%@ page import="org.jfree.chart.*" %>
<%@ page import="org.jfree.chart.axis.*" %>
<%@ page import="org.jfree.chart.plot.*" %>
<%@ page import="org.jfree.data.xy.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
	/* What to do:
	   1. Generate a chart
	   3. Write out metadata to VDS and save file to the right place [requires login]
	*/

	/* Chart data parameters */ 
	String channelParam = request.getParameter("channels");
	String startTimeParam = request.getParameter("startTime");
	String endTimeParam = request.getParameter("endTime");
	
	/* Metadata title parameter */ 
	String titleParam = request.getParameter("title"); 
	
	if (channelParam == null || startTimeParam == null || endTimeParam == null) {
		response.sendError(HttpServletResponse.SC_BAD_REQUEST, "missing channels, startTime or endTime parameters");
	}
	else { 
		String[] channels = null;
		String title = null; 
		double startTime = -1.0, endTime = -1.0; 
		int width = 600, height = 600; 
		try {
			channels = channelParam.split(","); 
			startTime = Double.parseDouble(startTimeParam);
			endTime = Double.parseDouble(endTimeParam);
		}
		catch (NumberFormatException nfe) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "could not understand either the startTime or endTime parameters");
			return; 
		}
		try {
			width = Integer.parseInt(request.getParameter("width"));
		}
		catch(NumberFormatException nfe) { 
			// don't care, use default. 
		}
		try {
			height = Integer.parseInt(request.getParameter("height"));
		}
		catch(NumberFormatException nfe) { 
			// don't care, use default. 
		}
		title = request.getParameter("title");

		DateFormat df = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss zzz");
		NumberFormat nf = new DecimalFormat("00.0000");
		Date gpsepoch = df.parse("01/06/1980 00:00:00 GMT");
		
		int CHUNK_SIZE = 1000000;
		int SAMPLING_INTERVAL = 60;
		int SAMPLES_PER_CHUNK = 16667;
		int SAMPLES_PER_REQUEST = 600;
		
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
			
		final double GPSCONVERSION = 315964787.0; 
		String unit = null; 
		double XMin, XMax;
		
		XYSeriesCollection xyDataset = new XYSeriesCollection();
		for (String channel : channels) {
			NumberArrayDataSet ds = (NumberArrayDataSet) de.get(new DataPath(channel), new Range(startTime, endTime), new Options().setSamples(SAMPLES_PER_REQUEST));
			XYSeries dataSeries = new XYSeries(channel);
			unit = ds.getYUnit().toString();
			
			for (int i=0; i < ds.size(); ++i) {
				dataSeries.add(
					Double.isNaN(ds.getX(i).doubleValue()) ? null : (ds.getX(i).doubleValue() + GPSCONVERSION) * 1000.0 , 
					ds.getY(i)
				);
			}
			xyDataset.addSeries(dataSeries);
		}
		
		if (title == null) {
			title = "LIGO Seismic Data for Channels " ;
			title += StringUtils.join(channels, ", ");
		}
		
	    NumberAxis na = new NumberAxis(unit);
	    DateAxis da = new DateAxis("Date"); 
	    
	    da.setRange((startTime + GPSCONVERSION) * 1000, (endTime + GPSCONVERSION) * 1000);
	    na.setAutoRangeIncludesZero(false);
	    
	    JFreeChart chart = ChartFactory.createXYLineChart(title, "Date-time", "Unit", xyDataset, PlotOrientation.VERTICAL, true, false, false );
	    chart.getXYPlot().setDomainAxis(da); 
	    chart.getXYPlot().setRangeAxis(na);
	    
	    /* Save the chart */  
		ElabGroup group = user.getGroup();
		
		String groupName = user.getGroup().getName();
		String plotDir = user.getDir("plots");
		
		GregorianCalendar gc = new GregorianCalendar();
	    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
	    String date = sdf.format(gc.getTime());

	    String dstFile = "savedimage-" + groupName + "-" + date + ".png";
	    String dstThumb = "savedimage-" + groupName + "-" + date + "_thm.png";
	    
	    File chartFile = new File(plotDir, dstFile);
	    File chartThumbnailFile = new File(plotDir, dstThumb); 
	    ChartUtilities.saveChartAsPNG(chartFile, chart, width, height);
	    ChartUtilities.saveChartAsPNG(chartThumbnailFile, chart, 150, 150);
		
		/* Write the metadata */ 
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		List<String> meta = new ArrayList();
		
		meta.add("city string " + group.getCity());
		meta.add("group string " + group.getName());
		meta.add("name string " + title);
		meta.add("project string " + elab.getName());
		meta.add("school string " + group.getSchool());
		meta.add("state string " + group.getState());
		meta.add("teacher string " + group.getTeacher());
		meta.add("year string " + group.getYear());
		meta.add("thumbnail string " + dstThumb);
		meta.add("filename string " + dstFile);
		meta.add("GPS_start_time string " + startTimeParam);
		meta.add("GPS_end_time string " + endTimeParam);
		meta.add("channel string " + channelParam); 
		meta.add("type string plot"); 
		meta.add("creationdate date " + (new Timestamp(System.currentTimeMillis())).toString()); 
		meta.add("analysis string superbluestone-advanced"); 
		
		dcp.insert(DataTools.buildCatalogEntry(dstFile, meta));
	}

%>
	