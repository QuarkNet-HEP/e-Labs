<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Saving Plot...</title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
		<table width="100%" cellpadding="0" cellspacing="0" align="center">
			<%
					String groupName = user.getGroup().getName();
					String dataset = request.getParameter("dataset");
					String runs = request.getParameter("runs");
					String plots = request.getParameter("plots");
					String expr = request.getParameter("expr");
					String analysis = request.getParameter("analysis");
					
					String base = "dataset=" + dataset + "&runs=" + runs + "&plots=" + plots;
					String plotURL = "../data/plot-image.jsp?" + base;
					String thumbnailURL = plotURL + "&thumbnail=true";
					
					//filename from user input
					String userFilename = request.getParameter("name");
					
					if ( userFilename == null || userFilename.equals("") ) {
					    throw new ElabJspException("You forgot to specify the name of your file. Please close this window and enter it.");
					}
					
					DataCatalogProvider dcp = elab.getDataCatalogProvider();
					CatalogEntry e = dcp.getEntry(userFilename);
					if (e != null) {
					    throw new ElabJspException("A saved plot with this name (\"" + userFilename + "\") already exists");
					}
					
					// *** Metadata section ***
					ArrayList meta = new ArrayList();
					ElabGroup group = user.getGroup();
					
					// Default metadata for all files saved
					meta.add("type string plot");
					meta.add("city string " + group.getCity());
					meta.add("group string " + group.getName());
					meta.add("name string " + userFilename);
					meta.add("project string " + elab.getName());
					meta.add("school string " + group.getSchool());
					meta.add("state string " + group.getState());
					meta.add("teacher string " + group.getTeacher());
					meta.add("year string " + group.getYear());
					meta.add("thumbnailURL string " + thumbnailURL);
					meta.add("dataset string " + dataset);
					meta.add("runs string " + runs);
					meta.add("analysis string " + analysis);
					
					String[] plotsv = plots.split("\\s+");
					for (int i = 0; i < plotsv.length; i++) {
					    String[] kvv = plotsv[i].split(",");
					    for (String kv : kvv) {
					        String[] p = kv.split(":", 2);
							if (p[0].equals("maxx") || p[0].equals("minx") || p[0].equals("maxy")) {
							    meta.add(p[0] + i + " float " + p[1]);
							}
							else if (p[0].equals("logx") || p[0].equals("logy")) {
							    meta.add(p[0] + i + " boolean " + p[1]);
							}
							else {
								meta.add(p[0] + i + " string " + p[1]);	    
							}
					    }
					}
					
					meta.add("_plots string " + plots);
					meta.add("triggerExpression string " + expr);
					

					dcp.insert(DataTools.buildCatalogEntry(userFilename, meta));
			%>
	            	<p>You saved your plot permanently as file <%= userFilename %> 
		</table>
			
		<a href=# onclick="window.close()">Close</A>
	</body>
</html>
