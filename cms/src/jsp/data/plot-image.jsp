<%@ page
	import="java.io.*"
	import="gov.fnal.elab.cms.plot.*"
	import="gov.fnal.elab.cms.dataset.*"
%><%@
	include file="../include/elab.jsp"
%><%
	String pdataset = request.getParameter("dataset");
	String runs = request.getParameter("runs");
	String plot = request.getParameter("plots");
	String thumbnail = request.getParameter("thumbnail");
	
	Dataset dataset = Datasets.getDataset(elab, session, pdataset);
	int index = "true".equals(thumbnail) ? 1 : 0;

	File[] imgs = PlotTool.getOrCreatePlot(elab, dataset, runs, plot);
	
	out.clear();
	response.setContentType("image/png");
	OutputStream os = response.getOutputStream();
	
	InputStream is = new FileInputStream(imgs[index]);
	byte[] buf = new byte[16394];
	int len = is.read(buf);
	while (len != -1) {
		os.write(buf, 0, len);
		len = is.read(buf);
	}
	is.close();
	os.close();
%>