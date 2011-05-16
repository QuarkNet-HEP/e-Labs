<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.estimation.*" %>
<%@ page import="gov.fnal.elab.tags.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<%
	boolean ignoreConstraints = Boolean.valueOf(request.getParameter("ignore-constraints"));
	
	double lambda = Double.parseDouble(request.getParameter("delay")) * 10;
	
	long seed = Long.parseLong(request.getParameter("seed"));
	
	Random r = new Random();
	if (seed != 0) {
		r.setSeed(seed);
	}
	
	// get all data files and respective event counts
	In and = new In();
	and.add(new Equals("project", elab.getName()));
	and.add(new Equals("type", "split"));
	ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
	request.setAttribute("count", rs.size());
	List<CatalogEntry> l = new ArrayList<CatalogEntry>();
	
	List<String> types = new ArrayList<String>();
	for (String s : new String[] {"I2U2.Cosmic::PerformanceStudy", "I2U2.Cosmic::ShowerStudy", "I2U2.Cosmic::FluxStudy", "I2U2.Cosmic::LifetimeStudy"}) {
		if (request.getParameter(s) != null) {
			types.add(s);
		}
	}
	
	List<String> modes = new ArrayList<String>();
	for (String s: new String[] {"local", "i2u2", "mixed"}) {
		if (request.getParameter(s) != null) {
			modes.add(s);
		}
	}
	
	l.addAll(rs);
	
	int count = Integer.parseInt(request.getParameter("count"));
	
	List<Map<String, Object>> a = new ArrayList<Map<String, Object>>();
	
	int totalDelay = 0;
	
	for (int i = 0; i < count; i++) {
		Set<CatalogEntry> selected = new HashSet<CatalogEntry>();
		List<String> lfns = new ArrayList<String>();
		Map<String, Object> m = new HashMap<String, Object>();
		a.add(m);
		m.put("files", lfns);
	
		int type = (int) Math.floor(r.nextDouble() * 4);
		m.put("type", types.get(type));
		
		switch(type) {
			case 0:
				m.put("shortType", "performance");
				break;
			case 1:
				m.put("shortType", "shower");
				break;
			case 2:
				m.put("shortType", "flux");
				break;
			case 3:
				m.put("shortType", "lifetime");
				break;
		}
	
		
		//make sure we don't loop forever trying to meet some anattainable condition
		int retries = 100;
	
		if ("Events".equals(request.getParameter("feprio"))) {
			long minev = Long.parseLong(request.getParameter("eventmin"));
			long maxev = Long.parseLong(request.getParameter("eventmax"));
			
			long eventGoal = (long) Math.floor(r.nextDouble() * (maxev - minev)) + minev;
			
			long crtev = 0;
			
			while (crtev < eventGoal) {
				if (retries == 0) {
					break;
				}
			
				int index = (int) Math.floor(r.nextDouble() * l.size());
				long fev = 0;
				CatalogEntry e = l.get(index);
				// avoid duplicates
				if (selected.contains(e.getLFN())) {
					retries--; 
					continue;
				}
		
				for (int j = 1; j <= 4; j++) {
					Long evc = (Long) e.getTupleValue("chan" + j);
					if (evc != null) {
						fev += evc; 
					} 
				}
		
				if (crtev + fev > maxev && !crtev == 0) {
					// this might screw the distribution, but given that this
					// is a knapsack problem, let's not care
					break;
				}
				if (crtev + fev > eventGoal) {
					if (eventGoal - crtev > crtev + fev - eventGoal) {
						if (crtev == 0) {
							continue;
						}
						//closer below
						break;
					}
					else {
						crtev += fev;
						selected.add(e);
						break;
					}
				}
				selected.add(e);
				crtev += fev;
			}
			m.put("events", crtev);
		}
		else {
			int minfc = Integer.parseInt(request.getParameter("filemin"));
			int maxfc = Integer.parseInt(request.getParameter("filemax"));
			int c = (int) Math.floor(r.nextDouble() * (maxfc - minfc)) + minfc;
			long events = 0;
			while (selected.size() < c) {
				if (retries == 0) {
					break;
				}
				int index = (int) Math.floor(r.nextDouble() * l.size());
				CatalogEntry e = l.get(index);
				if (selected.contains(e.getLFN())) {
					retries--;
					continue;
				}
				selected.add(e);
				for (int j = 1; j <= 4; j++) {
					Long evc = (Long) e.getTupleValue("chan" + j);
					if (evc != null) {
						events += evc; 
					}
				}
			}
			m.put("events", events);
		}
		
		if (type == 0) {
			//performance; single file
			while (selected.size() > 1) {
				selected.remove(selected.iterator().next());
			}
		}
		
		m.put("fileCount", selected.size());
		
		for (CatalogEntry e : selected) {
			lfns.add(e.getLFN());
		}
		
		Estimator localEstimator = AnalysisRunTimeEstimator.getEstimator(elab, "swift", "local", types.get(type));
		ElabAnalysis analysis = ElabFactory.newElabAnalysis(elab, null, null);
		m.put("analysis", analysis);
		analysis.setType(types.get(type));
		analysis.setParameter("rawData", lfns);
		int ltime = localEstimator.estimate(elab, analysis);		
		int allowed = elab.getProperties().getMaxAllowedLocalRunTime();
		
		int mode = (int) Math.floor(r.nextDouble() * modes.size());
		
		if (!ignoreConstraints && mode == 0 && ltime > allowed) {
			mode = 1;
		}
		
		int time = AnalysisRunTimeEstimator.getEstimator(elab, "swift", modes.get(mode), types.get(type)).estimate(elab, analysis);
		m.put("etime", TimeIntervalFormatter.formatSeconds(time));
		
		m.put("mode", modes.get(mode));
		
		double x = 1.0;
		double L = Math.exp(-lambda);
		int delay = 0;
		
		while (delay < 10000) {
			x *= r.nextDouble();
			if (x == 0) {
				continue;
			}
			if (x < L) {
				break;
			}
			delay++;
		}
		if (i == 0) {
			delay = 0;
		}
		m.put("delay", delay);
		totalDelay += delay;
		m.put("cDelay", totalDelay);
	}
	
	session.setAttribute("l", a);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis Generator - Generated Workload</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.3.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
		<style>
			.panel {padding: 16px;}
			.panel {background-color: #e0e0e0; vertical-align: top;}
			#form th {background-color: #c0c0c0;}
			.help-item {display: none;}
			#list td.numeric {text-align: right;}
			#list td {padding-left: 4px; padding-right: 4px; background-color: #e0e0e0;}
			#list th {background-color: #c0c0c0;}
		</style>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">			
			<div id="content">
				<h1>Analysis generator - Generated Workload</h1>
				<%@ include file="tester-analysis-list.jspf" %>
		
				<form method="post" action="tester3.jsp">
					<input type="submit" value="Start"/>
				</form>
			</div>
		</div>
	</body>
</html>