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
	NumberFormat nf = new DecimalFormat("00.0000");
	Date gpsepoch = df.parse("01/06/1980 00:00:00 GMT");
	
	int CHUNK_SIZE = 1000000;
	int SAMPLING_INTERVAL = 60;
	int SAMPLES_PER_CHUNK = 16667;
	int SAMPLES_PER_REQUEST = 120;
	
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
	double STARTTIME = 833177533, ENDTIME = 835682226;
	
	NumberArrayDataSet ds = (NumberArrayDataSet) de.get(new DataPath(CHANNEL), new Range(STARTTIME, ENDTIME), new Options().setSamples(SAMPLES_PER_REQUEST));

	// simple adapter since I am lazy and don't wnat ot deal with charts4j right now
	
	String baseURL = "http://chart.apis.google.com/chart?cht=lxy&chs=550x250";
	
	List<Integer> tempListX = new ArrayList<Integer>();
	List<Double> tempListY = new ArrayList<Double>();
	for (int i=0; i < ds.size(); ++i) {
		tempListX.add(ds.getX(i).intValue());
		tempListY.add(ds.getY(i).doubleValue());
		
	}
	
	String xList = StringUtils.join(tempListX, ',');
	String yList = StringUtils.join(tempListY, ',');
	
	double min = Collections.min(tempListY);
	double max = Collections.max(tempListY);
	yList = yList.replaceAll("NaN", "_"); 
	
	String requestURL = baseURL + "&chd=t:-1|" + yList + "&chds=" + min + "," + max; 
	
%>

<%= requestURL %> 