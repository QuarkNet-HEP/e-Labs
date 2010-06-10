<%@ page 
	import="java.util.*"
	import="java.io.*"
	import="org.w3c.dom.*"
	import="java.sql.*"
	import="gov.fnal.elab.cms.*"
	import="gov.fnal.elab.cms.dataset.*"
%>
<%@ include file="../include/elab.jsp" %>
<%
	// the dataset is validated by dataset-info
	String pdataset = request.getParameter("dataset");
	String runs = request.getParameter("runs");
	String plots = request.getParameter("plots");
	
	Dataset dataset = Datasets.getDataset(elab, session, pdataset);
	
	long st = System.currentTimeMillis();
	
	String location = elab.getProperty("dataset.location." + dataset.getName());
	
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
	    Map<String, String> pp = new HashMap<String, String>();
		pp.put("logx", "false");
		pp.put("logy", "false");
		pp.put("color", "black");
	    String[] cp = plot.split(",");
	    for (String cpe : cp) {
	        String[] kv = cpe.split(":");
	        pp.put(kv[0], kv[1]);
	    }
	    String path = pp.get("path");

		out.write("path: " + pp.get("path") + "\n");
		out.write("logx: " + pp.get("logx") + "\n");
		out.write("logy: " + pp.get("logy") + "\n");
		if (pp.containsKey("maxy")) {
		    out.write("maxy: " + pp.get("maxy") + "\n");
		}
		if (pp.containsKey("minx")) {
		    out.write("minx: " + pp.get("minx") + "\n");
		}
		if (pp.containsKey("maxx")) {
		    out.write("maxx: " + pp.get("maxx") + "\n");
		}
		if (pp.containsKey("binwidth")) {
			out.write("binwidth: " + pp.get("binwidth") + "\n");
		}
	
		Leaf leaf = dataset.getLeaf(path);
		
		out.write("title: " + leaf.getTitle() + "\n");
		out.write("labelx: " + leaf.getLabelx() + "\n");
		out.write("labely: " + leaf.getLabely() + "\n");
		out.write("units: " + leaf.getUnits() + "\n");
		out.write("description: " + leaf.getDescription() + "\n");
		
		out.write("color: " + pp.get("color") + "\n");
		for (String run : sruns) {
			String file = dataset.getRunFiles().get(run);
			if (file == null) {
				throw new RuntimeException("Invalid run: " + run);	    
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