<%@ page import="gov.fnal.elab.ligo.data.chart.XYLineChartAdapter" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.ligo.data.engine.*" %>
<%@ page import="gov.fnal.elab.ligo.data.json.*"%>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.googlecode.charts4j.*" %>

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
	
	//fn=getData&channels=H0:PEM-EX_SEISX.rms&startTime=820260469.9171033&endTime=841752175.4160292
	
	String CHANNEL = "H0:PEM-EX_SEISX.rms";
	double STARTTIME = 820260469, ENDTIME = 841752175;
	
	NumberArrayDataSet nads = (NumberArrayDataSet) de.get(new DataPath(CHANNEL), new Range(STARTTIME, ENDTIME), new Options().setSamples(SAMPLES_PER_REQUEST));
	
	XYLineChart chart = XYLineChartAdapter.newXYLineChart(nads); 
%>

<%= chart.toURLString() %>
