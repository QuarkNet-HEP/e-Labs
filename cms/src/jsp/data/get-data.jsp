<%@ page 
	import="java.util.*"
	import="java.io.*"
	import="org.w3c.dom.*"
	import="java.sql.*"
	import="gov.fnal.elab.cms.*"
%>
<%@ include file="../include/elab.jsp" %>
<jsp:include page="../data/dataset-info.jsp">
	<jsp:param name="dataset" value="${param.dataset}"/>
</jsp:include>
<%
	// the dataset is validated by dataset-info
	String dataset = request.getParameter("dataset");
	String runs = request.getParameter("runs");
	String plots = request.getParameter("plots");
	
	long st = System.currentTimeMillis();
	Document doc = (Document) request.getAttribute("currentDataset");
	
	NodeList branches = doc.getElementsByTagName("branch");
	Map<String, Map<String, Map<String, String>>> props = 
	    (Map<String, Map<String, Map<String, String>>>) session.getAttribute("plot-params");
	if (props == null) {
	    props = new HashMap<String, Map<String, Map<String, String>>>();
	    session.setAttribute("plot-params", props);
	}
	Map<String, Map<String, String>> dsprops = props.get(dataset);
	if (dsprops == null) {
		dsprops = new HashMap<String, Map<String, String>>();
		for (int i = 0; i < branches.getLength(); i++) {
		    Node branch = branches.item(i);
		    String v1 = branch.getAttributes().getNamedItem("name").getNodeValue();
		    NodeList leaves = branch.getChildNodes();
		    for (int j = 0; j < leaves.getLength(); j++) {
		    	Node leaf = leaves.item(j);
		    	if (leaf.getNodeType() != Node.ELEMENT_NODE) {
		    	    continue;
		    	}
		    	String v2 = leaf.getAttributes().getNamedItem("name").getNodeValue();
		    	Map<String, String> p = new HashMap<String, String>();
		    	dsprops.put(v1 + "." + v2, p);
		    	for (String attr : new String[] { "title", "labelx", "labely", "units", "description" }) {
		    	    p.put(attr, 
		    	    	LabelPrettyPrinter.formatLabel(leaf.getAttributes().getNamedItem(attr).getNodeValue()));
		    	}
		    }
		}
		props.put(dataset, dsprops);
	}
	System.out.println("dsprops load time: " + (System.currentTimeMillis() - st) + "ms");
	st = System.currentTimeMillis();
	
	Map<String, Map<String, String>> runfiles = (Map<String, Map<String, String>>) session.getAttribute("run-files");
	if (runfiles == null) {
		runfiles = new HashMap<String, Map<String, String>>();
		session.setAttribute("run-files", runfiles);
	}
	Map<String, String> dsrunfiles = runfiles.get(dataset);
	if (dsrunfiles == null) {
		dsrunfiles = new HashMap<String, String>();
		String db = elab.getProperties().getProperty("ogredb.database");
		String dbuser = elab.getProperties().getProperty("ogredb.username");
		String dbpass = elab.getProperties().getProperty("ogredb.password");

		try {
			Class.forName("com.mysql.jdbc.Driver");
		}
		catch (ClassNotFoundException e) {
		    throw new RuntimeException("Couldn't find the mysql driver!");
		}

		String table;
		if ("tb04".equals(dataset)) {
		    table = "rundb";
		}
		else {
		    table = "mcdb";
		}
		String sql = "SELECT run, filename FROM " + table; 

		Connection conn = DriverManager.getConnection("jdbc:mysql:" + db, dbuser, dbpass);
		if (conn == null) {
		    throw new SQLException(
		        "Connection to database failed. The SQL driver manager "
		            + "did not return a valid connection");
		}
		try {
			Statement s = conn.createStatement();
			ResultSet rs = s.executeQuery(sql);
			while (rs.next()) {
				dsrunfiles.put(rs.getString(1), rs.getString(2));
			}
		}
		finally {
		    conn.close();
		}
		runfiles.put(dataset, dsrunfiles);
	}
	System.out.println("dsrunfiles load time: " + (System.currentTimeMillis() - st) + "ms");
	st = System.currentTimeMillis();
	
	String location = elab.getProperties().getProperty("dataset." + dataset + ".location");
	
	String[] sruns = runs.split("\\s+");
	String[] splots = plots.split("\\s+");
	String combine = request.getParameter("combine");
	if (combine == null || combine.equals("") || combine.equals("off") || combine.equals("false")) {
		out.write("combine: false\n");
	}
	else {
	    out.write("combine: true\n");
	}

	for (String plot : splots) {
	    String[] cp = plot.split(":");
	    String path = cp[0];
	    String color = cp[1];
		out.write("path: " + path + "\n");
		Map<String, String> p = dsprops.get(path);
		if (cp.length > 2 && "logx".equals(cp[2])) {
		    out.write("logx: true\n");
		}
		else {
		    out.write("logx: false\n");
		}
		if (cp.length > 3 && "logy".equals(cp[3])) {
		    out.write("logy: true\n");
		}
		else {
		    out.write("logy: false\n");
		}
		for (String attr : new String[] { "title", "labelx", "labely", "units", "description" }) {
		 	out.write(attr + ": " + p.get(attr) + "\n");   
		}
		out.write("color: " + color + "\n");
		for (String run : sruns) {
			String file = dsrunfiles.get(run);
			if (file == null) {
				throw new RuntimeException("Invalid run: " + run);	    
			}
			if (file.endsWith(".root")) {
			    file = file.substring(0, file.length() - 5);
			}
			BufferedReader br = new BufferedReader(new FileReader(location + "/" + file + "/" + path));
			out.write("run: " + run + "\n");
			try {
				String line = br.readLine();
				while (line != null) {
				    if (!line.startsWith("#")) {
				        String[] g = line.split("\\s+", 2);
				        if (g.length == 2) { 
				    		out.write(g[0] + ": " + g[1]);
				    		out.write('\n');
				        }
				    }
				    line = br.readLine();
				}
			}
			finally {
			    br.close();
			}
		}
	}
	System.out.println("data read time: " + (System.currentTimeMillis() - st) + "ms");
%>